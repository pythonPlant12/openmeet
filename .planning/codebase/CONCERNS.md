---
doc_type: codebase-map
focus: concerns
analysis_date: 2026-06-19
scope: full repo
status: current
---

# Codebase Concerns

**Analysis Date:** 2026-06-19

## Tech Debt

**Large SFU modules own too many responsibilities:**
- Issue: `openmeet-server/src/sfu/room.rs` is 770 lines and handles room state, participant lifecycle, RTP fan-out, NACK/PLI handling, late-joiner subscription, packet buffering integration, and memory logging in one type. `openmeet-server/src/signaling/handler.rs` is 747 lines and handles WebSocket lifecycle, room creation, env-derived ICE config, signaling message dispatch, renegotiation, chat, media-state sync, and cleanup in one file.
- Files: `openmeet-server/src/sfu/room.rs`, `openmeet-server/src/signaling/handler.rs`
- Impact: Changes to negotiation, cleanup, chat, or metrics share lock scopes and task-spawning code, increasing regression risk and making targeted tests difficult.
- Fix approach: Split by responsibility: keep `Room` as state container, move RTP forwarding into `openmeet-server/src/sfu/forwarding.rs`, RTCP feedback into `openmeet-server/src/sfu/rtcp.rs`, and signaling handlers into per-message modules under `openmeet-server/src/signaling/`.

**Authentication and XState type safety is weakened:**
- Issue: Auth state actions cast XState events with `(event as any)`, and composables inject actors as `any`.
- Files: `openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/composables/useAuth.ts`, `openmeet-client/src/composables/useWebrtc.ts`, `openmeet-client/eslint.config.ts`
- Impact: Event payload shape changes can compile while breaking token persistence, session validation, or UI state at runtime.
- Fix approach: Define typed actor output events for `loginActor`, `registerActor`, `checkSessionActor`, and `refreshTokenActor`; type Vue injection keys instead of `inject<any>`; re-enable `@typescript-eslint/no-explicit-any` after replacing known occurrences.

**Module-level singleton services make WebRTC lifecycle fragile:**
- Issue: `signalingService` and `webrtcService` are module-level mutable variables outside XState context.
- Files: `openmeet-client/src/xstate/machines/webrtc/actors.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`
- Impact: Multiple meeting tabs, rapid retries, hot reload, or partial cleanup can leave stale handlers and service instances shared across sessions.
- Fix approach: Keep service instances in an explicit actor/session owner, register handlers with cleanup via `off()`, and make `joinRoomActor` cleanup unregister every handler it adds.

**Deployment scripts and Dockerfiles are drift-prone:**
- Issue: Server Dockerfile copies `Cargo.lock`, but `openmeet-server/Cargo.lock` is not present. Production compose expects `openmeet-client/.env`, `openmeet-server/.env`, and root `.env`, while the repo contains example files plus a suspicious env-like file name in `openmeet-client/`.
- Files: `openmeet-server/Dockerfile`, `docker-compose.yaml`, `deploy.sh`, `openmeet-client/.env 21-59-59-312`
- Impact: Production builds can fail before compilation, deployments depend on manually synchronized env files, and env-file naming mistakes can leak or break configuration.
- Fix approach: Commit `openmeet-server/Cargo.lock` for reproducible application builds, add a non-secret env validation script, and reject unexpected `.env*` filenames in CI without reading contents.

**Client package metadata is misleading:**
- Issue: The client package is named `xstate` despite being the OpenMeet frontend.
- Files: `openmeet-client/package.json`
- Impact: Logs, package-manager output, audit reports, and dependency tooling identify the app incorrectly.
- Fix approach: Rename the package to an application-specific private name such as `openmeet-client`.

## Known Bugs

**Server build can fail because the lockfile is missing:**
- Symptoms: `docker build` for the SFU reaches `COPY Cargo.toml Cargo.lock ./` and fails when `Cargo.lock` is absent.
- Files: `openmeet-server/Dockerfile`, `openmeet-server/Cargo.toml`
- Trigger: Run the production server image build from `docker-compose.yaml`.
- Workaround: Generate and commit `openmeet-server/Cargo.lock`, or change the Dockerfile only if this crate is intentionally treated as a library.

**Unprotected meeting rooms can be joined by anyone with a room URL:**
- Symptoms: `/room/:id` is marked public and `/ws` accepts joins without an authenticated user or room authorization check.
- Files: `openmeet-client/src/router/index.ts`, `openmeet-server/src/main.rs`, `openmeet-server/src/signaling/handler.rs`
- Trigger: Open any known room URL and send a `join` WebSocket message.
- Workaround: None in code; room privacy relies on obscurity of room IDs.

**Reconnects do not rejoin rooms or reattach message handlers deterministically:**
- Symptoms: `SignalingService` reconnects the raw WebSocket, but room join, WebRTC offer creation, and XState state recovery are not re-run as a single reconnection transaction.
- Files: `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`
- Trigger: Network drop while in a meeting.
- Workaround: Leave and rejoin the room from the UI.

**Unread chat count can be overwritten instead of accumulated:**
- Symptoms: The watcher assigns `unreadCount` to the number of unread messages in the latest slice rather than adding to existing unread count.
- Files: `openmeet-client/src/pages/MeetingPage.vue`
- Trigger: Receive messages in multiple batches while the chat panel is closed.
- Workaround: Open and close the chat panel to reset the read index.

## Security Considerations

**CORS is fully open on the SFU/API server:**
- Risk: Any origin can call auth endpoints and open WebSocket/API requests in browser contexts.
- Files: `openmeet-server/src/main.rs`
- Current mitigation: JWT validation is required for `/auth/me`, but `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/logout`, and `/ws` are reachable cross-origin.
- Recommendations: Restrict CORS origins to configured frontend domains, keep development `Any` behind an explicit dev flag, and add origin checks for WebSocket upgrades.

**Tokens are stored in JavaScript-readable cookies without security attributes:**
- Risk: XSS can read access and refresh tokens, and cookies are set without `Secure`, `SameSite`, or explicit encoding.
- Files: `openmeet-client/src/utils.ts`, `openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/App.vue`
- Current mitigation: Access tokens are short-lived; refresh tokens are random and hashed server-side before DB storage.
- Recommendations: Move refresh tokens to server-set `HttpOnly; Secure; SameSite=Lax/Strict` cookies, encode cookie values, and keep access tokens in memory where possible.

**Refresh token implementation does not rotate tokens:**
- Risk: A stolen refresh token remains valid until logout or expiration because refresh returns only a new access token and leaves the existing refresh token active.
- Files: `openmeet-server/src/auth/handlers.rs`, `openmeet-server/src/auth/jwt.rs`, `openmeet-server/migrations/20251201000001_create_refresh_tokens/up.sql`
- Current mitigation: Refresh tokens are hashed in the database and can be deleted on logout.
- Recommendations: Rotate refresh tokens on every `/auth/refresh`, store token family/session metadata, revoke reused tokens, and delete expired rows in a scheduled cleanup.

**Input validation is minimal for auth, chat, and room joins:**
- Risk: Oversized names/messages, malformed emails, weak passwords, and arbitrary room IDs can be accepted and stored/broadcast.
- Files: `openmeet-server/src/auth/models.rs`, `openmeet-server/src/auth/handlers.rs`, `openmeet-server/src/signaling/message.rs`, `openmeet-server/src/signaling/handler.rs`
- Current mitigation: Database column sizes constrain `users.email`, `users.name`, and `users.password_hash`; JSON deserialization enforces field presence.
- Recommendations: Add request validators for email/password/name lengths, chat message length, room ID format, and per-connection message size/rate limits.

**Operational dashboards and host metrics are exposed broadly by compose defaults:**
- Risk: Grafana, Prometheus, Loki, cAdvisor, node-exporter, and Promtail ports are published; Grafana compose config uses default admin credentials; Promtail has Docker socket access and privileged mode.
- Files: `docker-compose.yaml`, `docker-compose.dev.yml`, `deployment/nginx/nginx.conf`, `observability/promtail-config.yaml`, `observability/prometheus.yaml`
- Current mitigation: Some services are only on the Docker network in production, but several ports are still published directly.
- Recommendations: Bind observability ports to localhost/VPN, remove default Grafana credentials, put Grafana behind auth, remove unnecessary privileged flags, and avoid exposing Docker socket unless required.

**TURN credentials are present in client-side build configuration and defaults:**
- Risk: Long-lived TURN credentials in browser bundles can be reused by third parties for relay abuse.
- Files: `openmeet-client/src/services/webrtc-sfu.ts`, `docker-compose.dev.yml`, `deployment/coturn/turnserver.conf.template`
- Current mitigation: Production can override via environment variables.
- Recommendations: Use short-lived TURN REST credentials generated server-side; remove fallback credentials from client code; keep development credentials explicitly scoped to local-only docs/config.

**Error responses can expose internal server details:**
- Risk: Diesel, Argon2, pool, and JWT errors are returned with `e.to_string()` in HTTP responses.
- Files: `openmeet-server/src/auth/handlers.rs`, `openmeet-server/src/db/mod.rs`
- Current mitigation: Login credential failures use generic `Invalid credentials`.
- Recommendations: Return stable public error messages and log detailed errors server-side with request IDs.

## Performance Bottlenecks

**RTP forwarding scales as per-track-per-receiver tasks and buffers:**
- Problem: Each forwarded track creates writer and RTCP tasks per receiver plus a `RtpPacketBuffer` of cloned RTP packets.
- Files: `openmeet-server/src/sfu/room.rs`, `openmeet-server/src/sfu/packet_buffer.rs`
- Cause: Fan-out is implemented with `tokio::spawn` for each current and late-join receiver, and `RTP_BROADCAST_CAPACITY` plus `BUFFER_SIZE` are fixed constants.
- Improvement path: Add room participant limits, load-shed on lagging receivers, expose per-room task/buffer metrics, and benchmark N participants x M tracks before raising capacity.

**Room write locks are held while creating WebRTC forwarding resources:**
- Problem: The room write lock can be held while handling incoming tracks and forwarding to participants.
- Files: `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/sfu/room.rs`
- Cause: `room.handle_incoming_track(...).await` is invoked while a write lock is held, and `forward_track_to_others()` awaits peer-connection operations.
- Improvement path: Snapshot participant targets under lock, release the room lock, perform WebRTC operations, then re-acquire a narrow lock only for state updates.

**Memory logging uses process refresh calls in participant lifecycle paths:**
- Problem: Every participant add/remove refreshes process info and logs memory.
- Files: `openmeet-server/src/sfu/room.rs`
- Cause: `log_memory_usage()` calls `System::new()` and `refresh_processes()` synchronously in hot lifecycle paths.
- Improvement path: Replace ad hoc memory logging with periodic metrics or debug-only sampling.

**Verbose frontend and backend logging is in hot media paths:**
- Problem: Browser `console.log()` calls and Rust `info!()` calls run in signaling, media, and packet-forwarding paths.
- Files: `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`, `openmeet-server/src/sfu/room.rs`, `openmeet-server/src/signaling/handler.rs`
- Cause: Debug logging remains in production code paths.
- Improvement path: Gate logs behind debug flags, downgrade packet/media logs to trace/debug, and strip client debug logs for production builds.

## Fragile Areas

**WebRTC renegotiation and late-joiner flow:**
- Files: `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/sfu/room.rs`, `openmeet-server/src/sfu/peer_connection.rs`, `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`
- Why fragile: Tracks are marked negotiated immediately after offer creation in some paths, collision handling relies on later answers, and fallback stream assignment guesses the first participant without a stream.
- Safe modification: Add integration tests around two-user and late-join three-user flows before changing offer/answer sequencing; assert stream-owner mapping before assigning remote streams.
- Test coverage: Server unit tests cover repository and peer-connection basics only; client tests focus on auth, not multi-party WebRTC negotiation.

**WebSocket cleanup and task cancellation:**
- Files: `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/sfu/room.rs`, `openmeet-server/src/sfu/participant.rs`
- Why fragile: Send/receive tasks are aborted, RTP reader/writer/RTCP tasks depend on broadcast closure and shutdown receivers, and failed sends are often ignored with `let _ =`.
- Safe modification: Add structured task ownership per participant, explicit cancellation tokens, and tests that assert room/track cleanup after disconnect.
- Test coverage: No disconnect cleanup tests were detected for WebSocket/SFU paths.

**Auth/session behavior crosses cookies, router guards, and XState:**
- Files: `openmeet-client/src/utils.ts`, `openmeet-client/src/router/index.ts`, `openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/services/auth-api.ts`
- Why fragile: Router guards trust refresh-token existence while XState validates via backend later; token refresh in `authApi.me()` can update only access token; cookies are managed from multiple places.
- Safe modification: Centralize session state transitions in the auth machine and make router guards wait on machine state rather than parsing cookies directly.
- Test coverage: Auth unit tests exist, but browser cookie/security attributes and router refresh-token edge cases need coverage.

**Deployment relies on host state and nested paths:**
- Files: `deploy.sh`, `docker-compose.yaml`, `.github/workflows/deploy.yml`, `deployment/nginx/nginx.conf`
- Why fragile: Deployment sources `.env`, uses `sudo docker`, stores certbot material under `openmeet/certbot/...`, and hard-codes production domains in Nginx.
- Safe modification: Add preflight checks for directories, certificates, DNS domains, env keys, Docker Compose version, and missing lockfiles before `docker compose down`.
- Test coverage: No deploy dry-run or compose validation workflow was detected.

## Scaling Limits

**In-memory rooms prevent horizontal scaling and restart recovery:**
- Current capacity: One process owns all rooms in memory via a `HashMap<String, Arc<RwLock<Room>>>`.
- Limit: Rooms and participants disappear on restart; multiple SFU replicas cannot share room state or route participants into the same room.
- Scaling path: Introduce sticky routing per room or a room coordinator, persist room/session metadata, and document single-SFU limits.
- Files: `openmeet-server/src/sfu/repository.rs`, `openmeet-server/src/main.rs`

**UDP media port range is narrow in development and optional in production:**
- Current capacity: Development maps a small UDP range, production depends on env-provided UDP range or OS ephemeral ports.
- Limit: More concurrent peer connections can exhaust the configured range or fail firewall traversal.
- Scaling path: Document port-per-peer expectations, validate `UDP_PORT_MIN/MAX`, and size firewall rules for expected concurrency.
- Files: `docker-compose.dev.yml`, `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/sfu/peer_connection.rs`

**Database connection pool has implicit sizing:**
- Current capacity: Pool construction uses `AsyncDieselConnectionManager` defaults.
- Limit: Auth traffic can block or fail under bursts without explicit max size, timeout, or metrics.
- Scaling path: Configure pool size/timeouts from env and expose pool metrics.
- Files: `openmeet-server/src/db/mod.rs`, `openmeet-server/src/auth/handlers.rs`

## Dependencies at Risk

**Rust dependencies are not locked:**
- Risk: Without `openmeet-server/Cargo.lock`, builds can resolve different transitive versions over time.
- Impact: SFU, TLS, JWT, and Diesel behavior can change without a source diff.
- Migration plan: Generate and commit `openmeet-server/Cargo.lock`; run `cargo update` intentionally in dependency maintenance PRs.
- Files: `openmeet-server/Cargo.toml`, `openmeet-server/Dockerfile`

**Floating container image tags reduce reproducibility:**
- Risk: `latest` tags and `rust:latest` in dev can change behavior unexpectedly.
- Impact: CI/dev/prod parity can break due to image updates outside repository control.
- Migration plan: Pin image versions/digests for `coturn`, Grafana stack, Rust dev image, and certbot; schedule controlled upgrades.
- Files: `docker-compose.yaml`, `docker-compose.dev.yml`

**Client production build installs dependencies without frozen lock enforcement:**
- Risk: Docker build uses `yarn install` without `--frozen-lockfile`/immutable mode.
- Impact: Image builds can drift from `openmeet-client/yarn.lock`.
- Migration plan: Use `yarn install --frozen-lockfile` or the Yarn version-appropriate immutable install flag in `openmeet-client/Dockerfile`.
- Files: `openmeet-client/Dockerfile`, `openmeet-client/yarn.lock`

**Vite uses an alias to latest Rolldown Vite:**
- Risk: `vite` is declared as `npm:rolldown-vite@latest`, which can change on every install.
- Impact: Build and dev-server behavior can change without lockfile updates if installs are not immutable.
- Migration plan: Pin an explicit Rolldown Vite version or return to stable Vite for production builds.
- Files: `openmeet-client/package.json`, `openmeet-client/yarn.lock`

## Missing Critical Features

**Room authorization and ownership:**
- Problem: There is no server-side model for room owners, invitations, participant authorization, or room ACLs.
- Blocks: Private meetings, abuse prevention, auditability, and authenticated room membership.
- Files: `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/auth/handlers.rs`, `openmeet-server/migrations/`

**Rate limiting and abuse controls:**
- Problem: Auth endpoints, WebSocket joins, chat messages, and signaling messages have no rate limits.
- Blocks: Safe public deployment against brute force login, room spam, and resource-exhaustion attacks.
- Files: `openmeet-server/src/main.rs`, `openmeet-server/src/auth/handlers.rs`, `openmeet-server/src/signaling/handler.rs`

**Server-side request/body limits:**
- Problem: The API and WebSocket message parsing do not define explicit payload size limits in app code.
- Blocks: Predictable memory usage under malformed or oversized messages.
- Files: `openmeet-server/src/main.rs`, `openmeet-server/src/signaling/handler.rs`

**Automated E2E coverage is configured but no E2E tests are present:**
- Problem: Playwright config points to `openmeet-client/e2e`, but no E2E files were detected.
- Blocks: Regression detection for login, meeting join, device permissions, WebSocket connection, and chat flows.
- Files: `openmeet-client/playwright.config.ts`, `openmeet-client/package.json`

## Test Coverage Gaps

**SFU media negotiation and cleanup:**
- What's not tested: Offer/answer collision handling, late joiner renegotiation, RTP forwarding, NACK retransmission, PLI forwarding, and disconnect cleanup.
- Files: `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/sfu/room.rs`, `openmeet-server/src/sfu/packet_buffer.rs`, `openmeet-server/src/sfu/peer_connection.rs`
- Risk: Multi-party media can fail while unit tests pass.
- Priority: High

**Auth backend edge cases:**
- What's not tested: Duplicate registration behavior, refresh expiry cleanup, refresh-token replay, logout invalidation, malformed Authorization headers, and database failures.
- Files: `openmeet-server/src/auth/handlers.rs`, `openmeet-server/src/auth/jwt.rs`, `openmeet-server/migrations/20251201000001_create_refresh_tokens/up.sql`
- Risk: Session security regressions can reach production unnoticed.
- Priority: High

**Deployment and migration safety:**
- What's not tested: Compose config validity, Docker image build with missing files, migration rollback, certbot path availability, and production env completeness.
- Files: `docker-compose.yaml`, `deploy.sh`, `.github/workflows/deploy.yml`, `openmeet-server/migrations/`
- Risk: Deployment can fail after CI passes build/test workflows.
- Priority: High

**Frontend meeting flows:**
- What's not tested: Join dialog device selection, reconnect behavior, chat unread counts, media toggle synchronization, and connection error recovery.
- Files: `openmeet-client/src/pages/MeetingPage.vue`, `openmeet-client/src/components/meeting-page/JoinMeetingDialog.vue`, `openmeet-client/src/xstate/machines/webrtc/index.ts`, `openmeet-client/src/services/signaling.ts`
- Risk: Core meeting UX can regress without automated detection.
- Priority: Medium

**Lint suppressions and skipped tests:**
- What's not tested: No skipped tests were detected, but `@typescript-eslint/no-explicit-any` is disabled globally and Clippy is commented out in CI.
- Files: `openmeet-client/eslint.config.ts`, `.github/workflows/test.yml`
- Risk: Type-safety and Rust quality regressions can accumulate despite green CI.
- Priority: Medium

## Incomplete Docs / Config

**Environment documentation is fragmented:**
- Issue: Root, client, and server env files are required, but validation and single-source documentation are not enforced.
- Files: `.env.example`, `openmeet-client/.env.example`, `openmeet-server/.env.example`, `deploy.sh`, `docker-compose.yaml`
- Impact: Missing or stale env values fail at runtime via `expect()` or service misconfiguration.
- Fix approach: Add `scripts/check-env` that validates required keys without printing values, and run it before deploy.

**CI quality gates omit important checks:**
- Issue: Server Clippy is commented out, E2E tests are not run in workflows, and deployment health check allows failure with `|| echo`.
- Files: `.github/workflows/test.yml`, `.github/workflows/build.yml`, `.github/workflows/deploy.yml`, `openmeet-client/playwright.config.ts`
- Impact: Code quality, browser flow, and deployment failures can pass automation.
- Fix approach: Enable `cargo clippy -- -D warnings`, add `yarn test:e2e` when E2E tests exist, and make production health check fail the deployment job.

---

*Concerns audit: 2026-06-19*
