---
doc_type: codebase-map
focus: tech
generated_at: 2026-06-19
source_scope: full repo
---

# Technology Stack

**Analysis Date:** 2026-06-19

## Languages

**Primary:**
- TypeScript `~5.9.0` - Vue client source in `openmeet-client/src/**/*.ts` and Vue single-file components in `openmeet-client/src/**/*.vue`; configured by `openmeet-client/tsconfig.json`.
- Rust edition `2024` - SFU/API server in `openmeet-server/src/**/*.rs`; package metadata in `openmeet-server/Cargo.toml`.

**Secondary:**
- Vue SFC template/CSS - UI components and pages in `openmeet-client/src/components/**/*.vue` and `openmeet-client/src/pages/**/*.vue`.
- SQL - Diesel migrations in `openmeet-server/migrations/20251201000000_create_users/up.sql` and `openmeet-server/migrations/20251201000001_create_refresh_tokens/up.sql`.
- YAML - GitHub Actions in `.github/workflows/build.yml`, `.github/workflows/test.yml`, `.github/workflows/deploy.yml`, Docker Compose files in `docker-compose.dev.yml` and `docker-compose.yaml`, and observability config in `observability/*.yaml`.
- JavaScript/CommonJS config - Tailwind/PostCSS config in `openmeet-client/tailwind.config.js` and `openmeet-client/postcss.config.js`.
- NGINX config - SPA and reverse-proxy routing in `openmeet-client/docker-nginx.conf` and `deployment/nginx/nginx.conf`.

## Runtime

**Environment:**
- Browser runtime for the Vue SPA mounted from `openmeet-client/src/main.ts`.
- Node.js `^20.19.0 || >=22.12.0` for client tooling, declared in `openmeet-client/package.json`.
- Node.js `22` in CI and Docker for client builds, configured in `.github/workflows/build.yml`, `.github/workflows/test.yml`, and `openmeet-client/Dockerfile`.
- Rust toolchain `stable` in CI via `.github/workflows/build.yml` and `.github/workflows/test.yml`; Docker builds use `rust:1.91.1-bookworm` in `openmeet-server/Dockerfile`.
- Tokio async runtime `1.49` for the Rust server, declared in `openmeet-server/Cargo.toml` and used by `#[tokio::main]` in `openmeet-server/src/main.rs`.

**Package Manager:**
- Client: Yarn Classic lockfile present at `openmeet-client/yarn.lock`; CI runs `yarn install --frozen-lockfile` from `.github/workflows/build.yml` and `.github/workflows/test.yml`.
- Server: Cargo manifest present at `openmeet-server/Cargo.toml`; no `openmeet-server/Cargo.lock` detected in the repository even though CI cache keys reference it in `.github/workflows/build.yml` and `.github/workflows/test.yml`.
- Root automation: Make targets wrap Docker Compose in `Makefile`.

## Frameworks

**Core:**
- Vue `^3.5.22` - SPA framework for `openmeet-client/src/App.vue`, `openmeet-client/src/main.ts`, pages, and components.
- Vue Router `^4.6.3` - client routing and auth guards in `openmeet-client/src/router/index.ts`.
- XState `^5.24.0` and `@xstate/vue` `^5.0.0` - state machines and actors in `openmeet-client/src/xstate/machines/**`.
- Axum `0.8.8` and Axum Server `0.8.0` - Rust HTTP/WebSocket server in `openmeet-server/src/main.rs` and `openmeet-server/src/signaling/handler.rs`.
- WebRTC crate `0.14` - SFU peer-connection implementation in `openmeet-server/src/sfu/peer_connection.rs` and WebSocket signaling handler in `openmeet-server/src/signaling/handler.rs`.
- Diesel `2.3.5`, Diesel Async `0.8.0`, and Diesel Migrations `2.2` - PostgreSQL schema, async connection pool, and embedded migrations in `openmeet-server/src/db/mod.rs`, `openmeet-server/src/schema.rs`, and `openmeet-server/src/main.rs`.

**Testing:**
- Vitest `^3.2.4` - unit tests configured in `openmeet-client/vitest.config.ts`.
- Vitest Browser + Playwright provider - browser tests configured in `openmeet-client/vitest.browser.config.ts`.
- Playwright `^1.56.1` - E2E test runner configured in `openmeet-client/playwright.config.ts`.
- Cargo test - server test command in `.github/workflows/test.yml`.

**Build/Dev:**
- Vite via `rolldown-vite@latest` - client dev/build server in `openmeet-client/vite.config.ts` and scripts in `openmeet-client/package.json`.
- Vue TSC `^3.1.1` - client type checking via `yarn type-check` in `openmeet-client/package.json` and `.github/workflows/build.yml`.
- Tailwind CSS `^3.4.18` with `tailwindcss-animate` - styling pipeline configured in `openmeet-client/tailwind.config.js`.
- ESLint `^9.37.0`, Oxlint `~1.23.0`, and Prettier `3.6.2` - client lint/format tooling configured in `openmeet-client/eslint.config.ts` and scripts in `openmeet-client/package.json`.
- Docker multi-stage builds - client in `openmeet-client/Dockerfile`, server in `openmeet-server/Dockerfile`.
- NGINX - static SPA serving in `openmeet-client/Dockerfile` and production reverse proxy in `deployment/nginx/nginx.conf`.

## Key Dependencies

**Critical:**
- `firebase` `^12.5.0` - declared in `openmeet-client/package.json`; no active imports detected under `openmeet-client/src`, so treat as unused until integration code exists.
- `@vueuse/core` `^14.1.0` - Vue composition utilities available to client code from `openmeet-client/package.json`.
- `reka-ui` `^2.6.1`, `shadcn-vue` `^2.3.3`, `lucide-vue-next` `^0.553.0`, `class-variance-authority`, `clsx`, and `tailwind-merge` - UI component and styling primitives used by components under `openmeet-client/src/components/ui/**`.
- `tokio-tungstenite` `0.28` and Axum WebSocket support - WebSocket signaling in `openmeet-server/src/signaling/handler.rs`.
- `jsonwebtoken` `10.2.0`, `argon2` `0.5`, `sha2` `0.11`, and `rand` `0.10` - custom auth implementation in `openmeet-server/src/auth/**/*.rs`.
- `metrics` `0.24` and `metrics-exporter-prometheus` `0.18.1` - Prometheus endpoint exposed from `openmeet-server/src/main.rs`.
- `tracing` `0.1.44` and `tracing-subscriber` `0.3.22` - server logging initialized in `openmeet-server/src/main.rs`.

**Infrastructure:**
- PostgreSQL `16-alpine` - database service in `docker-compose.dev.yml` and `docker-compose.yaml`.
- Coturn `latest` - TURN relay service in `docker-compose.dev.yml` and `docker-compose.yaml`.
- Prometheus, Grafana, Loki, Promtail, Node Exporter, and cAdvisor - observability services in `docker-compose.dev.yml`, `docker-compose.yaml`, and `observability/**`.
- Certbot - certificate renewal service in `docker-compose.yaml` and ACME webroot handling in `deployment/nginx/nginx.conf`.

## Configuration

**Environment:**
- Client env vars are read through `import.meta.env` in `openmeet-client/src/services/auth-api.ts`, `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`, and `openmeet-client/src/router/index.ts`.
- Server env vars are loaded with `dotenvy::dotenv().ok()` and `std::env::var` in `openmeet-server/src/main.rs` and `openmeet-server/src/signaling/handler.rs`.
- Environment example files exist at `.env.example`, `openmeet-client/.env.example`, and `openmeet-server/.env.example`; contents were not read because `.env*` files may contain secret-like values.

**Build:**
- Client build config: `openmeet-client/vite.config.ts`, `openmeet-client/tsconfig.json`, `openmeet-client/tsconfig.app.json`, `openmeet-client/tsconfig.node.json`, `openmeet-client/tsconfig.vitest.json`, `openmeet-client/tailwind.config.js`, `openmeet-client/postcss.config.js`, `openmeet-client/eslint.config.ts`.
- Server build config: `openmeet-server/Cargo.toml`, `openmeet-server/diesel.toml`, `openmeet-server/Dockerfile`.
- CI config: `.github/workflows/build.yml`, `.github/workflows/test.yml`, `.github/workflows/deploy.yml`.
- Runtime orchestration: `docker-compose.dev.yml`, `docker-compose.yaml`, `Makefile`, `deployment/nginx/nginx.conf`, `openmeet-client/docker-nginx.conf`.

## Platform Requirements

**Development:**
- Use Docker Compose through `Makefile` targets `dev`, `stop`, `restart`, and `logs`; compose definitions live in `docker-compose.dev.yml`.
- Client local dev server listens on `0.0.0.0:5173` from `openmeet-client/vite.config.ts`.
- Server listens on `0.0.0.0:8081` and exposes `/health`, `/ws`, `/metrics`, and `/auth/*` from `openmeet-server/src/main.rs`.
- PostgreSQL must be reachable through `DATABASE_URL`; Diesel migrations are embedded and run at server startup from `openmeet-server/src/main.rs`.
- WebRTC requires STUN/TURN configuration through server/client environment variables consumed in `openmeet-server/src/signaling/handler.rs` and `openmeet-client/src/services/webrtc-sfu.ts`.

**Production:**
- Deployment target is a VPS reached by SSH from `.github/workflows/deploy.yml`, with repository checkout under `/home/debian/openmeet` and deployment delegated to `deploy.sh`.
- Public hosts are routed by NGINX in `deployment/nginx/nginx.conf`: `openmeets.eu` for the frontend, `sfu.openmeets.eu` for WebSocket/API, `grafana.openmeets.eu` for Grafana, and `turn.openmeets.eu` included in TLS redirect coverage.
- Production containers are defined in `docker-compose.yaml`; local/dev containers are defined in `docker-compose.dev.yml`.
- TLS certificates are expected under Let's Encrypt paths referenced by `deployment/nginx/nginx.conf`; Certbot renewal is configured in `docker-compose.yaml`.

---

*Stack analysis: 2026-06-19*
