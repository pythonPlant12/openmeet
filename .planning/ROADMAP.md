# Roadmap: OpenMeet Multi-Participant Media Stability

**Created:** 2026-06-19
**Mode:** Brownfield reliability roadmap
**Project:** OpenMeet Multi-Participant Media Stability

## Overview

This roadmap stabilizes the existing OpenMeet meeting flow in vertical reliability slices. Phase 1 proves the smallest valuable outcome: two participants in the same room can reliably exchange audio/video. Later phases extend the same corrected flow to late joiners, three or more participants, cleanup, and regression-proof verification.

## Phases

### Phase 1: Two-Participant Media Baseline
**Goal:** Reproduce the current failure, identify the root cause, and make two participants reliably receive each other's audio/video.
**Mode:** mvp
**Requirements:** DIAG-01, DIAG-02, DIAG-03, MEDIA-01, MEDIA-02, MEDIA-03, MEDIA-04, MEDIA-05, MEDIA-06, VER-01, VER-02
**Plans:** 5 plans
Plans:
- [ ] 01-01-PLAN.md — Reproduce/classify deployed two-participant failure and create browser smoke baseline
- [ ] 01-02-PLAN.md — Surface terminal disconnects through the existing connection error dialog
- [ ] 01-03-PLAN.md — Make client stream ownership deterministic and test-covered
- [ ] 01-04-PLAN.md — Fix server RTP forwarding lock scope and preserve SFU architecture
- [ ] 01-05-PLAN.md — Run final automated, VPS, and human two-browser verification
**UI hint:** yes
**Success Criteria**:
1. A two-participant room join can be reproduced or simulated with enough instrumentation to locate the failing layer.
2. Both participants complete signaling, SDP, ICE, and server-side track registration.
3. Each participant receives and renders the other participant's video stream.
4. Each participant receives the other participant's audio track.
5. A targeted regression test or scripted smoke check covers the corrected two-participant path.

### Phase 2: Late Joiner and 3+ Participant Stability
**Goal:** Extend the fixed media path so third and later participants receive existing streams and existing participants receive late joiner streams.
**Mode:** mvp
**Requirements:** MULTI-01, MULTI-02, MULTI-03, MULTI-04
**Depends on:** Phase 1
**UI hint:** yes
**Success Criteria**:
1. A third participant can join after two participants are already connected.
2. Existing participants receive the late joiner's remote audio/video after renegotiation.
3. The late joiner receives existing participants' audio/video after renegotiation.
4. Negotiated track state, stream owner messages, and offer/answer sequencing remain consistent for sequential joins.

### Phase 3: Session Resilience, Cleanup, and Verification Documentation
**Goal:** Make the corrected flow resilient to participant leave/rejoin behavior and document repeatable verification for future maintenance.
**Mode:** mvp
**Requirements:** RES-01, RES-02, RES-03, VER-03, VER-04
**Depends on:** Phase 1, Phase 2
**UI hint:** yes
**Success Criteria**:
1. Participant disconnect removes server room state, forwarding tasks, local tracks, and client handlers without breaking remaining participants.
2. Participant leave/rejoin does not create duplicate client handlers or stale service instances.
3. Media toggles do not disrupt established remote media delivery.
4. Corrected connection flow and manual verification steps are documented.
5. Relevant client and server quality gates pass or have documented, actionable failures.

## Requirement Coverage

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

## Planning Notes

- Phase 1 should read `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/CONCERNS.md`, `.planning/codebase/TESTING.md`, and all files in the current meeting flow before editing.
- Start from the smallest observable failure: two browser participants in one room.
- Prefer targeted fixes over broad SFU rewrites.
- Verification should include real browser behavior if possible because missing remote tracks may not be caught by pure unit tests.
- Known risky files include `openmeet-client/src/xstate/machines/webrtc/actors.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`, `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/services/signaling.ts`, `openmeet-server/src/signaling/handler.rs`, and `openmeet-server/src/sfu/room.rs`.

---
*Roadmap created: 2026-06-19*
