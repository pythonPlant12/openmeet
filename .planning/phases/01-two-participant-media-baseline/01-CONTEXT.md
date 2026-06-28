# Phase 01: Two-Participant Media Baseline - Context

**Gathered:** 2026-06-27
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 1 reproduces the deployed two-participant failure, identifies the concrete failing layer, and fixes the smallest path needed for two participants in the same room to stay connected and receive each other's audio/video. This is a brownfield reliability/debugging phase, not a product redesign or SFU rewrite.

The reported production symptom is that the app works locally, but on the VPS deployment both participants disconnect after the second participant joins, with no visible UI error. Planning must therefore cover both the media failure and the missing user-visible disconnect state.

</domain>

<decisions>
## Implementation Decisions

### Reproduction Target
- **D-01:** Reproduce the failure on the deployed VPS environment first, using the live UI at `https://openmeets.eu/room/1/` and server/container logs as the primary evidence source.
- **D-02:** SSH access may be used for read-only log inspection and diagnostics, but code changes should be made locally unless a concrete blocker requires VPS-side debugging. Do not record or expose SSH credentials in planning docs, logs, commits, or UI output.
- **D-02a:** The VPS SSH target is `debian@162.19.154.153`. The password was provided by the user in chat for this session only; treat it as an ephemeral secret and never persist it in repository artifacts, summaries, shell history snippets, screenshots, logs, or UI output.
- **D-03:** If localhost and VPS behavior differ, VPS behavior wins for Phase 1 because the user-reported failure is production-only.
- **D-04:** The primary reproduction shape is two fresh browser participants in the same room with audio/video enabled. After the two-participant path passes, a third participant may be observed only as non-blocking Phase 2 signal.

### User-Visible Failures
- **D-05:** Unexpected terminal disconnects must produce a blocking user-visible error using the existing meeting error flow/dialog instead of silently leaving participants disconnected.
- **D-06:** Treat peer connection `failed` and unexpected WebSocket close/reconnect exhaustion as user-visible terminal failures. Transient `disconnected` states should be observable for diagnostics, but should not immediately block the user if the browser can recover.
- **D-07:** Error copy should be plain and recovery-focused: tell the participant the meeting connection was lost and offer leave/rejoin behavior. Do not expose SDP, TURN credentials, environment values, tokens, or internal stack traces in the UI.
- **D-08:** Add safe structured diagnostics where needed for WebSocket close codes/reconnect exhaustion, peer and ICE states, track/stream IDs, participant IDs, and server forwarding events. Keep diagnostic payloads bounded and secret-free.

### Verification Proof
- **D-09:** Phase 1 is not complete until two browser participants on `https://openmeets.eu/room/1/` both receive remote audio/video and remain connected through the observed failure window.
- **D-10:** Add the best practical regression coverage for the proven root cause: deterministic unit/integration tests where feasible plus a scripted or documented two-browser smoke path. If full WebRTC automation cannot run reliably in CI, the blocker and fallback manual/browser evidence must be documented.
- **D-11:** Three- or four-participant stability is not a Phase 1 blocker. If a third participant is easy to observe after the two-person pass, record the result for Phase 2; do not expand the Phase 1 fix scope to guarantee 3+ participant stability.
- **D-12:** The eventual phase summary must include UI verification evidence, relevant client/server log markers, exact automated/manual checks run, and any non-blocking third-participant observation.

### the agent's Discretion
- The agent may choose the exact logging format, test file placement, and local reproduction setup as long as decisions D-01 through D-12 and the phase requirements are satisfied.
- The agent may decide whether to use Playwright, Vitest, cargo tests, direct browser sessions, or a combination based on the proven root cause and repository constraints.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Planning Scope
- `.planning/PROJECT.md` — Project constraints, out-of-scope work, and the brownfield reliability goal.
- `.planning/REQUIREMENTS.md` — Phase 1 DIAG, MEDIA, and VER requirements plus acceptance criteria.
- `.planning/ROADMAP.md` — Phase 1 boundary, Phase 2 deferral for late joiner/3+ participant stability, and planning notes.
- `.planning/phases/01-two-participant-media-baseline/01-RESEARCH.md` — Existing research on likely root causes, pitfalls, and validation strategy.

### Client Meeting Flow
- `openmeet-client/src/pages/MeetingPage.vue` — Join flow, connection status UI, and current error-dialog trigger behavior.
- `openmeet-client/src/xstate/machines/webrtc/index.ts` — Meeting lifecycle state, stream-owner mapping, remote stream assignment, error transitions, and cleanup.
- `openmeet-client/src/xstate/machines/webrtc/actors.ts` — WebRTC/signaling actor bridge and long-lived handler setup.
- `openmeet-client/src/services/webrtc-sfu.ts` — Browser `RTCPeerConnection`, local tracks, offer/answer, ICE, remote track callback, and cleanup.
- `openmeet-client/src/services/signaling.ts` — WebSocket connect/close/reconnect handling and signaling message dispatch.
- `openmeet-client/src/components/meeting-page/ConnectionErrorDialog.vue` — Existing blocking error UI to reuse or extend.
- `openmeet-client/src/components/meeting-page/ParticipantTile.vue` — Remote media attachment and playback behavior.

### Server Signaling and SFU Flow
- `openmeet-server/src/signaling/handler.rs` — WebSocket lifecycle, participant join, offer/answer/ICE handling, on-track setup, and cleanup.
- `openmeet-server/src/signaling/message.rs` — Rust signaling contract that must stay aligned with the TypeScript union.
- `openmeet-server/src/sfu/room.rs` — Participant room state, incoming track registration, RTP forwarding, RTCP feedback, and current lock-sensitive forwarding path.
- `openmeet-server/src/sfu/peer_connection.rs` — Server-side peer connection setup, ICE/TURN/STUN config, SDP methods, and negotiation state guards.
- `openmeet-server/src/sfu/participant.rs` — Participant connection, outbound signaling sender, peer connection storage, and shutdown signal.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ConnectionErrorDialog.vue`: Existing blocking dialog should be reused for terminal disconnect visibility instead of adding a new UI surface.
- `MeetingPage.vue` debug/status panel: Already exposes state, peer connection state, ICE state, and participant count; can be extended cautiously for diagnostic visibility if needed.
- `SignalingService.off()` and `disconnect()`: Existing handler cleanup primitives should be used if new signaling callbacks are added.

### Established Patterns
- Client meeting state is owned by `webrtcMachine`; user-visible terminal failures should enter or notify the machine rather than living only in service-level console logs.
- Client service logs use tagged prefixes such as `[WebRTCServiceSFU]`, `[SignalingService]`, and `[webrtcMachine]`; new diagnostics should follow this pattern.
- Rust server logging uses `tracing` macros; new server diagnostics should use `info!`, `warn!`, or `error!` with participant/room identifiers and without secrets.
- Signaling message shapes are duplicated in TypeScript and Rust; any new client-visible signaling event or payload change must update both sides.

### Integration Points
- `MeetingPage.vue` currently opens `ConnectionErrorDialog` only when `connectionState === 'failed'`; Phase 1 must also route unexpected signaling termination/reconnect exhaustion into visible UI state.
- `SignalingService.handleDisconnect()` currently retries and then logs max retries without a typed callback to the XState machine; this is a likely integration point for the missing UI error.
- `WebRTCServiceSFU.createPeerConnection()` logs peer connection state changes but does not itself surface all terminal signaling failures to UI state.
- `webrtcMachine.assignStreamToParticipant()` currently falls back to the first remote participant without a stream if no `streamOwnerMap` entry exists; this can hide or misassign the real media failure.
- `handler.rs` currently holds a room write lock while awaiting `Room::handle_incoming_track()`, and `room.rs` awaits peer connection/RTCP operations while forwarding. This is a likely root-cause area and must be handled without broad SFU rewrites.

</code_context>

<specifics>
## Specific Ideas

- Start from the live production URL `https://openmeets.eu/room/1/` because that is where the user sees the two-participant disconnect.
- Use VPS access through `ssh debian@162.19.154.153` for log inspection only; do not store credentials in artifacts.
- Make silent WebSocket closure/reconnect exhaustion visible to the user, not just to console logs.
- Capture enough evidence to answer whether failure is in signaling, SDP/ICE, stream ownership, RTP forwarding, or rendering.

</specifics>

<deferred>
## Deferred Ideas

- Full 3-4 participant audio/video stability belongs to Phase 2 (`Late Joiner and 3+ Participant Stability`). Phase 1 may record non-blocking third-participant observations only after the two-participant baseline passes.
- Leave/rejoin cleanup, media toggle resilience, and full verification documentation hardening remain Phase 3 scope unless directly required to fix the two-participant production failure.

</deferred>

---

*Phase: 01-two-participant-media-baseline*
*Context gathered: 2026-06-27*
