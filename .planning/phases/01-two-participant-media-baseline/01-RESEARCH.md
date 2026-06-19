# Phase 1: Two-Participant Media Baseline - Research

**Researched:** 2026-06-19  
**Domain:** Brownfield WebRTC/SFU reliability across Vue 3/XState client and Rust Axum/webrtc-rs backend  
**Confidence:** HIGH for current code-path findings; MEDIUM for external WebRTC testing constraints

## User Constraints

No `01-CONTEXT.md` / phase `CONTEXT.md` exists for this phase, so there are no user-locked phase decisions beyond the roadmap, requirements, and AGENTS.md directives. [VERIFIED: .planning/STATE.md + filesystem]

### Locked Decisions
- Preserve Vue 3, TypeScript, XState, Rust, Axum, WebRTC crate, Diesel, PostgreSQL, Docker Compose, and the existing SFU architecture unless a concrete defect requires a targeted change. [VERIFIED: AGENTS.md]
- Start with the smallest stable two-user flow before widening to late joiners and 3+ participant cases. [VERIFIED: AGENTS.md]
- Do not redesign the product; make the existing meeting experience dependable. [VERIFIED: AGENTS.md]

### the agent's Discretion
- No explicit phase discretion document exists. Planner may choose targeted instrumentation, tests, and the smallest code fix that satisfies Phase 1 requirements. [VERIFIED: filesystem + ROADMAP.md]

### Deferred Ideas (OUT OF SCOPE)
- Third/later participant late-join stability belongs to Phase 2. [VERIFIED: .planning/ROADMAP.md]
- Leave/rejoin cleanup, toggle resilience, and verification documentation hardening belong to Phase 3. [VERIFIED: .planning/ROADMAP.md]
- Room authorization/security overhaul, horizontal scaling, full UI redesign, payments/email/analytics/mobile apps are out of scope for the current milestone. [VERIFIED: .planning/REQUIREMENTS.md]

## Project Constraints (from AGENTS.md)

- Preserve the existing stack and SFU architecture unless a concrete defect requires a targeted change. [VERIFIED: AGENTS.md]
- Read and preserve existing code patterns from `.planning/codebase/` before modifying signaling, SFU, or WebRTC client files. [VERIFIED: AGENTS.md]
- A fix is incomplete until two browser participants in the same room receive each other's audio/video streams and automated checks cover the corrected path where feasible. [VERIFIED: AGENTS.md]
- Start with the smallest stable two-user flow before widening scope. [VERIFIED: AGENTS.md]
- Do not introduce new token, CORS, room-join, or TURN credential exposure while debugging media flow. [VERIFIED: AGENTS.md]
- Avoid holding long-lived room locks across async WebRTC operations when fixing server forwarding behavior. [VERIFIED: AGENTS.md]
- Follow Vue/TypeScript naming, formatting, import, and test conventions documented in AGENTS.md. [VERIFIED: AGENTS.md]
- Follow Rust `rustfmt`, `tracing`, `anyhow::Result` for internal SFU operations, and `crate::` module path conventions. [VERIFIED: AGENTS.md]

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DIAG-01 | Reproduce/simulate two-participant failure and identify failing layer | Instrument the join path from `MeetingPage` → XState actor → `SignalingService` → `WebRTCServiceSFU` → Axum handler → `Room::handle_incoming_track()` → remote `<video>` attachment. [VERIFIED: codebase read] |
| DIAG-02 | Observe client WebRTC state, remote track events, stream-owner mapping, signaling messages | Existing client already tracks connection/ICE state and logs signaling/ontrack; planner should add structured diagnostics for `signalingState`, SDP direction/m-lines, track kind/id/streamId, and `streamOwnerMap`. [VERIFIED: codebase read] |
| DIAG-03 | Observe server room membership, offer/answer, track registration, forwarding, RTCP | Existing server logs joins, ICE, track registration, packet forwarding, PLI/NACK; planner should add assertions/counters around room lock scope and forwarding target snapshots. [VERIFIED: codebase read] |
| MEDIA-01 | First participant can join, publish local audio/video, wait | Current first participant path creates peer connection, adds local tracks, sends offer, and server registers tracks after answer/ICE. [VERIFIED: codebase read] |
| MEDIA-02 | Second participant completes offer/answer plus ICE without breaking first | Server creates one peer connection per participant and handles each participant offer independently; failure risk is renegotiation with new tracks. [VERIFIED: codebase read] |
| MEDIA-03 | Each participant receives/renders remote video | Remote render depends on server `StreamOwner` arriving before client `ontrack`, stream ID matching, and `ParticipantTile` attaching `srcObject`. [VERIFIED: codebase read] |
| MEDIA-04 | Each participant receives remote audio | `ParticipantTile` keeps `<video>` mounted for streams and does not mute remote participants, so audio should play if remote stream has audio and autoplay permits it. [VERIFIED: codebase read] |
| MEDIA-05 | Server forwards RTP without unsafe long room locks | Current `on_track` acquires `room_lock.write().await` then awaits `handle_incoming_track()`, which awaits peer-connection operations; this directly violates the phase constraint and is a likely fix target. [VERIFIED: openmeet-server/src/signaling/handler.rs + openmeet-server/src/sfu/room.rs] |
| MEDIA-06 | Client maps streams to correct participant | Current client falls back to first remote participant without a stream when `streamOwnerMap` lacks a stream ID; planner should make owner mapping deterministic and observable. [VERIFIED: openmeet-client/src/xstate/machines/webrtc/index.ts] |
| VER-01 | Automated/scripted checks cover corrected two-participant flow | Playwright E2E is configured but no E2E tests exist; planner should add a targeted two-page smoke script or Playwright test with fake media when feasible. [VERIFIED: .planning/codebase/TESTING.md + package.json] |
| VER-02 | Real browser/equivalent WebRTC smoke test before completion | Playwright can grant camera/microphone permissions; Chromium fake media flags may be used in launch config. [CITED: https://playwright.dev/docs/api/class-browsercontext#browser-context-grant-permissions] |

</phase_requirements>

## Summary

Phase 1 should be planned as a diagnostic-first, targeted stabilization pass through the existing two-participant SFU path, not as an SFU rewrite. The critical flow is browser `MeetingPage` media initialization, XState `joinRoomActor`, WebSocket signaling, client `RTCPeerConnection`, server per-participant `SfuPeerConnection`, `Room::handle_incoming_track()`, RTP fan-out, `StreamOwner` mapping, and final `ParticipantTile` stream attachment. [VERIFIED: .planning/codebase/ARCHITECTURE.md + codebase read]

The highest-confidence likely root-cause area is server forwarding/renegotiation under room locks: `handler.rs` spawns an `on_track` task that holds the room write lock while awaiting `Room::handle_incoming_track()`, and `handle_incoming_track()` awaits `forward_track_to_others()`, which awaits peer-connection lock/add-track/get-parameters/PLI operations. This matches the known concern and the explicit AGENTS.md constraint to avoid long-lived room locks across async WebRTC operations. [VERIFIED: openmeet-server/src/signaling/handler.rs:278-287 + openmeet-server/src/sfu/room.rs:226-377 + .planning/codebase/CONCERNS.md]

The second high-confidence issue class is client stream ownership/race handling. The server sends `StreamOwner` before adding forwarding tracks, but client assignment still falls back to the first remote participant without a stream if `ontrack` arrives before the owner map or if `stream.id` differs from the ID in `StreamOwner`. The plan should instrument and then remove/guard fallback assignment for Phase 1. [VERIFIED: openmeet-server/src/sfu/room.rs:298-303 + openmeet-client/src/xstate/machines/webrtc/index.ts:96-124]

**Primary recommendation:** Plan one diagnostic wave followed by one minimal fix wave: reproduce with two browser participants, capture structured client/server trace points, then fix the first proven failure among (1) long room lock/renegotiation forwarding, (2) StreamOwner/ontrack race or stream ID mismatch, or (3) offer/answer collision/ICE sequencing. [VERIFIED: roadmap + codebase read]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Media capture and local preview | Browser / Client | — | `WebRTCServiceSFU.initializeMedia()` owns `getUserMedia()` and local tracks. [VERIFIED: openmeet-client/src/services/webrtc-sfu.ts] |
| Meeting lifecycle state | Browser / Client | Frontend Server: — | `webrtcMachine` owns idle/mediaReady/connected/inCall/error states and participant map. [VERIFIED: openmeet-client/src/xstate/machines/webrtc/index.ts] |
| Signaling message transport | Browser / Client + API / Backend | — | Client `SignalingService` sends JSON over `/ws`; Rust `handler.rs` parses `SignalingMessage`. [VERIFIED: codebase read] |
| SDP offer/answer and ICE | Browser / Client + API / Backend | — | Client and server each set local/remote descriptions and exchange candidates. [VERIFIED: openmeet-client/src/services/webrtc-sfu.ts + openmeet-server/src/signaling/handler.rs] |
| Track registration | API / Backend | SFU media layer | Server `on_track` calls `Room::handle_incoming_track()` and stores `participant_tracks`. [VERIFIED: openmeet-server/src/sfu/room.rs] |
| RTP fan-out and RTCP feedback | API / Backend / SFU media | Browser receives/render | `Room` reads RTP, broadcasts packets, rewrites SSRC, writes local tracks, and handles PLI/NACK. [VERIFIED: openmeet-server/src/sfu/room.rs] |
| Stream ownership mapping | API / Backend produces; Browser consumes | — | Server emits `StreamOwner`; client stores `streamOwnerMap` and assigns streams to participants. [VERIFIED: codebase read] |
| Rendering remote media | Browser / Client | — | `ParticipantTile` attaches `participant.stream` to `<video srcObject>`. [VERIFIED: openmeet-client/src/components/meeting-page/ParticipantTile.vue] |
| Regression verification | Browser automation + server checks | Docker Compose/runtime | Playwright/Vitest/Cargo exist; real two-browser behavior is required by requirements. [VERIFIED: .planning/codebase/TESTING.md] |

## Standard Stack

No new production packages should be installed for Phase 1 unless the proven root cause requires a targeted helper. Use the existing stack. [VERIFIED: AGENTS.md + package manifests]

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Vue | ^3.5.22 | Meeting page and media UI rendering | Existing app framework; preserve stack. [VERIFIED: openmeet-client/package.json] |
| XState | ^5.24.0 | Meeting lifecycle state machine and invoked actors | Existing meeting flow uses `fromPromise`/`fromCallback`. [VERIFIED: openmeet-client/package.json + codebase read] |
| TypeScript | ~5.9.0 | Typed client services and signaling unions | Existing client language. [VERIFIED: openmeet-client/package.json] |
| Playwright | ^1.56.1 | Browser/equivalent two-participant smoke tests | Existing E2E runner, configured but no tests yet. [VERIFIED: openmeet-client/package.json + .planning/codebase/TESTING.md] |
| Axum | 0.8.8 | HTTP/WebSocket server | Existing `/ws` backend framework. [VERIFIED: openmeet-server/Cargo.toml] |
| webrtc-rs crate | 0.14 | Server peer connections, tracks, RTP/RTCP | Existing SFU WebRTC implementation. [VERIFIED: openmeet-server/Cargo.toml] |
| Tokio | 1.49 | Async tasks, locks, channels | Existing server runtime for WebSocket and RTP tasks. [VERIFIED: openmeet-server/Cargo.toml] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Vitest | ^3.2.4 | Client unit tests | Use for deterministic stream-owner mapping and XState transition tests with mocked MediaStream/RTCPeerConnection. [VERIFIED: openmeet-client/package.json] |
| Cargo test | rustc/cargo 1.95.0 locally | Server unit/integration checks | Use for pure `Room`/message/peer config tests; full media path likely needs browser smoke. [VERIFIED: environment audit + .planning/codebase/TESTING.md] |
| Docker Compose | v2.31.0 locally | Local dev runtime | Use only if full stack reproduction needs DB/server/client/TURN orchestration. [VERIFIED: environment audit] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Playwright two-page smoke | Manual two-browser checklist only | Manual verifies reality but does not satisfy regression requirement as strongly. [VERIFIED: REQUIREMENTS.md] |
| Vitest unit around mapping | Full WebRTC browser E2E only | E2E catches integration; unit test makes StreamOwner race/mismatch easier to isolate. [ASSUMED] |
| Refactor entire `Room` module | Snapshot-and-release targeted lock fix | Full refactor increases risk; Phase 1 should patch smallest proven lock/forwarding issue. [VERIFIED: AGENTS.md + CONCERNS.md] |

**Installation:**
```bash
# No new package install recommended for Phase 1.
```

## Package Legitimacy Audit

No external packages are recommended for installation in Phase 1, so the package legitimacy gate is not applicable. [VERIFIED: research recommendation]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| none | — | — | — | — | — | No install |

**Packages removed due to slopcheck [SLOP] verdict:** none  
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```text
Participant A browser                    Rust Axum/SFU                         Participant B browser
─────────────────────                    ─────────────                         ─────────────────────
MeetingPage join
  │
  ▼
initMediaActor → getUserMedia
  │
  ▼
joinRoomActor ── WebSocket join ───────▶ handle_socket / Join
  │                                      │ create room/participant/PC
  │                                      └──── joined / participantJoined ─────▶ participant map
  ▼
createPeerConnection + addTrack
  │
  ├── offer + ICE ─────────────────────▶ Offer/IceCandidate handlers
  │                                      │ set remote desc, answer
  │◀──────────────────── answer + ICE ──┘
  │
  ▼                                      on_track from A/B
connection/ICE state                    │
                                         ▼
                                  Room::handle_incoming_track
                                         │ store sender track + broadcaster
                                         │ select receiver participants
                                         │ add forwarding tracks
                                         │ send StreamOwner
                                         │ create renegotiation offer
                                         │ spawn RTP reader/writer + RTCP
                                         ▼
ontrack ◀──────────── offer/answer + RTP forwarding ───────────▶ ontrack
  │                                                               │
  ▼                                                               ▼
STREAM_OWNER map → assign stream                            STREAM_OWNER map → assign stream
  │                                                               │
  ▼                                                               ▼
ParticipantTile video.srcObject                              ParticipantTile video.srcObject
```

### Recommended Project Structure

Do not add broad new subsystems. Add focused test/instrumentation files in existing locations. [VERIFIED: .planning/codebase/STRUCTURE.md]

```text
openmeet-client/
├── e2e/                                      # add two-participant smoke if feasible
├── src/xstate/machines/webrtc/__tests__/     # add mapping/machine regression tests
├── src/services/                             # keep signaling/WebRTC service changes here
└── src/pages/MeetingPage.vue                 # UI/debug panel only if needed

openmeet-server/
├── src/signaling/handler.rs                  # keep protocol handling changes targeted
├── src/sfu/room.rs                           # fix forwarding/lock behavior here first
└── src/sfu/*                                 # only split modules if required by targeted fix
```

### Pattern 1: Diagnostic Trace Across Boundaries

**What:** Add temporary or retained structured logs/events at each handoff: `join`, `joined`, offer, answer, ICE, `on_track`, `StreamOwner`, `ontrack`, stream assignment, and video attachment. [VERIFIED: current logging exists across these files]

**When to use:** First wave before any fix; use it to identify whether the loss happens before SDP, after SDP, at RTP forwarding, or at rendering. [VERIFIED: DIAG requirements]

**Example:**
```typescript
// Source: existing project style in openmeet-client/src/services/webrtc-sfu.ts
this.peerConnection.ontrack = (event) => {
  const stream = event.streams[0];
  console.log('[WebRTCServiceSFU] remote track', {
    kind: event.track.kind,
    trackId: event.track.id,
    streamId: stream?.id,
    signalingState: this.peerConnection?.signalingState,
  });
};
```

### Pattern 2: Snapshot Room State, Release Lock, Then Await WebRTC Work

**What:** Under a room lock, collect receiver IDs, senders, shutdown receivers, and peer connection handles; release the lock before awaiting `peer_conn.lock()`, `pc.add_track()`, `get_parameters()`, `write_rtcp()`, or offer creation. [VERIFIED: AGENTS.md + codebase anti-pattern]

**When to use:** If reproduction shows server forwarding stalls, missing renegotiation, or lock contention during two-user track registration. [VERIFIED: MEDIA-05]

**Example:**
```rust
// Source: derived from AGENTS.md constraint and current Room::forward_track_to_others shape.
// Pseudocode for planning only; exact ownership/lifetimes must be implemented in code.
let targets = {
    let room = room_lock.read().await;
    room.forwarding_targets_except(sender_id)
};

for target in targets {
    // Await peer-connection operations after lock release.
    add_forwarding_track_and_negotiate(target).await?;
}
```

### Pattern 3: Deterministic Stream Owner Mapping

**What:** Treat `StreamOwner` as the source of truth for participant assignment; if a remote track arrives before owner metadata, queue it by `stream.id` or emit a diagnostic rather than guessing. [VERIFIED: current fallback exists]

**When to use:** If diagnostics show `REMOTE_TRACK_RECEIVED` before `STREAM_OWNER`, or stream IDs differ between server `TrackRemote::stream_id()` and browser `event.streams[0].id`. [VERIFIED: codebase read]

**Example:**
```typescript
// Source: replacement pattern for openmeet-client/src/xstate/machines/webrtc/index.ts
const ownerParticipantId = context.streamOwnerMap.get(streamId);
if (!ownerParticipantId) {
  console.warn('[webrtcMachine] Remote stream has no owner yet', { streamId });
  return context.participants;
}
```

### Anti-Patterns to Avoid

- **Broad SFU rewrite:** Phase 1 requires a minimal two-user baseline, not a new media architecture. [VERIFIED: ROADMAP.md + AGENTS.md]
- **Changing signaling on one side only:** Rust `SignalingMessage` and TypeScript `SignalingMessage` duplicate the contract and must stay aligned. [VERIFIED: .planning/codebase/ARCHITECTURE.md]
- **Leaving fallback stream assignment unexamined:** It can mask root cause and assign media to the wrong participant. [VERIFIED: openmeet-client/src/xstate/machines/webrtc/index.ts]
- **Awaiting WebRTC operations while holding `Room` write lock:** Current code does this and AGENTS.md forbids it for fixes. [VERIFIED: codebase read + AGENTS.md]
- **Relying only on unit tests:** Missing remote tracks often require browser/WebRTC behavior, and requirements explicitly demand real browser/equivalent smoke. [VERIFIED: REQUIREMENTS.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Browser media simulation | Custom fake camera/mic JS shim | Playwright/browser fake media permissions/launch flags | Browser WebRTC APIs have permission/autoplay/device semantics that mocks miss. [CITED: https://playwright.dev/docs/api/class-browsercontext#browser-context-grant-permissions] |
| State lifecycle | Ad hoc booleans outside machine | Existing XState machine and `fromCallback` actor cleanup | Callback actors support cleanup functions when stopped. [CITED: https://github.com/statelyai/docs/blob/main/content/docs/callback-actors.mdx] |
| Signaling schema | Separate untyped JSON strings | Existing TS union + Rust serde enum | Contract is already duplicated but explicit; keep it aligned. [VERIFIED: codebase read] |
| RTP retransmission | Custom packet-loss protocol | Existing RTCP PLI/NACK forwarding and `RtpPacketBuffer` | Server already has NACK/PLI handling; Phase 1 should fix routing, not invent media recovery. [VERIFIED: openmeet-server/src/sfu/room.rs] |
| Participant stream assignment | Guess by first empty remote participant | Server `StreamOwner` + queued deterministic assignment | Guessing can silently pass two-user cases while failing correctness. [VERIFIED: codebase read] |

**Key insight:** The hard part is not lack of libraries; it is preserving WebRTC sequencing and async ownership across browser, signaling, server peer connections, RTP tasks, and Vue rendering. [VERIFIED: codebase read]

## Common Pitfalls

### Pitfall 1: `ontrack` before `StreamOwner` mapping

**What goes wrong:** Browser receives a remote stream and `assignStreamToParticipant` cannot find `streamOwnerMap[streamId]`, so it assigns to the first remote participant without a stream. [VERIFIED: openmeet-client/src/xstate/machines/webrtc/index.ts]  
**Why it happens:** WebSocket `StreamOwner` and WebRTC `track` event are independent async channels. [ASSUMED]  
**How to avoid:** Queue unmapped remote streams by stream ID, log the missing owner, then assign only when owner arrives. [ASSUMED]  
**Warning signs:** `Fallback: Assigning stream to` appears in client logs, or stream IDs in `StreamOwner` do not match `event.streams[0].id`. [VERIFIED: codebase read]

### Pitfall 2: Room write lock held across async peer operations

**What goes wrong:** Other join/offer/answer/ICE/track operations in the room can be blocked while forwarding work awaits peer locks, add-track, get-parameters, offer creation, or RTCP writes. [VERIFIED: codebase read]  
**Why it happens:** `handler.rs` holds `room_lock.write().await` while awaiting `room.handle_incoming_track()`. [VERIFIED: openmeet-server/src/signaling/handler.rs]  
**How to avoid:** Snapshot room state under lock and do WebRTC operations after releasing the lock. [VERIFIED: AGENTS.md]  
**Warning signs:** Server logs show track registration but no answer/offer/ICE progress for the other participant, or operations serialize unexpectedly. [ASSUMED]

### Pitfall 3: Renegotiation offer collision or missing retry

**What goes wrong:** Server adds forwarding tracks but skips offer creation when signaling state is not stable, leaving tracks unnegotiated. [VERIFIED: openmeet-server/src/sfu/peer_connection.rs + handler.rs retry logic]  
**Why it happens:** `create_offer_if_stable()` returns `None` outside stable state; retry exists only after client answer for some paths. [VERIFIED: codebase read]  
**How to avoid:** Instrument `signalingState`, pending track IDs, and retry paths; for Phase 1, make two-user pending track retry deterministic. [ASSUMED]  
**Warning signs:** Logs contain `Collision ... pending retry` or `Skipping renegotiation ... collision` without a later successful offer. [VERIFIED: codebase read]

### Pitfall 4: Audio present but not audible due to autoplay/browser policy

**What goes wrong:** Remote audio track is received but not audible if playback is blocked or the element is not playing. [ASSUMED]  
**Why it happens:** Browser autoplay policies and muted/local state differ by browser. [ASSUMED]  
**How to avoid:** Verify `event.track.kind === 'audio'`, `stream.getAudioTracks().length`, video element `paused`, and Playwright/user gesture behavior in smoke tests. [ASSUMED]  
**Warning signs:** `ontrack` logs audio but user hears nothing; `ParticipantTile` catches autoplay errors. [VERIFIED: ParticipantTile.vue]

### Pitfall 5: Testing with one browser context leaks state

**What goes wrong:** Two participants in the same browser context can share permissions/storage/session in ways that differ from two users. [ASSUMED]  
**Why it happens:** Browser contexts isolate permissions/storage; pages in one context are less isolated. [CITED: https://playwright.dev/docs/browser-contexts]  
**How to avoid:** Use two contexts or two pages with deliberate isolation, and grant media permissions per context. [CITED: https://playwright.dev/docs/api/class-browsercontext#browser-context-grant-permissions]

## Code Examples

Verified patterns from official/project sources:

### XState callback actor cleanup

```typescript
// Source: https://github.com/statelyai/docs/blob/main/content/docs/callback-actors.mdx
const resizeLogic = fromCallback(({ sendBack }) => {
  const resizeHandler = (event) => {
    sendBack(event);
  };

  window.addEventListener('resize', resizeHandler);

  return () => {
    window.removeEventListener('resize', resizeHandler);
  };
});
```

Use this pattern if Phase 1 adds handlers in `joinRoomActor`; handler cleanup should call `signalingService.off(...)` for each registered handler instead of relying only on service disconnect. [CITED: Stately docs + VERIFIED: current `off` exists]

### WebRTC remote track handling

```javascript
// Source: https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/track_event
pc.addEventListener('track', (event) => {
  videoElement.srcObject = event.streams[0];
});
```

MDN states the `track` event fires after a new track has been added to an `RTCRtpReceiver`, and `event.streams` contains the associated media streams. [CITED: https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/track_event]

### WebRTC negotiation collision guard

```javascript
// Source: https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Perfect_negotiation
let makingOffer = false;

pc.onnegotiationneeded = async () => {
  try {
    makingOffer = true;
    await pc.setLocalDescription();
    signaler.send({ description: pc.localDescription });
  } finally {
    makingOffer = false;
  }
};
```

MDN recommends separating negotiation logic and guarding offer collisions with explicit state such as `makingOffer`, `ignoreOffer`, and signaling-state checks. [CITED: https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Perfect_negotiation]

### Existing project render path

```vue
<!-- Source: openmeet-client/src/components/meeting-page/ParticipantTile.vue -->
<video
  v-if="participant.stream"
  ref="videoRef"
  autoplay
  playsinline
  :muted="participant.isLocal"
/>
```

This means remote audio/video rendering is controlled by whether the participant has a stream and whether `attachStream()` successfully sets `srcObject` and calls `play()`. [VERIFIED: ParticipantTile.vue]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Ad hoc caller/callee negotiation | Perfect negotiation with collision handling | MDN page last modified 2025-05-27 | Phase 1 should inspect server-initiated renegotiation for stable-state/collision handling rather than adding unconditional offers. [CITED: MDN Perfect negotiation] |
| Browser `addstream` event | `track` event with `RTCTrackEvent.streams` | `track` baseline available since Jan 2020 | Current client correctly uses `ontrack`; fix mapping/rendering around it, not legacy events. [CITED: MDN track event] |
| Unit-only confidence for media | Real browser/equivalent WebRTC smoke | Existing project requirement | Add Playwright/scripted smoke because unit tests cannot fully prove media delivery. [VERIFIED: REQUIREMENTS.md] |

**Deprecated/outdated:**
- `addstream` event should not be introduced; use `track`/`ontrack`. [CITED: https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/track_event]
- One-sided signaling schema changes should not be introduced; update Rust and TypeScript together. [VERIFIED: .planning/codebase/ARCHITECTURE.md]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | WebSocket `StreamOwner` and WebRTC `track` event can arrive in either order. | Common Pitfalls | Planner may overbuild queuing if current ordering is deterministic in all supported browsers. |
| A2 | A Vitest unit test around stream-owner mapping is worthwhile alongside browser smoke. | Standard Stack | Planner might spend time on a unit test that does not catch the actual failure. |
| A3 | Server offer retry may need deterministic pending-track handling for two-user baseline. | Common Pitfalls | Planner may modify negotiation unnecessarily if root cause is elsewhere. |
| A4 | Browser autoplay policy can explain received-but-inaudible remote audio. | Common Pitfalls | Planner may chase UI playback when RTP/track delivery is actually missing. |
| A5 | Separate browser contexts better approximate two users than one shared context. | Common Pitfalls | Test design may be more complex than necessary for local smoke. |

## Open Questions

1. **What is the exact observed failure mode in the current app?**
   - What we know: Requirements mention missing remote media streams; code has plausible failures in forwarding locks, renegotiation, and stream mapping. [VERIFIED: REQUIREMENTS.md + codebase read]
   - What's unclear: Whether current failure is no `ontrack`, wrong owner assignment, no RTP packets, ICE failure, or render/autoplay. [VERIFIED: no reproduction run in this research]
   - Recommendation: First plan task must reproduce and classify the failure using structured trace points. [VERIFIED: DIAG-01]

2. **Does browser `event.streams[0].id` match server `TrackRemote::stream_id()` for forwarded `TrackLocalStaticRTP`?**
   - What we know: Server uses `remote_track.stream_id()` in `StreamOwner` and forwarded tracks; client uses browser `stream.id` for lookup. [VERIFIED: codebase read]
   - What's unclear: Whether webrtc-rs/browser preserves that stream ID through renegotiation in all cases. [ASSUMED]
   - Recommendation: Instrument and assert IDs during two-user smoke before changing mapping design. [ASSUMED]

3. **Can local Docker Compose run the full WebRTC path reliably on this workstation?**
   - What we know: Docker, Node/Yarn, Cargo are available locally. [VERIFIED: environment audit]
   - What's unclear: Whether env files, DB, TURN/STUN, certs, and submodule dependency installs are ready without secrets. [VERIFIED: env files not read per AGENTS.md]
   - Recommendation: Plan should include a fallback scripted smoke against dev server if Compose/env setup blocks. [ASSUMED]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Node.js | client build/test/dev | ✓ | v23.8.0 | Use CI Node 22 if local engine warnings matter. [VERIFIED: environment audit + package.json] |
| npm | package scripts if needed | ✓ | 10.9.2 | Prefer Yarn because lockfile is Yarn Classic. [VERIFIED: environment audit + TESTING.md] |
| Yarn Classic | client install/test scripts | ✓ | 1.22.22 | npm scripts may work but lock parity is weaker. [VERIFIED: environment audit] |
| Cargo | server check/test | ✓ | 1.95.0 | CI stable toolchain if local differs. [VERIFIED: environment audit] |
| rustc | server compilation | ✓ | 1.95.0 | CI stable toolchain if local differs. [VERIFIED: environment audit] |
| Docker | full-stack local runtime | ✓ | 27.4.0 | Run client/server directly if Compose/env blocks. [VERIFIED: environment audit] |
| Docker Compose | dev orchestration | ✓ | v2.31.0-desktop.2 | Direct process launch with PostgreSQL service if Compose blocks. [VERIFIED: environment audit] |
| Browser automation | VER-02 smoke | ✓ via Playwright dependency | ^1.56.1 in package.json | Manual two-browser verification if automation cannot access media. [VERIFIED: package.json] |

**Missing dependencies with no fallback:** none discovered during research. [VERIFIED: environment audit]

**Missing dependencies with fallback:** possible env/TURN/cert readiness unknown because real `.env*` files must not be read; use documented examples or manual setup if local Compose fails. [VERIFIED: AGENTS.md no-secret rule]

## Validation Architecture

Skipped because `.planning/config.json` explicitly sets `workflow.nyquist_validation` to `false`. Phase still requires verification through VER-01 and VER-02. [VERIFIED: .planning/config.json + REQUIREMENTS.md]

## Security Domain

Security enforcement is not explicitly disabled in `.planning/config.json`, so Phase 1 planning must avoid worsening existing security posture while debugging media. [VERIFIED: .planning/config.json]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | No direct Phase 1 auth change | Do not alter token/cookie auth while fixing media. [VERIFIED: AGENTS.md] |
| V3 Session Management | No direct Phase 1 session change | Avoid changes to refresh/access token storage. [VERIFIED: AGENTS.md] |
| V4 Access Control | Yes, room join is currently public but out of scope | Do not broaden room join exposure; leave full room authorization to deferred security work. [VERIFIED: CONCERNS.md + REQUIREMENTS.md] |
| V5 Input Validation | Yes for signaling diagnostics | Do not add unbounded diagnostic payloads or expose secret/env values in logs. [VERIFIED: AGENTS.md + CONCERNS.md] |
| V6 Cryptography | No direct Phase 1 crypto change | Do not change TLS/TURN credential handling except to avoid exposing credentials. [VERIFIED: AGENTS.md] |
| V10 Malicious Code | Yes for test/package changes | Do not install new unverified packages; no new packages recommended. [VERIFIED: Package Legitimacy Audit] |

### Known Threat Patterns for OpenMeet media debugging

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Logging TURN credentials or env secrets during diagnostics | Information Disclosure | Log presence/shape only; never print `.env*` values. [VERIFIED: AGENTS.md] |
| Debug endpoint or verbose signaling payload exposed in production | Information Disclosure | Keep diagnostics behind existing logs/tests or dev-only flags. [ASSUMED] |
| Relaxing CORS/WebSocket origin while testing | Spoofing/Tampering | Do not modify CORS/origin policy in Phase 1 unless directly required and then only tighten. [VERIFIED: AGENTS.md + CONCERNS.md] |
| Unbounded chat/room/message diagnostics | Denial of Service | Keep payload sizes bounded and avoid storing large SDP/media blobs in app state. [ASSUMED] |

## Sources

### Primary (HIGH confidence)

- `.planning/STATE.md` - phase status, decisions, known context. [VERIFIED: file read]
- `.planning/ROADMAP.md` - Phase 1 scope and success criteria. [VERIFIED: file read]
- `.planning/REQUIREMENTS.md` - DIAG/MEDIA/VER requirements and out-of-scope items. [VERIFIED: file read]
- `.planning/codebase/ARCHITECTURE.md` - current architecture/data flow/anti-patterns. [VERIFIED: file read]
- `.planning/codebase/CONCERNS.md` - known SFU, lock, mapping, and test gaps. [VERIFIED: file read]
- `.planning/codebase/TESTING.md` - existing test runners and gaps. [VERIFIED: file read]
- `.planning/codebase/STRUCTURE.md` - file locations and where to add code. [VERIFIED: file read]
- `AGENTS.md` - project constraints and conventions. [VERIFIED: instruction context]
- Live code: `openmeet-client/src/pages/MeetingPage.vue`, `openmeet-client/src/xstate/machines/webrtc/*`, `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/components/meeting-page/*`. [VERIFIED: file read]
- Live code: `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/signaling/message.rs`, `openmeet-server/src/sfu/room.rs`, `openmeet-server/src/sfu/peer_connection.rs`. [VERIFIED: file read]
- Context7 `/statelyai/docs` - XState callback actor cleanup. [CITED: https://github.com/statelyai/docs/blob/main/content/docs/callback-actors.mdx]
- Context7 `/microsoft/playwright.dev` - `browserContext.grantPermissions`. [CITED: https://playwright.dev/docs/api/class-browsercontext#browser-context-grant-permissions]
- MDN WebRTC `track` event. [CITED: https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/track_event]
- MDN WebRTC perfect negotiation. [CITED: https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Perfect_negotiation]

### Secondary (MEDIUM confidence)

- Local environment version probes for Node, npm, Yarn, Cargo, rustc, Docker, Docker Compose. [VERIFIED: environment audit]

### Tertiary (LOW confidence)

- Assumptions listed in the Assumptions Log about event ordering, autoplay, and test isolation. [ASSUMED]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - package manifests and AGENTS.md constrain Phase 1 to existing stack. [VERIFIED]
- Architecture: HIGH - codebase maps and live code agree on the join/signaling/SFU/render path. [VERIFIED]
- Likely root causes: MEDIUM-HIGH - lock scope and mapping risks are verified in code, but exact failure was not reproduced during research. [VERIFIED + ASSUMED]
- Pitfalls: MEDIUM - several are verified current risks, but final prioritization depends on reproduction trace. [VERIFIED + ASSUMED]
- Verification strategy: MEDIUM - tools exist, but local fake-media/full-stack feasibility still needs execution. [VERIFIED + ASSUMED]

**Research date:** 2026-06-19  
**Valid until:** 2026-07-19 for current code-path findings; re-check docs/tooling if dependencies change.
