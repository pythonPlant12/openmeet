---
doc_type: codebase-map
focus: tech
generated_at: 2026-06-19
source_scope: full repo
---

# External Integrations

**Analysis Date:** 2026-06-19

## APIs & External Services

**Internal HTTP API:**
- Rust Axum API - handles health checks, authentication, metrics, and WebSocket upgrade.
  - Implementation: `openmeet-server/src/main.rs`, `openmeet-server/src/auth/routes.rs`, `openmeet-server/src/auth/handlers.rs`.
  - Client: `openmeet-client/src/services/auth-api.ts` uses `fetch` against `VITE_API_URL` with a local fallback.
  - Routes: `/health`, `/metrics`, `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/me`, `/ws`.

**Realtime Signaling:**
- WebSocket signaling - client connects to the Rust SFU WebSocket endpoint for room join, SDP offers/answers, ICE candidates, media-state events, and chat messages.
  - Server: `openmeet-server/src/signaling/handler.rs`.
  - Client: `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`.
  - URL configuration: `VITE_SFU_WSS_URL` in client code; reverse-proxied by `deployment/nginx/nginx.conf` at `sfu.openmeets.eu/ws`.

**WebRTC / NAT Traversal:**
- Google public STUN - default client ICE server includes `stun1.l.google.com:19302` and `stun2.l.google.com:19302` in `openmeet-client/src/services/webrtc-sfu.ts`; server supports custom `STUN_URL` in `openmeet-server/src/signaling/handler.rs`.
- Coturn TURN relay - containerized in `docker-compose.dev.yml` and `docker-compose.yaml` and consumed through `TURN_URL`, `TURN_USER`, and `TURN_PASSWORD` in `openmeet-server/src/signaling/handler.rs` plus `VITE_TURN_URL`, `VITE_TURN_USER`, and `VITE_TURN_PASSWORD` in `openmeet-client/src/services/webrtc-sfu.ts`.
- UDP port range - optional SFU UDP ports are configured with `UDP_PORT_MIN` and `UDP_PORT_MAX` in `openmeet-server/src/signaling/handler.rs`.

**Browser Platform APIs:**
- Media capture - `navigator.mediaDevices.getUserMedia` is used for camera/microphone capture in `openmeet-client/src/services/webrtc-sfu.ts`.
- RTCPeerConnection - browser WebRTC peer connections are created in `openmeet-client/src/services/webrtc-sfu.ts`.
- WebSocket - browser WebSocket client is wrapped by `openmeet-client/src/services/signaling.ts`.

**External SDKs Not Actively Wired:**
- Firebase - dependency declared in `openmeet-client/package.json`, but no imports detected under `openmeet-client/src`; do not rely on Firebase auth/firestore/storage until integration code is added.

## Data Storage

**Databases:**
- PostgreSQL - authoritative persistent storage for users and refresh tokens.
  - Container: `postgres:16-alpine` in `docker-compose.dev.yml` and `docker-compose.yaml`.
  - Connection: `DATABASE_URL` consumed by `openmeet-server/src/main.rs` and `openmeet-server/src/db/mod.rs`.
  - Client/ORM: Diesel and Diesel Async configured in `openmeet-server/Cargo.toml` and `openmeet-server/diesel.toml`.
  - Migrations: `openmeet-server/migrations/20251201000000_create_users/up.sql` creates `users`; `openmeet-server/migrations/20251201000001_create_refresh_tokens/up.sql` creates `refresh_tokens`.
  - Schema: generated Diesel schema in `openmeet-server/src/schema.rs`.

**In-Memory State:**
- SFU room state is in memory through `InMemoryRoomRepository` initialized in `openmeet-server/src/main.rs` and implemented under `openmeet-server/src/sfu/repository.rs`.
- WebRTC service instances are module-level browser state in `openmeet-client/src/xstate/machines/webrtc/actors.ts`.

**File Storage:**
- Local filesystem and container volumes only.
  - PostgreSQL data volume in `docker-compose.dev.yml` and `docker-compose.yaml`.
  - Prometheus and Grafana volumes in `docker-compose.dev.yml` and `docker-compose.yaml`.
  - Let's Encrypt/Certbot volumes in `docker-compose.yaml` and `deployment/nginx/nginx.conf`.
  - No S3/GCS/Azure Blob integration detected.

**Caching:**
- No Redis/Memcached/application cache detected.
- Browser/static asset caching is configured through NGINX in `openmeet-client/docker-nginx.conf`.

## Authentication & Identity

**Auth Provider:**
- Custom email/password authentication implemented in Rust.
  - Server routes: `openmeet-server/src/auth/routes.rs`.
  - Server handlers: `openmeet-server/src/auth/handlers.rs`.
  - Client API wrapper: `openmeet-client/src/services/auth-api.ts`.
  - Client route guard: `openmeet-client/src/router/index.ts`.

**Token Model:**
- JWT access tokens are created and validated with `jsonwebtoken` in `openmeet-server/src/auth/jwt.rs`.
- Refresh tokens are random UUIDs, hashed with SHA-256 before database storage in `openmeet-server/src/auth/jwt.rs`, persisted in `refresh_tokens` from `openmeet-server/migrations/20251201000001_create_refresh_tokens/up.sql`.
- Password hashing uses Argon2 declared in `openmeet-server/Cargo.toml` and used by the auth module under `openmeet-server/src/auth/**`.

**Identity Stores:**
- Users are persisted in PostgreSQL table `users` from `openmeet-server/migrations/20251201000000_create_users/up.sql`.
- Client tokens are read from browser cookies by `cookieUtils` in `openmeet-client/src/router/index.ts` and API calls include bearer tokens from `openmeet-client/src/services/auth-api.ts`.

## Monitoring & Observability

**Metrics:**
- Prometheus metrics exporter is installed in `openmeet-server/src/main.rs`, rendered at `/metrics`, and scraped by `observability/prometheus.yaml` under job `sfu-server`.
- SFU counters and gauges are emitted in `openmeet-server/src/signaling/handler.rs`.
- Node Exporter and cAdvisor scrape targets are configured in `observability/prometheus.yaml` and services are defined in `docker-compose.dev.yml` and `docker-compose.yaml`.

**Dashboards:**
- Grafana is provisioned with datasources in `observability/grafana/datasources.yaml` and dashboard provisioning files under `observability/grafana/**`.
- Production NGINX exposes Grafana at `grafana.openmeets.eu` in `deployment/nginx/nginx.conf`.

**Logs:**
- Server logging uses `tracing` initialized in `openmeet-server/src/main.rs`.
- Container log shipping uses Promtail and Loki configured in `docker-compose.dev.yml`, `docker-compose.yaml`, `observability/promtail-config.yaml`, and `observability/loki-config.yaml`.
- Client logging uses browser `console` calls in `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/services/webrtc-sfu.ts`, and `openmeet-client/src/xstate/machines/webrtc/actors.ts`.

**Error Tracking:**
- No Sentry, Bugsnag, Rollbar, or equivalent hosted error tracking integration detected.

## CI/CD & Deployment

**Hosting:**
- Production deploy target is a VPS accessed over SSH from `.github/workflows/deploy.yml`.
- Public routing and TLS termination are handled by NGINX in `deployment/nginx/nginx.conf`.
- Frontend is served by an internal NGINX container built from `openmeet-client/Dockerfile`.
- Backend is a Rust binary in a Debian slim container built from `openmeet-server/Dockerfile`.

**CI Pipeline:**
- Build workflow: `.github/workflows/build.yml` runs client type-check/build and server `cargo check --release`/`cargo build --release`.
- Test workflow: `.github/workflows/test.yml` runs client lint/unit tests and server `cargo test`/`cargo check` after build succeeds.
- Deploy workflow: `.github/workflows/deploy.yml` runs after tests, installs SSH credentials from GitHub Actions secrets, updates the VPS checkout, runs `deploy.sh`, and checks `https://openmeets.eu/health`.

**Container Orchestration:**
- Development stack: `docker-compose.dev.yml` includes PostgreSQL, frontend, SFU, Coturn, Promtail, Loki, Prometheus, Grafana, Node Exporter, and cAdvisor.
- Production stack: `docker-compose.yaml` includes PostgreSQL, frontend, SFU, Coturn, NGINX, Certbot, Promtail, Loki, Prometheus, Grafana, Node Exporter, and cAdvisor.
- Make targets in `Makefile` wrap `docker compose -f docker-compose.dev.yml` for local development.

## Environment Configuration

**Required env vars:**
- Server: `DATABASE_URL`, `JWT_SECRET` are required by `openmeet-server/src/main.rs`.
- Server optional auth lifetime: `ACCESS_TOKEN_MINUTES`, `REFRESH_TOKEN_DAYS` in `openmeet-server/src/main.rs`.
- Server optional TLS: `USE_TLS`, `SSL_CERT_PATH`, `SSL_KEY_PATH` in `openmeet-server/src/main.rs`.
- Server optional WebRTC networking: `STUN_URL`, `TURN_URL`, `TURN_USER`, `TURN_PASSWORD`, `UDP_PORT_MIN`, `UDP_PORT_MAX` in `openmeet-server/src/signaling/handler.rs`.
- Client API/WebRTC: `VITE_API_URL`, `VITE_SFU_WSS_URL`, `VITE_TURN_URL`, `VITE_TURN_USER`, `VITE_TURN_PASSWORD`, `VITE_LANDING_PAGE` in `openmeet-client/src/services/auth-api.ts`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`, `openmeet-client/src/services/webrtc-sfu.ts`, and `openmeet-client/src/router/index.ts`.
- Production compose variables: PostgreSQL and TURN placeholders are referenced by `docker-compose.yaml`; use environment/secret injection rather than committing values.

**Secrets location:**
- GitHub Actions deployment secrets are referenced as `secrets.SSH_PRIVATE_KEY`, `secrets.VPS_PORT`, `secrets.VPS_HOST`, and `secrets.VPS_USERNAME` in `.github/workflows/deploy.yml`.
- Runtime secrets should be supplied through environment files or the deployment host for `docker-compose.yaml`; `.env.example`, `openmeet-client/.env.example`, and `openmeet-server/.env.example` exist but were not read.
- Do not commit concrete values for `JWT_SECRET`, database passwords, TURN credentials, or SSH keys.

## Webhooks & Callbacks

**Incoming:**
- WebSocket endpoint `/ws` receives signaling messages from browsers, implemented in `openmeet-server/src/signaling/handler.rs` and exposed by `openmeet-server/src/main.rs`.
- Auth endpoints under `/auth/*` receive browser requests, implemented in `openmeet-server/src/auth/routes.rs` and `openmeet-server/src/auth/handlers.rs`.
- Prometheus scrapes `/metrics`, implemented in `openmeet-server/src/main.rs` and configured in `observability/prometheus.yaml`.
- GitHub Actions workflow triggers use `push`, `pull_request`, `workflow_dispatch`, and `workflow_run` in `.github/workflows/build.yml`, `.github/workflows/test.yml`, and `.github/workflows/deploy.yml`.
- No third-party webhook receiver endpoints such as Stripe, Slack, GitHub webhooks, or email callbacks detected.

**Outgoing:**
- Client browser connects to the API/SFU endpoints through `openmeet-client/src/services/auth-api.ts` and `openmeet-client/src/services/signaling.ts`.
- WebRTC ICE negotiation uses STUN/TURN servers configured by `openmeet-client/src/services/webrtc-sfu.ts` and `openmeet-server/src/signaling/handler.rs`.
- Deploy workflow SSHes to the VPS and performs an HTTPS health check from `.github/workflows/deploy.yml`.
- Promtail pushes logs to Loki through `observability/promtail-config.yaml`.
- No payment, email, SMS, push notification, object storage, or analytics outbound integrations detected.

---

*Integration audit: 2026-06-19*
