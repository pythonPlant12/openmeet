# OpenMeet Multi-Participant Media Stability

## What This Is

OpenMeet is an existing browser-based video meeting application with a Vue 3 client and a Rust Axum/WebRTC SFU backend. This project focuses on debugging and stabilizing the meeting connection flow so participants reliably connect and receive remote audio/video streams.

The immediate goal is not to redesign the product. It is to make the existing meeting experience dependable when two or more participants join the same room.

## Core Value

Participants in the same OpenMeet room can maintain stable, bidirectional audio/video without missing remote media streams.

## Requirements

### Validated

- ✓ Browser SPA exists for landing, auth, dashboard, room entry, meeting UI, controls, chat, and video grid — existing
- ✓ Rust Axum backend exists for auth, WebSocket signaling, health, metrics, and SFU media routing — existing
- ✓ WebRTC/SFU architecture exists with browser `RTCPeerConnection`, server-side peer connections, RTP forwarding, RTCP feedback, and STUN/TURN configuration — existing
- ✓ PostgreSQL-backed user and refresh-token auth exists — existing
- ✓ Docker Compose, NGINX, Coturn, Prometheus, Grafana, Loki, Promtail, and GitHub Actions scaffolding exist — existing

### Active

- [ ] Prove two participants in one room can connect and receive each other's audio and video reliably.
- [ ] Identify the root cause of missing or unstable media packets in the current signaling/SFU flow.
- [ ] Fix offer/answer, ICE, stream ownership, RTP forwarding, or renegotiation defects that prevent remote media delivery.
- [ ] Add targeted regression coverage for two-participant media flow and the specific failure mode found.
- [ ] Extend verification to late joiners and 3+ participant behavior after the two-user baseline is stable.
- [ ] Document the corrected connection flow and operational verification steps.

### Out of Scope

- Room authorization, invitations, ownership, and ACLs — important security work, but not required to prove media stability.
- Horizontal SFU scaling or room persistence across backend restarts — larger architecture work after single-node media correctness is proven.
- Authentication token hardening, CORS lockdown, and refresh-token rotation — known concerns, but separate from the immediate media-flow failure.
- Full UI redesign — only meeting UI changes required to expose or verify connection state should be included.
- Hosted error tracking, analytics, payments, email, SMS, or mobile apps — unrelated to the current reliability goal.

## Context

The codebase map shows a split frontend/backend architecture. The client meeting flow lives mainly in `openmeet-client/src/pages/MeetingPage.vue`, `openmeet-client/src/xstate/machines/webrtc/index.ts`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`, `openmeet-client/src/services/signaling.ts`, and `openmeet-client/src/services/webrtc-sfu.ts`.

The server meeting flow lives mainly in `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/signaling/message.rs`, and `openmeet-server/src/sfu/`. The SFU path registers incoming tracks, broadcasts RTP packets, forwards to other participants, handles RTCP feedback, and sends renegotiation offers for late joiners.

Known fragile areas from `.planning/codebase/CONCERNS.md` are directly relevant: WebRTC renegotiation and late-joiner flow, module-level singleton client services, room write locks held while creating forwarding resources, WebSocket cleanup/task cancellation, missing multi-party media tests, and fallback stream assignment that guesses stream ownership.

The user reported that connecting two or more participants does not reliably deliver video/audio packets to both participants. The project should therefore be treated as a debugging and stabilization effort: reproduce the failure, instrument the connection flow, fix the root cause, and verify with real two-participant and multi-participant behavior.

## Constraints

- **Tech stack**: Preserve Vue 3, TypeScript, XState, Rust, Axum, WebRTC crate, Diesel, PostgreSQL, Docker Compose, and existing SFU architecture unless a concrete defect requires a targeted change.
- **Brownfield safety**: Read and preserve existing code patterns from `.planning/codebase/` before modifying signaling, SFU, or WebRTC client files.
- **Verification**: A fix is not complete until two browser participants in the same room receive each other's audio/video streams and automated checks cover the corrected path where feasible.
- **Scope**: Start with the smallest stable two-user flow before widening to late joiners and 3+ participant cases.
- **Security**: Do not introduce new token, CORS, room-join, or TURN credential exposure while debugging media flow.
- **Concurrency**: Avoid holding long-lived room locks across async WebRTC operations when fixing server forwarding behavior.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Treat this as a brownfield reliability project | The app already exists and has a codebase map; the user wants the current meeting flow fixed, not a new product | — Pending |
| Phase 1 proves stable two-participant bidirectional A/V | The user selected the smallest reliable proof before expanding to larger rooms | — Pending |
| Use YOLO mode with parallel execution | The user wants the agent to investigate, fix, debug, and verify without repeated approvals | — Pending |
| Keep full PR body sections enabled | Acceptance criteria, risks, release checks, and approval traceability should be preserved for reliability work | — Pending |
| Use vertical MVP phase structure | Each phase should deliver observable meeting reliability, not isolated horizontal refactors | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? -> Move to Out of Scope with reason
2. Requirements validated? -> Move to Validated with phase reference
3. New requirements emerged? -> Add to Active
4. Decisions to log? -> Add to Key Decisions
5. "What This Is" still accurate? -> Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check -> still the right priority?
3. Audit Out of Scope -> reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-19 after initialization*
