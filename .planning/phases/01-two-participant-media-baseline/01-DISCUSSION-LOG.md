# Phase 01: Two-Participant Media Baseline - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-27
**Phase:** 01-two-participant-media-baseline
**Areas discussed:** Reproduction target, User-visible failures, Verification proof

---

## Reproduction Target

| Option | Description | Selected |
|--------|-------------|----------|
| VPS first | Start from the real failing deployment at openmeets.eu, using browser UI plus VPS logs. | ✓ |
| Localhost first | Start locally for faster iteration and logs, then confirm on VPS after a suspected fix. | |
| Both in parallel | Use VPS to classify the production failure while local setup runs for code-level reproduction. | |
| You decide | Let the agent choose the safest path during execution. | |

**User's choice:** VPS first. Use SSH for read-only log inspection, let VPS behavior drive the fix if environments differ, and use a two-participant room as the primary reproduction case.
**Notes:** A third participant can be observed after two participants pass, but it is non-blocking Phase 2 signal.

---

## User-Visible Failures

| Option | Description | Selected |
|--------|-------------|----------|
| Show blocking dialog | Open the existing ConnectionErrorDialog for WebSocket close/reconnect exhaustion, peer failed, and unrecoverable ICE failure. | ✓ |
| Show inline banner | Keep participants on the call screen with a non-modal disconnected banner and retry/leave actions. | |
| Auto retry silently | Try reconnect first without interrupting, only show an error after retry exhaustion. | |
| You decide | Let the agent choose the least invasive UI behavior. | |

**User's choice:** Show a blocking dialog for terminal failures.
**Notes:** Treat peer failed and unexpected signaling close/reconnect exhaustion as user-visible terminal failures. Use plain recovery copy and safe structured diagnostics; do not expose secrets or internals in UI.

---

## Verification Proof

| Option | Description | Selected |
|--------|-------------|----------|
| VPS two-browser pass | Phase is not complete until two participants on openmeets.eu/room/1 can both see/hear each other and stay connected through the observed failure window. | ✓ |
| Local automated pass | Phase completion can be based on local Playwright/fake-media or equivalent automated checks, with VPS validation optional. | |
| Either VPS or local | Accept whichever environment provides reliable two-participant evidence first. | |
| You decide | Let the agent choose the strongest practical proof. | |

**User's choice:** VPS two-browser pass blocks completion.
**Notes:** Add best practical automated/scripted coverage. Capture UI result, server/client log markers, exact checks run, and non-blocking third-participant observation if attempted.

---

## the agent's Discretion

- Choose exact diagnostic log format and test placement.
- Choose the best practical mix of Playwright, Vitest, cargo tests, manual browser checks, and scripted smoke checks based on the proven root cause.

## Deferred Ideas

- Full 3-4 participant audio/video stability belongs to Phase 2 and should not block Phase 1.
