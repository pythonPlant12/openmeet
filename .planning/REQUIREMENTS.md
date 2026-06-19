# Requirements: OpenMeet Multi-Participant Media Stability

**Defined:** 2026-06-19
**Core Value:** Participants in the same OpenMeet room can maintain stable, bidirectional audio/video without missing remote media streams.

## v1 Requirements

Requirements for the current reliability milestone. Each maps to exactly one roadmap phase.

### Reproduction and Instrumentation

- [ ] **DIAG-01**: Agent can reproduce or simulate the current two-participant media failure and identify whether the failure occurs in signaling, SDP negotiation, ICE, stream ownership, RTP forwarding, RTCP feedback, or client rendering.
- [ ] **DIAG-02**: Agent can observe client-side WebRTC state transitions, remote track events, stream-owner mapping, and signaling messages during a two-participant join.
- [ ] **DIAG-03**: Agent can observe server-side room membership, offer/answer handling, incoming track registration, forwarding target selection, RTP packet forwarding, and RTCP feedback during a two-participant join.

### Two-Participant Stability

- [ ] **MEDIA-01**: First participant can join a room, publish local audio/video, and remain connected while waiting for another participant.
- [ ] **MEDIA-02**: Second participant can join the same room and complete offer/answer plus ICE flow without breaking the first participant's connection.
- [ ] **MEDIA-03**: Each of two participants receives and renders the other participant's video stream.
- [ ] **MEDIA-04**: Each of two participants receives the other participant's audio track without missing remote media events.
- [ ] **MEDIA-05**: Server RTP forwarding sends packets from each participant's incoming tracks to the other participant's peer connection without holding unsafe long-lived room locks.
- [ ] **MEDIA-06**: Client stream ownership maps remote tracks to the correct participant instead of relying on ambiguous fallback assignment.

### Multi-Participant and Late Joiner Stability

- [ ] **MULTI-01**: A third participant can join an existing room after two participants are already connected.
- [ ] **MULTI-02**: Existing participants receive the late joiner's audio/video after renegotiation.
- [ ] **MULTI-03**: The late joiner receives existing participants' audio/video after renegotiation.
- [ ] **MULTI-04**: Renegotiation offers, answers, and track negotiated state remain consistent when participants join in sequence.

### Resilience and Cleanup

- [ ] **RES-01**: Leaving or disconnecting a participant removes their room state, forwarding tasks, local tracks, and client handlers without breaking remaining participants.
- [ ] **RES-02**: A participant can leave and rejoin the same room without stale module-level WebRTC or signaling service handlers receiving duplicate events.
- [ ] **RES-03**: Media toggle state changes do not disrupt established remote audio/video delivery.

### Verification and Documentation

- [ ] **VER-01**: Automated tests or scripted checks cover the corrected two-participant media flow at the most practical level available in this repo.
- [ ] **VER-02**: Verification includes a real browser or equivalent WebRTC smoke test for two participants before the phase is considered complete.
- [ ] **VER-03**: The corrected connection flow and manual verification steps are documented for future debugging.
- [ ] **VER-04**: Existing client and server quality gates pass after the fix: client type/lint/unit checks where applicable and server cargo check/test where applicable.

## v2 Requirements

Deferred to future reliability/security milestones. Tracked but not in the current roadmap.

### Room Security

- **ROOM-01**: Authenticated users can only join rooms they are allowed to access.
- **ROOM-02**: Room IDs, participant names, and chat payloads are validated and rate-limited.
- **ROOM-03**: WebSocket origin checks and CORS restrictions protect production deployments.

### Operational Hardening

- **OPS-01**: SFU exposes per-room participant, forwarding-task, packet-loss, reconnect, and renegotiation metrics.
- **OPS-02**: TURN credentials use short-lived server-generated credentials instead of client-side static defaults.
- **OPS-03**: Deployment preflight checks validate env files, cert paths, Docker Compose config, and missing lockfiles before restart.

### Scale and Persistence

- **SCALE-01**: Room state can survive backend restarts or route users consistently through sticky room ownership.
- **SCALE-02**: SFU capacity limits and load-shedding behavior are defined for larger meetings.

## Out of Scope

Explicitly excluded from this milestone to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Full auth/session security overhaul | Important but separate from proving audio/video delivery |
| Room authorization and invitations | Requires product/data model decisions beyond the current media defect |
| Horizontal SFU scaling | Single-node media correctness must be proven first |
| Complete UI redesign | Existing meeting UI is sufficient for reliability debugging |
| Payment, email, analytics, or mobile apps | Not relevant to media connection stability |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DIAG-01 | Phase 1 | Pending |
| DIAG-02 | Phase 1 | Pending |
| DIAG-03 | Phase 1 | Pending |
| MEDIA-01 | Phase 1 | Pending |
| MEDIA-02 | Phase 1 | Pending |
| MEDIA-03 | Phase 1 | Pending |
| MEDIA-04 | Phase 1 | Pending |
| MEDIA-05 | Phase 1 | Pending |
| MEDIA-06 | Phase 1 | Pending |
| MULTI-01 | Phase 2 | Pending |
| MULTI-02 | Phase 2 | Pending |
| MULTI-03 | Phase 2 | Pending |
| MULTI-04 | Phase 2 | Pending |
| RES-01 | Phase 3 | Pending |
| RES-02 | Phase 3 | Pending |
| RES-03 | Phase 3 | Pending |
| VER-01 | Phase 1 | Pending |
| VER-02 | Phase 1 | Pending |
| VER-03 | Phase 3 | Pending |
| VER-04 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 20 total
- Mapped to phases: 20
- Unmapped: 0

## User Stories

- As a meeting participant, I can join a room with one other participant and see/hear them reliably.
- As a meeting participant, I can have another participant join after me without losing my own connection.
- As a developer, I can inspect the signaling and media flow enough to identify where missing remote media originates.
- As a maintainer, I can run repeatable checks that catch regressions in two-participant media delivery.

## Acceptance Criteria

- Two participants in the same room both receive remote video and audio tracks.
- The server logs or test instrumentation show incoming tracks are registered and forwarded to the intended peer connection.
- The client maps each remote stream to the correct participant ID.
- A two-participant verification path is automated or scripted, with manual browser steps documented if full automation is not feasible.

## Definition of Done

- Root cause is documented in the phase summary.
- Fix is implemented with targeted tests or smoke verification.
- `openmeet-client` and `openmeet-server` relevant checks pass or failures are documented with evidence.
- Manual two-participant browser verification passes.

---
*Requirements defined: 2026-06-19*
*Last updated: 2026-06-19 after initial definition*
