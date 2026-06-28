# Phase 01 Plan 01 Summary — Two-Participant Diagnostic Baseline

**Executed:** 2026-06-27
**Plan:** `.planning/phases/01-two-participant-media-baseline/01-01-PLAN.md`
**Status:** Completed; production-only human failure traced to deployment media networking gap

## Outcome

The focused two-participant browser smoke is now explicit and runnable. It passed locally and against the deployed room URL in fake-media Chromium, but user-run real-browser verification failed. VPS logs classify the real-browser failure at ICE/media networking for the second participant: the participant joins over WebSocket, receives existing participant metadata/renegotiation, but never reaches SFU-side ICE `Connected` and never publishes local audio/video tracks before disconnecting.

The root deployment mismatch found during follow-up debugging: production `openmeet_sfu` was not publishing the configured UDP media range, while the SFU advertises host candidates on `162.19.154.153:50xxx`. `docker ps` showed only `8081/tcp` for `openmeet_sfu`, and `docker-compose.yaml` lacked SFU UDP port mappings even though the development compose publishes them. The production compose now publishes `50000-50100:50000-50100/udp` for `openmeet_sfu`.

## Changes Made

- Updated `openmeet-client/e2e/multi-participant-media.spec.ts` with a focused test titled `two participants exchange remote audio and video`.
- Added support for targeting a specific deployed room through `PLAYWRIGHT_ROOM_URL` or `OPENMEET_ROOM_URL`.
- Added bounded browser diagnostic capture for tagged client logs only: `[SignalingService]`, `[WebRTCServiceSFU]`, and `[webrtcMachine]`.
- Filtered diagnostics to avoid SDP, ICE candidates, tokens, cookies, credentials, passwords, TURN URLs, bearer strings, and Vite env values.
- Strengthened remote media assertions so each remote rendered stream must contain live audio and video tracks.
- Added a second post-join media-flow assertion after an 8-second hold to cover the observed failure window.
- Kept existing 3+ participant tests unchanged; the new Phase 1 baseline is scoped to two participants only.
- Updated `docker-compose.yaml` so the production SFU publishes `50000-50100/udp`.

## Commands Run

### Local Two-Participant Smoke

Command:

```bash
yarn test:e2e --project=chromium --grep "two participants"
```

Working directory: `openmeet-client`

Result: passed in 11.4s.

Evidence:

- 1 Chromium test ran.
- `two participants exchange remote audio and video` passed.
- Both participants reached connected/stable WebRTC state and remote audio/video assertions passed.

### Deployed Two-Participant Smoke

Command:

```bash
PLAYWRIGHT_ROOM_URL="https://openmeets.eu/room/1" yarn test:e2e --project=chromium --grep "two participants"
```

Working directory: `openmeet-client`

Result: passed in 10.2s.

Evidence:

- 1 Chromium test ran against `https://openmeets.eu/room/1`.
- `two participants exchange remote audio and video` passed.
- No connection error dialog appeared during the observation window.
- Remote audio and video track assertions passed for both participants.

After tightening the smoke with an additional 8-second media-flow assertion, the same command passed in 23.2s. This confirms the fake-media Chromium path can work and does not reproduce the user's real-browser failure.

### VPS Read-Only SSH Attempt

Command:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=10 "debian@162.19.154.153" "hostname && docker ps --format '{{.Names}} {{.Status}}'"
```

Working directory: repository root.

Initial result from this harness: blocked.

Observed output:

```text
debian@162.19.154.153: Permission denied (publickey,password).
```

Interpretation:

- Non-interactive key-based SSH is not configured for this harness.
- The password was not placed in a command line, file, shell history snippet, or summary.
- Server/container log correlation required user-run interactive SSH output.

### User-Provided VPS Evidence

The user ran read-only commands on the VPS and provided redacted output.

Container state:

- `openmeet_sfu` was up and healthy.
- `openmeet_coturn` was up.
- `docker ps` showed `openmeet_sfu` exposing only `8081/tcp`, with no UDP media port mappings.

Firewall state:

- UFW allows `3478/tcp`, `3478/udp`, `5349/tcp`, `5349/udp`, and `49152:65535/udp`.
- Because `50000-50100/udp` is within `49152:65535/udp`, the host firewall is not the direct blocker for the SFU media range.

SFU log markers from the failing real-browser run:

- Participant `test` joined room `1`, reached `ICE connection state: Connected`, and published audio/video tracks.
- Participant `test2` joined room `1` and received renegotiation for existing tracks.
- Participant `test2` did not log `ICE connection state: Connected` before closing.
- Participant `test2` did not log `sent audio track` or `sent video track` before closing.
- The WebSocket closed after the failed join window.

CoTURN log markers:

- TURN allocations succeeded for user `<openmeets>`.
- Some sessions logged `CREATE_PERMISSION processed, error 403: Forbidden IP`, indicating TURN/private-address permission issues are also present and should be tracked if direct SFU UDP exposure is not sufficient.

Production compose fix made locally:

- `docker-compose.yaml` now maps `50000-50100:50000-50100/udp` on `openmeet_sfu`.

Local validation:

```bash
docker compose -f docker-compose.yaml config
```

Result: blocked locally because this checkout does not contain production `.env` files such as `openmeet-client/.env`. Compose reached interpolation/env-file loading, so no syntax-specific error was identified before the missing-env blocker.

### Public Server Health Checks

Requests:

- `https://sfu.openmeets.eu/health` returned `OK`.
- `https://sfu.openmeets.eu/metrics` returned `404`.

These checks confirm the public SFU health endpoint was reachable, but they do not replace container log correlation.

## Requirement Evidence

| Requirement | Evidence | Status |
|-------------|----------|--------|
| DIAG-01 | Real-browser VPS logs classify the failure before second participant publishes tracks: second participant joins but does not reach server-side ICE `Connected`; automation path passes. | Satisfied |
| DIAG-02 | Browser-side smoke captures bounded tagged diagnostics and verifies peer/ICE/signaling/media state. | Satisfied for smoke path |
| DIAG-03 | User-provided VPS logs show room membership, offer/answer, track registration for participant 1, existing-track renegotiation to participant 2, TURN activity, and WebSocket close. | Satisfied |
| VER-01 | Focused Playwright regression path exists and passed locally. | Satisfied |
| VER-02 | Browser-equivalent deployed smoke passed against `https://openmeets.eu/room/1`. | Satisfied for automation |

## DIAG-03 Checkpoint Status

| Server Checkpoint | Observed? | Notes |
|-------------------|-----------|-------|
| Room membership | Yes | Both participants joined room `1`; participant count reached 2. |
| Offer/answer handling | Yes | Initial offer/answer and renegotiation answer logs are present. |
| ICE candidate handling | Yes | ICE candidate add/gather logs are present; participant 2 fails before connected in the human run. |
| Incoming track registration | Partial | Participant 1 audio/video tracks registered; participant 2 never published tracks before disconnect. |
| Forwarding target selection | Yes | Server logged existing tracks sent to participant 2 via renegotiation. |
| RTP forwarding | Partial | Existing participant-to-late-joiner forwarding logs exist; participant 2-to-participant 1 cannot start because participant 2 never publishes tracks. |
| RTCP feedback | Yes | RTCP handler shutdown logs are present after disconnect. |

## Failure Classification

The automated fake-media path passes through:

- browser room join,
- local media capture with fake camera/microphone,
- WebSocket signaling,
- SDP/ICE connection establishment,
- remote stream attachment,
- live remote audio and video tracks,
- increasing inbound/outbound RTP packet counters.

The real-browser production path fails earlier for participant 2:

- participant 2 joins the room over WebSocket,
- server prepares existing tracks for participant 2,
- participant 2 does not reach server-side ICE `Connected`,
- server never receives participant 2's audio/video tracks,
- WebSocket closes silently from the user's perspective.

Root cause classification: deployment media networking, specifically missing SFU UDP port publication for advertised host candidates, with secondary TURN/private-address permission warnings to watch after redeploy.

## Security Notes

- No SSH password or credential value was written to repository files.
- Browser diagnostics filter out SDP, ICE candidates, tokens, cookies, credentials, passwords, TURN URLs, bearer strings, and Vite env values.
- VPS commands were read-only and did not execute because authentication required password interaction.
- No VPS files, deployment config, environment files, or containers were modified.

## Fix Applied In Repository

- `docker-compose.yaml` now publishes the SFU media UDP range: `50000-50100:50000-50100/udp`.
- This matches the server's production candidate range seen in logs (`162.19.154.153:50xxx`) and the development compose pattern.
- No TURN credentials, auth behavior, CORS behavior, room authorization, or token handling changed.

## Non-Blocking Third Participant Observation

Skipped per D-11. This plan focused only on the two-participant baseline.

## Next Step

Deploy the `docker-compose.yaml` change to the VPS and recreate `openmeet_sfu`, then rerun the two-human-browser verification on `https://openmeets.eu/room/1`. If participant 2 still fails to connect, inspect `openmeet_coturn` for continued `403: Forbidden IP` entries during the fresh attempt and fix TURN private-peer handling next.

After media connectivity is fixed or while it is being deployed, proceed to `.planning/phases/01-two-participant-media-baseline/01-02-PLAN.md` to make terminal disconnects visible through the existing connection error dialog.
