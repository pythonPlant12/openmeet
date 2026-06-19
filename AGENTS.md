<!-- GSD:project-start source:PROJECT.md -->
## Project

**OpenMeet Multi-Participant Media Stability**

OpenMeet is an existing browser-based video meeting application with a Vue 3 client and a Rust Axum/WebRTC SFU backend. This project focuses on debugging and stabilizing the meeting connection flow so participants reliably connect and receive remote audio/video streams.

The immediate goal is not to redesign the product. It is to make the existing meeting experience dependable when two or more participants join the same room.

**Core Value:** Participants in the same OpenMeet room can maintain stable, bidirectional audio/video without missing remote media streams.

### Constraints

- **Tech stack**: Preserve Vue 3, TypeScript, XState, Rust, Axum, WebRTC crate, Diesel, PostgreSQL, Docker Compose, and existing SFU architecture unless a concrete defect requires a targeted change.
- **Brownfield safety**: Read and preserve existing code patterns from `.planning/codebase/` before modifying signaling, SFU, or WebRTC client files.
- **Verification**: A fix is not complete until two browser participants in the same room receive each other's audio/video streams and automated checks cover the corrected path where feasible.
- **Scope**: Start with the smallest stable two-user flow before widening to late joiners and 3+ participant cases.
- **Security**: Do not introduce new token, CORS, room-join, or TURN credential exposure while debugging media flow.
- **Concurrency**: Avoid holding long-lived room locks across async WebRTC operations when fixing server forwarding behavior.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- TypeScript `~5.9.0` - Vue client source in `openmeet-client/src/**/*.ts` and Vue single-file components in `openmeet-client/src/**/*.vue`; configured by `openmeet-client/tsconfig.json`.
- Rust edition `2024` - SFU/API server in `openmeet-server/src/**/*.rs`; package metadata in `openmeet-server/Cargo.toml`.
- Vue SFC template/CSS - UI components and pages in `openmeet-client/src/components/**/*.vue` and `openmeet-client/src/pages/**/*.vue`.
- SQL - Diesel migrations in `openmeet-server/migrations/20251201000000_create_users/up.sql` and `openmeet-server/migrations/20251201000001_create_refresh_tokens/up.sql`.
- YAML - GitHub Actions in `.github/workflows/build.yml`, `.github/workflows/test.yml`, `.github/workflows/deploy.yml`, Docker Compose files in `docker-compose.dev.yml` and `docker-compose.yaml`, and observability config in `observability/*.yaml`.
- JavaScript/CommonJS config - Tailwind/PostCSS config in `openmeet-client/tailwind.config.js` and `openmeet-client/postcss.config.js`.
- NGINX config - SPA and reverse-proxy routing in `openmeet-client/docker-nginx.conf` and `deployment/nginx/nginx.conf`.
## Runtime
- Browser runtime for the Vue SPA mounted from `openmeet-client/src/main.ts`.
- Node.js `^20.19.0 || >=22.12.0` for client tooling, declared in `openmeet-client/package.json`.
- Node.js `22` in CI and Docker for client builds, configured in `.github/workflows/build.yml`, `.github/workflows/test.yml`, and `openmeet-client/Dockerfile`.
- Rust toolchain `stable` in CI via `.github/workflows/build.yml` and `.github/workflows/test.yml`; Docker builds use `rust:1.91.1-bookworm` in `openmeet-server/Dockerfile`.
- Tokio async runtime `1.49` for the Rust server, declared in `openmeet-server/Cargo.toml` and used by `#[tokio::main]` in `openmeet-server/src/main.rs`.
- Client: Yarn Classic lockfile present at `openmeet-client/yarn.lock`; CI runs `yarn install --frozen-lockfile` from `.github/workflows/build.yml` and `.github/workflows/test.yml`.
- Server: Cargo manifest present at `openmeet-server/Cargo.toml`; no `openmeet-server/Cargo.lock` detected in the repository even though CI cache keys reference it in `.github/workflows/build.yml` and `.github/workflows/test.yml`.
- Root automation: Make targets wrap Docker Compose in `Makefile`.
## Frameworks
- Vue `^3.5.22` - SPA framework for `openmeet-client/src/App.vue`, `openmeet-client/src/main.ts`, pages, and components.
- Vue Router `^4.6.3` - client routing and auth guards in `openmeet-client/src/router/index.ts`.
- XState `^5.24.0` and `@xstate/vue` `^5.0.0` - state machines and actors in `openmeet-client/src/xstate/machines/**`.
- Axum `0.8.8` and Axum Server `0.8.0` - Rust HTTP/WebSocket server in `openmeet-server/src/main.rs` and `openmeet-server/src/signaling/handler.rs`.
- WebRTC crate `0.14` - SFU peer-connection implementation in `openmeet-server/src/sfu/peer_connection.rs` and WebSocket signaling handler in `openmeet-server/src/signaling/handler.rs`.
- Diesel `2.3.5`, Diesel Async `0.8.0`, and Diesel Migrations `2.2` - PostgreSQL schema, async connection pool, and embedded migrations in `openmeet-server/src/db/mod.rs`, `openmeet-server/src/schema.rs`, and `openmeet-server/src/main.rs`.
- Vitest `^3.2.4` - unit tests configured in `openmeet-client/vitest.config.ts`.
- Vitest Browser + Playwright provider - browser tests configured in `openmeet-client/vitest.browser.config.ts`.
- Playwright `^1.56.1` - E2E test runner configured in `openmeet-client/playwright.config.ts`.
- Cargo test - server test command in `.github/workflows/test.yml`.
- Vite via `rolldown-vite@latest` - client dev/build server in `openmeet-client/vite.config.ts` and scripts in `openmeet-client/package.json`.
- Vue TSC `^3.1.1` - client type checking via `yarn type-check` in `openmeet-client/package.json` and `.github/workflows/build.yml`.
- Tailwind CSS `^3.4.18` with `tailwindcss-animate` - styling pipeline configured in `openmeet-client/tailwind.config.js`.
- ESLint `^9.37.0`, Oxlint `~1.23.0`, and Prettier `3.6.2` - client lint/format tooling configured in `openmeet-client/eslint.config.ts` and scripts in `openmeet-client/package.json`.
- Docker multi-stage builds - client in `openmeet-client/Dockerfile`, server in `openmeet-server/Dockerfile`.
- NGINX - static SPA serving in `openmeet-client/Dockerfile` and production reverse proxy in `deployment/nginx/nginx.conf`.
## Key Dependencies
- `firebase` `^12.5.0` - declared in `openmeet-client/package.json`; no active imports detected under `openmeet-client/src`, so treat as unused until integration code exists.
- `@vueuse/core` `^14.1.0` - Vue composition utilities available to client code from `openmeet-client/package.json`.
- `reka-ui` `^2.6.1`, `shadcn-vue` `^2.3.3`, `lucide-vue-next` `^0.553.0`, `class-variance-authority`, `clsx`, and `tailwind-merge` - UI component and styling primitives used by components under `openmeet-client/src/components/ui/**`.
- `tokio-tungstenite` `0.28` and Axum WebSocket support - WebSocket signaling in `openmeet-server/src/signaling/handler.rs`.
- `jsonwebtoken` `10.2.0`, `argon2` `0.5`, `sha2` `0.11`, and `rand` `0.10` - custom auth implementation in `openmeet-server/src/auth/**/*.rs`.
- `metrics` `0.24` and `metrics-exporter-prometheus` `0.18.1` - Prometheus endpoint exposed from `openmeet-server/src/main.rs`.
- `tracing` `0.1.44` and `tracing-subscriber` `0.3.22` - server logging initialized in `openmeet-server/src/main.rs`.
- PostgreSQL `16-alpine` - database service in `docker-compose.dev.yml` and `docker-compose.yaml`.
- Coturn `latest` - TURN relay service in `docker-compose.dev.yml` and `docker-compose.yaml`.
- Prometheus, Grafana, Loki, Promtail, Node Exporter, and cAdvisor - observability services in `docker-compose.dev.yml`, `docker-compose.yaml`, and `observability/**`.
- Certbot - certificate renewal service in `docker-compose.yaml` and ACME webroot handling in `deployment/nginx/nginx.conf`.
## Configuration
- Client env vars are read through `import.meta.env` in `openmeet-client/src/services/auth-api.ts`, `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`, and `openmeet-client/src/router/index.ts`.
- Server env vars are loaded with `dotenvy::dotenv().ok()` and `std::env::var` in `openmeet-server/src/main.rs` and `openmeet-server/src/signaling/handler.rs`.
- Environment example files exist at `.env.example`, `openmeet-client/.env.example`, and `openmeet-server/.env.example`; contents were not read because `.env*` files may contain secret-like values.
- Client build config: `openmeet-client/vite.config.ts`, `openmeet-client/tsconfig.json`, `openmeet-client/tsconfig.app.json`, `openmeet-client/tsconfig.node.json`, `openmeet-client/tsconfig.vitest.json`, `openmeet-client/tailwind.config.js`, `openmeet-client/postcss.config.js`, `openmeet-client/eslint.config.ts`.
- Server build config: `openmeet-server/Cargo.toml`, `openmeet-server/diesel.toml`, `openmeet-server/Dockerfile`.
- CI config: `.github/workflows/build.yml`, `.github/workflows/test.yml`, `.github/workflows/deploy.yml`.
- Runtime orchestration: `docker-compose.dev.yml`, `docker-compose.yaml`, `Makefile`, `deployment/nginx/nginx.conf`, `openmeet-client/docker-nginx.conf`.
## Platform Requirements
- Use Docker Compose through `Makefile` targets `dev`, `stop`, `restart`, and `logs`; compose definitions live in `docker-compose.dev.yml`.
- Client local dev server listens on `0.0.0.0:5173` from `openmeet-client/vite.config.ts`.
- Server listens on `0.0.0.0:8081` and exposes `/health`, `/ws`, `/metrics`, and `/auth/*` from `openmeet-server/src/main.rs`.
- PostgreSQL must be reachable through `DATABASE_URL`; Diesel migrations are embedded and run at server startup from `openmeet-server/src/main.rs`.
- WebRTC requires STUN/TURN configuration through server/client environment variables consumed in `openmeet-server/src/signaling/handler.rs` and `openmeet-client/src/services/webrtc-sfu.ts`.
- Deployment target is a VPS reached by SSH from `.github/workflows/deploy.yml`, with repository checkout under `/home/debian/openmeet` and deployment delegated to `deploy.sh`.
- Public hosts are routed by NGINX in `deployment/nginx/nginx.conf`: `openmeets.eu` for the frontend, `sfu.openmeets.eu` for WebSocket/API, `grafana.openmeets.eu` for Grafana, and `turn.openmeets.eu` included in TLS redirect coverage.
- Production containers are defined in `docker-compose.yaml`; local/dev containers are defined in `docker-compose.dev.yml`.
- TLS certificates are expected under Let's Encrypt paths referenced by `deployment/nginx/nginx.conf`; Certbot renewal is configured in `docker-compose.yaml`.
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- Vue pages use PascalCase with `Page` suffix in `openmeet-client/src/pages/`, for example `openmeet-client/src/pages/LoginPage.vue`, `openmeet-client/src/pages/DashboardPage.vue`, and `openmeet-client/src/pages/MeetingPage.vue`.
- Vue layout components use `The*` names in `openmeet-client/src/components/layout/`, for example `openmeet-client/src/components/layout/TheNavbar.vue` and `openmeet-client/src/components/layout/TheFooter.vue`.
- Vue feature components use PascalCase under feature folders, for example `openmeet-client/src/components/meeting-page/JoinMeetingDialog.vue`, `openmeet-client/src/components/meeting-page/VideoGrid.vue`, and `openmeet-client/src/components/landing-page/FeatureCard.vue`.
- UI primitives are grouped by kebab-case directory and PascalCase component file, for example `openmeet-client/src/components/ui/button/Button.vue` with `openmeet-client/src/components/ui/button/index.ts`.
- Client composables use `use*` camelCase files in `openmeet-client/src/composables/`, for example `openmeet-client/src/composables/useAuth.ts`, `openmeet-client/src/composables/useTheme.ts`, and `openmeet-client/src/composables/useMediaDevices.ts`.
- Client service files use kebab-case when the domain has multiple words, for example `openmeet-client/src/services/auth-api.ts` and `openmeet-client/src/services/webrtc-sfu.ts`.
- XState machines live in domain folders with `index.ts` and `types.ts`, for example `openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/xstate/machines/auth/types.ts`, and `openmeet-client/src/xstate/machines/webrtc/actors.ts`.
- Rust modules use snake_case file and module names under `openmeet-server/src/`, for example `openmeet-server/src/auth/handlers.rs`, `openmeet-server/src/sfu/peer_connection.rs`, and `openmeet-server/src/signaling/message.rs`.
- Client exported composables use `use*` names and return grouped reactive state/actions, for example `useAuth()` in `openmeet-client/src/composables/useAuth.ts` and `useTheme()` in `openmeet-client/src/composables/useTheme.ts`.
- Vue event handlers use `handle*` names inside `<script setup>`, for example `handleLogin()` and `handleRetry()` in `openmeet-client/src/pages/LoginPage.vue`.
- Client service methods use verb names inside exported service objects, for example `authApi.login()`, `authApi.register()`, `authApi.refresh()`, `authApi.logout()`, and `authApi.me()` in `openmeet-client/src/services/auth-api.ts`.
- XState actor constants use lower camelCase with `Actor` suffix, for example `loginActor`, `registerActor`, `checkSessionActor`, `refreshTokenActor`, and `logoutActor` in `openmeet-client/src/xstate/machines/auth/index.ts`.
- Rust functions and methods use snake_case, for example `create_pool()` in `openmeet-server/src/db/mod.rs`, `health_check()` in `openmeet-server/src/main.rs`, and `extract_user_id()` in `openmeet-server/src/auth/handlers.rs`.
- Rust handlers are named by route action, for example `register`, `login`, `refresh`, `logout`, and `me` in `openmeet-server/src/auth/handlers.rs`.
- Client local state and computed values use lower camelCase, for example `isAuthenticating`, `isCheckingSession`, `errorMessage`, and `currentUser` in `openmeet-client/src/composables/useAuth.ts`.
- Client constants that represent environment-derived singleton values use SCREAMING_SNAKE_CASE, for example `API_BASE_URL` in `openmeet-client/src/services/auth-api.ts`.
- XState events are UPPER_SNAKE_CASE enum values, for example `AuthEventType.LOGIN`, `AuthEventType.REFRESH_TOKEN`, and `AuthEventType.GO_TO_REGISTER` in `openmeet-client/src/xstate/machines/auth/types.ts`.
- Rust local variables use snake_case, for example `database_url`, `jwt_secret`, `access_token_minutes`, and `refresh_token_days` in `openmeet-server/src/main.rs`.
- Rust constants use SCREAMING_SNAKE_CASE, for example `MIGRATIONS` in `openmeet-server/src/main.rs` and `RTP_BROADCAST_CAPACITY` in `openmeet-server/src/sfu/room.rs`.
- Client interfaces use PascalCase nouns, for example `User`, `AuthResponse`, `LoginRequest`, and `RegisterRequest` in `openmeet-client/src/services/auth-api.ts`.
- Client enums use PascalCase type names and UPPER_SNAKE_CASE members, for example `AuthState` and `AuthEventType` in `openmeet-client/src/xstate/machines/auth/types.ts`.
- XState event unions are discriminated by `type`, for example `AuthEvents` in `openmeet-client/src/xstate/machines/auth/types.ts`.
- Rust structs and type aliases use PascalCase, for example `AppState` in `openmeet-server/src/main.rs`, `DbPool` in `openmeet-server/src/db/mod.rs`, and `AuthResponse` in `openmeet-server/src/auth/models.rs`.
## Code Style
- Use Prettier for client source formatting via `npm run format` / `yarn format`, defined as `prettier --write src/` in `openmeet-client/package.json`.
- ESLint delegates formatting concerns to Prettier through `skipFormatting` from `@vue/eslint-config-prettier/skip-formatting` in `openmeet-client/eslint.config.ts`.
- Client TypeScript and Vue code generally uses 2-space indentation, semicolon-terminated statements in most authored `.ts` files, and single quotes, as shown in `openmeet-client/src/services/auth-api.ts` and `openmeet-client/src/xstate/machines/auth/index.ts`.
- Some generated or scaffolded config files omit semicolons, for example `openmeet-client/eslint.config.ts` and `openmeet-client/playwright.config.ts`; follow the surrounding file style when editing config.
- Rust formatting follows standard `rustfmt` conventions: 4-space indentation, snake_case names, grouped `use` statements, and trailing commas in multi-line structures, as shown in `openmeet-server/src/main.rs` and `openmeet-server/src/auth/handlers.rs`.
- Run client lint with `yarn lint` or `npm run lint` from `openmeet-client/`; this runs `lint:oxlint` then `lint:eslint` via `run-s lint:*` in `openmeet-client/package.json`.
- `lint:oxlint` runs `oxlint . --fix -D correctness --ignore-path .gitignore` from `openmeet-client/package.json`.
- `lint:eslint` runs `eslint . --fix --cache` from `openmeet-client/package.json`.
- ESLint targets `**/*.{ts,mts,tsx,vue}` and ignores `**/dist/**`, `**/dist-ssr/**`, and `**/coverage/**` in `openmeet-client/eslint.config.ts`.
- ESLint uses `eslint-plugin-vue` essential rules, `@vue/eslint-config-typescript` recommended rules, Vitest rules for `src/**/__tests__/*`, Playwright rules for `e2e/**/*.{test,spec}.{js,ts,jsx,tsx}`, and Oxlint recommended rules in `openmeet-client/eslint.config.ts`.
- Project-specific ESLint relaxations are explicit: `@typescript-eslint/no-explicit-any` is off and `vue/multi-word-component-names` is off in `openmeet-client/eslint.config.ts`.
- Rust CI runs `cargo check`, `cargo check --release`, and `cargo test`; Clippy is present but commented out in `.github/workflows/test.yml`.
## Import Organization
- Use `@/*` for client source imports; it maps to `./src/*` in `openmeet-client/tsconfig.json` and resolves to `src` in `openmeet-client/vite.config.ts`.
- Prefer `@/components/...`, `@/composables/...`, `@/services/...`, and `@/xstate/...` over deep relative paths in client code, as shown in `openmeet-client/src/pages/LoginPage.vue` and `openmeet-client/src/xstate/machines/auth/index.ts`.
- Server modules use explicit `crate::` paths for cross-module references, for example `crate::auth`, `crate::db`, `crate::schema`, and `crate::sfu` in `openmeet-server/src/main.rs` and `openmeet-server/src/auth/handlers.rs`.
## Error Handling
- Client composables that require injection should fail fast with `throw new Error(...)`, as in `useAuth()` in `openmeet-client/src/composables/useAuth.ts` and the auth actor check in `openmeet-client/src/pages/LoginPage.vue`.
- Client API wrappers should centralize HTTP error translation through a helper. `handleResponse<T>()` in `openmeet-client/src/services/auth-api.ts` checks `response.ok`, reads `response.text()`, and throws `AuthApiError` with a status.
- Client utility parsing should return safe nullable/falsy values instead of throwing for invalid user-controlled input, as `jwtUtils.parse()` returns `null` in `openmeet-client/src/utils.ts`.
- Client retryable API flows should catch and degrade locally when appropriate, for example `authApi.me()` attempts `refresh()` and uses `.catch(() => null)` in `openmeet-client/src/services/auth-api.ts`.
- XState machines should map actor failures into explicit failure states and store readable errors in context through `setError`, as in `openmeet-client/src/xstate/machines/auth/index.ts`.
- Rust HTTP handlers should return `Result<_, (StatusCode, String)>` aliases and convert fallible operations with `.map_err(...)`, as `ApiResult<T>` and auth handlers do in `openmeet-server/src/auth/handlers.rs`.
- Rust startup code can use `.expect(...)` for required environment/configuration failures, for example `DATABASE_URL`, `JWT_SECRET`, migrations, and TLS certificate loading in `openmeet-server/src/main.rs`.
- Rust domain/service code should prefer `anyhow::Result` for internal WebRTC/SFU operations where errors are propagated across async boundaries, as in `openmeet-server/src/sfu/peer_connection.rs` and `openmeet-server/src/sfu/repository.rs`.
## Logging
- Client: direct `console.log` / `console.error` in WebRTC, signaling, preview, and current tests.
- Server: `tracing` macros (`info!`, `warn!`, `error!`, `debug!`) initialized by `tracing_subscriber::fmt()` in `openmeet-server/src/main.rs`.
- Server startup and infrastructure logs use `info!`, for example database pool and metrics initialization in `openmeet-server/src/main.rs`.
- Server WebSocket and SFU flows use structured component messages with participant and room IDs, for example `openmeet-server/src/signaling/handler.rs` and `openmeet-server/src/sfu/room.rs`.
- Server recoverable failures use `warn!`, for example invalid signaling messages in `openmeet-server/src/signaling/handler.rs` and missing participants in `openmeet-server/src/sfu/room.rs`.
- Server operation failures use `error!`, for example send/serialization failures in `openmeet-server/src/signaling/handler.rs`.
- Client WebRTC and signaling services prefix logs with component tags like `[WebRTCServiceSFU]`, `[SignalingService]`, and `[webrtcMachine]` in `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/services/signaling.ts`, and `openmeet-client/src/xstate/machines/webrtc/actors.ts`.
- Avoid untagged debug logging in new tests and source. Existing untagged logs appear in `openmeet-client/src/composables/__tests__/useAuth.test.ts` and `openmeet-client/src/composables/__tests__/useAuth.browser.test.ts`.
## Comments
- Use comments for non-obvious architecture, lifecycle, and protocol behavior, for example WebSocket task roles in `openmeet-server/src/signaling/handler.rs`, refresh-token semantics in `openmeet-client/src/router/index.ts`, and room cleanup semantics in `openmeet-server/src/sfu/room.rs`.
- Use comments for operational constraints, for example TLS and NAT/TURN/STUN configuration in `openmeet-server/src/main.rs` and `openmeet-server/src/signaling/handler.rs`.
- Avoid comments that simply restate names. Existing simple section comments in `openmeet-server/src/auth/handlers.rs` are acceptable for route grouping but new comments should explain why/constraints.
- Client code does not use a JSDoc/TSDoc convention. Prefer TypeScript interfaces and clear function names over docblocks in files like `openmeet-client/src/services/auth-api.ts` and `openmeet-client/src/xstate/machines/auth/types.ts`.
- Rust uses `///` doc comments for public functions and types in protocol-heavy modules, for example `websocket_handler()`, `handle_socket()`, and `handle_message()` in `openmeet-server/src/signaling/handler.rs`, and `Room` methods in `openmeet-server/src/sfu/room.rs`.
## Function Design
- Keep client composables and service helpers small and focused. `useAuth()` in `openmeet-client/src/composables/useAuth.ts` exposes computed state and actor actions only; `handleResponse<T>()` in `openmeet-client/src/services/auth-api.ts` owns HTTP response parsing.
- Keep XState actor functions thin and delegate side effects to services, as `loginActor`, `registerActor`, `checkSessionActor`, and `refreshTokenActor` do in `openmeet-client/src/xstate/machines/auth/index.ts`.
- Rust handlers can contain route-level orchestration, but extract repeated logic into helpers, as `create_tokens()` and `extract_user_id()` do in `openmeet-server/src/auth/handlers.rs`.
- Long protocol functions exist in `openmeet-server/src/signaling/handler.rs` and `openmeet-server/src/sfu/room.rs`; new code should prefer smaller helper functions around specific message/track behaviors.
- Client event handlers generally close over refs/composables rather than accepting many parameters, as `handleLogin()` in `openmeet-client/src/pages/LoginPage.vue` uses `email.value`, `password.value`, and `authActor.send()`.
- Client service functions accept typed request DTOs, for example `LoginRequest`, `RegisterRequest`, and token strings in `openmeet-client/src/services/auth-api.ts`.
- Rust route handlers use Axum extractors in parameter lists, for example `State(state): State<AppState>` and `Json(req): Json<LoginRequest>` in `openmeet-server/src/auth/handlers.rs`.
- Rust async SFU helpers pass IDs as `&str` and shared services as `Arc<dyn ...>` or lock guards, as in `handle_message()` in `openmeet-server/src/signaling/handler.rs`.
- Client composables return plain objects containing computed refs and callable actor methods, as in `openmeet-client/src/composables/useAuth.ts`.
- Client API methods return `Promise<T>` with response interfaces, as in `openmeet-client/src/services/auth-api.ts`.
- XState action helpers mutate context through `assign(...)` and actor results flow through `onDone`/`onError`, as in `openmeet-client/src/xstate/machines/auth/index.ts`.
- Rust HTTP handlers return `Json<T>`, `StatusCode`, or `Result<..., (StatusCode, String)>`, as in `openmeet-server/src/auth/handlers.rs`.
## Module Design
- Client composables export named functions, for example `export function useAuth()` in `openmeet-client/src/composables/useAuth.ts`.
- Client service modules export singleton objects for cohesive API clients, for example `export const authApi` in `openmeet-client/src/services/auth-api.ts`.
- Client type modules export enums, interfaces, and discriminated unions from domain `types.ts` files, for example `openmeet-client/src/xstate/machines/auth/types.ts`.
- Vue UI directories export barrel indexes for primitives, for example `openmeet-client/src/components/ui/button/index.ts`, `openmeet-client/src/components/ui/card/index.ts`, and `openmeet-client/src/components/ui/dialog/index.ts`.
- Rust modules are declared from `openmeet-server/src/main.rs` and grouped by feature directories (`auth`, `db`, `signaling`, `sfu`). Each feature exposes a `mod.rs` such as `openmeet-server/src/auth/mod.rs` and `openmeet-server/src/sfu/mod.rs`.
- Use barrel files for UI primitive folders so consumers import from folder roots, for example `import { Button } from '@/components/ui/button'` in `openmeet-client/src/pages/LoginPage.vue`.
- Avoid adding broad app-level barrels unless there is an existing folder-level convention; current barrels are local to UI primitives and Rust feature modules.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## System Overview
```text
```
## Component Responsibilities
| Component | Responsibility | File |
|-----------|----------------|------|
| Vue app bootstrap | Initialize theme, install router, mount the SPA | `openmeet-client/src/main.ts` |
| App provider shell | Create and provide global auth and WebRTC XState actors | `openmeet-client/src/App.vue` |
| Router | Map SPA routes and enforce cookie/JWT-based navigation guards | `openmeet-client/src/router/index.ts` |
| Auth machine | Own login, registration, session validation, token refresh, logout states | `openmeet-client/src/xstate/machines/auth/index.ts` |
| WebRTC machine | Own meeting lifecycle, participant map, streams, media toggles, chat events | `openmeet-client/src/xstate/machines/webrtc/index.ts` |
| WebRTC actors | Bridge long-lived signaling/WebRTC service objects into XState | `openmeet-client/src/xstate/machines/webrtc/actors.ts` |
| Signaling service | Maintain browser WebSocket connection and typed signaling message dispatch | `openmeet-client/src/services/signaling.ts` |
| Browser WebRTC service | Manage `RTCPeerConnection`, local media, offers/answers, ICE, remote tracks | `openmeet-client/src/services/webrtc-sfu.ts` |
| Auth API client | Call `/auth/*` endpoints and retry `/auth/me` after refresh | `openmeet-client/src/services/auth-api.ts` |
| Server entry point | Configure DB, migrations, JWT, room repository, metrics, routes, TLS | `openmeet-server/src/main.rs` |
| Auth handlers | Register/login/refresh/logout/me with Diesel and Argon2/JWT | `openmeet-server/src/auth/handlers.rs` |
| Signaling handler | Upgrade WebSocket, handle signaling messages, create SFU peer connections | `openmeet-server/src/signaling/handler.rs` |
| Signaling contract | Define client/server message envelope and camelCase JSON variants | `openmeet-server/src/signaling/message.rs` |
| Room repository | Abstract room storage and provide in-memory implementation | `openmeet-server/src/sfu/repository.rs` |
| Room media router | Track participants, forward RTP packets, handle RTCP feedback, cleanup | `openmeet-server/src/sfu/room.rs` |
| Participant connection | Bundle participant metadata, WebSocket sender, peer connection, shutdown signal | `openmeet-server/src/sfu/participant.rs` |
| SFU peer connection | Wrap `RTCPeerConnection` creation, ICE config, SDP handling | `openmeet-server/src/sfu/peer_connection.rs` |
| RTP packet buffer | Store recent RTP packets for NACK retransmission | `openmeet-server/src/sfu/packet_buffer.rs` |
| Deployment reverse proxy | Route public domains to frontend, SFU WebSocket/API, Grafana | `deployment/nginx/nginx.conf` |
## Pattern Overview
- Use Vue page/components for rendering and XState machines for cross-page auth/meeting state (`openmeet-client/src/App.vue`, `openmeet-client/src/xstate/machines/`).
- Use browser service classes for side-effectful APIs that are not serializable XState context (`openmeet-client/src/services/`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`).
- Use Axum route modules for HTTP/WebSocket entry points and domain modules for auth, signaling, and SFU media (`openmeet-server/src/main.rs`).
- Use PostgreSQL only for account/session data; meeting room state and media routing state live in memory (`openmeet-server/src/auth/`, `openmeet-server/src/sfu/repository.rs`).
- Use SFU selective forwarding: each participant has one server-side peer connection, incoming tracks fan out through broadcast channels and per-receiver writer tasks (`openmeet-server/src/sfu/room.rs`).
## Layers
- Purpose: Mount the Vue app, provide global actors, and route users between landing/auth/dashboard/meeting pages.
- Location: `openmeet-client/src/main.ts`, `openmeet-client/src/App.vue`, `openmeet-client/src/router/index.ts`
- Contains: App bootstrap, `<RouterView>`, route guards, page-to-route mapping.
- Depends on: Vue, Vue Router, global XState machines, cookie utilities.
- Used by: All pages and composables.
- Purpose: Render user flows and meeting UI while delegating state transitions to composables/machines.
- Location: `openmeet-client/src/pages/`, `openmeet-client/src/components/`
- Contains: Route-level pages, layout components, meeting controls, video grid, chat panel, shadcn-vue style UI primitives.
- Depends on: `openmeet-client/src/composables/`, `openmeet-client/src/xstate/machines/`, `openmeet-client/src/services/` types.
- Used by: Vue Router and page templates.
- Purpose: Provide typed Vue-computed accessors and event dispatch wrappers around injected XState actors.
- Location: `openmeet-client/src/composables/useAuth.ts`, `openmeet-client/src/composables/useWebrtc.ts`
- Contains: `inject()` calls, computed selectors, action wrappers such as `joinRoom()` and `sendChatMessage()`.
- Depends on: Actors provided by `openmeet-client/src/App.vue`.
- Used by: Pages and components that need auth or meeting state.
- Purpose: Encapsulate browser APIs and network I/O outside Vue components.
- Location: `openmeet-client/src/services/auth-api.ts`, `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/services/webrtc-sfu.ts`
- Contains: Fetch client, WebSocket client, `RTCPeerConnection`, media-device access, event dispatch helpers.
- Depends on: Browser `fetch`, `WebSocket`, `RTCPeerConnection`, `navigator.mediaDevices`, Vite env vars.
- Used by: XState actors in `openmeet-client/src/xstate/machines/`.
- Purpose: Expose process health, metrics, WebSocket signaling, and authentication endpoints.
- Location: `openmeet-server/src/main.rs`, `openmeet-server/src/auth/routes.rs`, `openmeet-server/src/auth/handlers.rs`
- Contains: Axum router, route handlers, CORS, state extraction, HTTP JSON responses.
- Depends on: `AppState`, Diesel pool, JWT config, room repository, Prometheus handle.
- Used by: Browser SPA via `/auth/*`, `/health`, `/metrics`, `/ws`.
- Purpose: Persist users and refresh tokens, hash passwords, issue/validate access tokens.
- Location: `openmeet-server/src/auth/`, `openmeet-server/src/db/mod.rs`, `openmeet-server/src/schema.rs`, `openmeet-server/migrations/`
- Contains: Diesel models, SQL migrations, pool creation, JWT utility, request/response DTOs.
- Depends on: PostgreSQL, Diesel Async, Argon2, jsonwebtoken, SHA-256 refresh-token hashing.
- Used by: Auth route handlers and frontend auth API client.
- Purpose: Convert WebSocket JSON messages into room, peer connection, negotiation, media state, and chat operations.
- Location: `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/signaling/message.rs`
- Contains: WebSocket send/receive tasks, message parsing/serialization, participant ID assignment, room join/leave cleanup.
- Depends on: SFU room/repository/peer abstractions, `tokio::mpsc`, `futures_util`, metrics, tracing.
- Used by: Axum `/ws` route.
- Purpose: Own rooms, participants, server-side peer connections, RTP packet forwarding, RTCP feedback.
- Location: `openmeet-server/src/sfu/`
- Contains: `Room`, `ParticipantConnection`, `SfuPeerConnection`, `RtpPacketBuffer`, `RoomRepository`.
- Depends on: `webrtc` crate, Tokio locks/channels/tasks, tracing, metrics from signaling.
- Used by: Signaling handler.
- Purpose: Build containers, serve SPA, terminate TLS, route domains, expose TURN/STUN and observability.
- Location: `openmeet-client/Dockerfile`, `openmeet-server/Dockerfile`, `deployment/nginx/nginx.conf`, `deployment/coturn/turnserver.conf.template`, `observability/`, `.github/workflows/`
- Contains: Multi-stage builds, Nginx reverse proxy, Prometheus scrape config, Loki config, GitHub Actions build/test/deploy workflows.
- Depends on: Docker Compose files, VPS environment, GitHub Actions, Let's Encrypt cert paths.
- Used by: Local development, production deployment, CI/CD.
## Data Flow
### Primary Meeting Join and Media Path
### Authentication Path
### SFU Forwarding and Renegotiation Flow
### Build, Deploy, and Runtime Flow
- Frontend auth state lives in `authMachine` context and cookie storage (`openmeet-client/src/xstate/machines/auth/index.ts`).
- Frontend meeting state lives in `webrtcMachine` context with a `Map<string, Participant>` and `streamOwnerMap` (`openmeet-client/src/xstate/machines/webrtc/index.ts:12`).
- Non-serializable WebSocket/WebRTC services are module-level singletons in `openmeet-client/src/xstate/machines/webrtc/actors.ts`.
- Server process state lives in `AppState` (`openmeet-server/src/main.rs:31`).
- Server room/media state lives in `InMemoryRoomRepository` with `Arc<RwLock<HashMap<String, Arc<RwLock<Room>>>>>` (`openmeet-server/src/sfu/repository.rs:28`).
- Persistent state is PostgreSQL users and refresh tokens (`openmeet-server/src/schema.rs`).
## Key Abstractions
- Purpose: Make auth and meeting flows explicit, event-driven, and inspectable.
- Examples: `openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`
- Pattern: Machine state + context + invoked actors + actions/guards.
- Purpose: Hide `inject()` and machine event shape behind Vue-friendly computed values and methods.
- Examples: `openmeet-client/src/composables/useAuth.ts`, `openmeet-client/src/composables/useWebrtc.ts`
- Pattern: `inject()` actor, derive `computed()` selectors, return action wrappers.
- Purpose: Own side effects and browser APIs outside Vue rendering and XState context.
- Examples: `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/services/auth-api.ts`
- Pattern: Class or object module with typed methods and callbacks.
- Purpose: Keep browser and server signaling contracts aligned.
- Examples: `openmeet-server/src/signaling/message.rs`, `openmeet-client/src/services/signaling.ts`
- Pattern: Tagged message envelope using `type` with camelCase fields.
- Purpose: Isolate room storage behind a trait so storage can be replaced without rewriting signaling.
- Examples: `openmeet-server/src/sfu/repository.rs`
- Pattern: `async_trait` trait object stored as `Arc<dyn RoomRepository>` in `AppState`.
- Purpose: Aggregate participants, sender tracks, negotiated tracks, and media forwarding tasks for one meeting room.
- Examples: `openmeet-server/src/sfu/room.rs`
- Pattern: Mutable room protected by `Arc<RwLock<Room>>` in repository.
- Purpose: Bundle participant metadata, WebSocket outbound channel, peer connection, and shutdown notification.
- Examples: `openmeet-server/src/sfu/participant.rs`
- Pattern: Data holder with `send()`, `set_peer_connection()`, `get_shutdown_receiver()`.
- Purpose: Wrap WebRTC-rs peer connection setup and SDP/ICE operations with SFU defaults.
- Examples: `openmeet-server/src/sfu/peer_connection.rs`
- Pattern: `Arc<Mutex<SfuPeerConnection>>` wrapping `Arc<RTCPeerConnection>`.
- Purpose: Store recent RTP packets for NACK retransmission per receiver.
- Examples: `openmeet-server/src/sfu/packet_buffer.rs`
- Pattern: `RwLock` protected ring-buffer-like map keyed by sequence number.
## Entry Points
- Location: `openmeet-client/src/main.ts`
- Triggers: Browser loads `openmeet-client/index.html` and Vite bundle.
- Responsibilities: Initialize theme, create Vue app, install router, mount `#app`.
- Location: `openmeet-client/src/router/index.ts`
- Triggers: Browser navigation to `/`, `/login`, `/register`, `/dashboard`, `/room/:id`.
- Responsibilities: Select page components and enforce basic token/cookie navigation rules.
- Location: `openmeet-client/src/pages/MeetingPage.vue`
- Triggers: Route `/room/:id`.
- Responsibilities: Join dialog, media settings, call lifecycle, chat, controls, connection status.
- Location: `openmeet-server/src/main.rs`
- Triggers: Cargo binary or Docker `CMD ["/app/openmeet-server"]`.
- Responsibilities: Load env, migrate DB, create pools/state, install metrics recorder, bind HTTP/TLS server.
- Location: `openmeet-server/src/main.rs`, `openmeet-server/src/auth/routes.rs`
- Triggers: HTTP requests to `/health`, `/metrics`, `/auth/*`, `/ws`.
- Responsibilities: Health, metrics rendering, auth JSON API, WebSocket upgrade.
- Location: `openmeet-server/src/signaling/handler.rs`
- Triggers: Browser `SignalingService.connect()` to SFU `/ws`.
- Responsibilities: Participant lifecycle, signaling message handling, room creation/removal, peer connection setup.
- Location: `.github/workflows/build.yml`, `.github/workflows/test.yml`, `.github/workflows/deploy.yml`
- Triggers: Push/pull request/workflow run on `master`.
- Responsibilities: Build, test, deploy to VPS, run health check.
## Architectural Constraints
- **Threading:** Backend uses Tokio async runtime; WebSocket send/receive, RTP reader/writer, RTCP feedback, and renegotiation use `tokio::spawn` (`openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/sfu/room.rs`). Frontend runs on the browser event loop.
- **Global state:** Frontend WebRTC services are module-level singletons in `openmeet-client/src/xstate/machines/webrtc/actors.ts`. Backend state is centralized in `AppState` (`openmeet-server/src/main.rs`) and repository-owned room maps (`openmeet-server/src/sfu/repository.rs`).
- **Room durability:** Room and media state are in memory only; restarting the SFU process clears all rooms and participant connections (`openmeet-server/src/sfu/repository.rs`).
- **Auth durability:** Users and refresh tokens are persisted in PostgreSQL through Diesel migrations and schema (`openmeet-server/migrations/`, `openmeet-server/src/schema.rs`).
- **Contract duplication:** Signaling message shapes exist in both Rust and TypeScript; update `openmeet-server/src/signaling/message.rs` and `openmeet-client/src/services/signaling.ts` together.
- **NAT traversal:** Client and server both rely on STUN/TURN configuration. Client defaults live in `openmeet-client/src/services/webrtc-sfu.ts`; server peer connection config reads env vars in `openmeet-server/src/signaling/handler.rs` and `openmeet-server/src/sfu/peer_connection.rs`.
- **TLS edge:** Production TLS termination and route selection are owned by Nginx config in `deployment/nginx/nginx.conf`; the Rust server also supports direct TLS through `USE_TLS` in `openmeet-server/src/main.rs`.
- **Background jobs:** No scheduler/queue subsystem exists. Background work is request/connection-scoped Tokio tasks spawned by signaling and room media flows.
- **Submodules:** `openmeet-client/` and `openmeet-server/` are Git submodules declared in `.gitmodules`.
## Anti-Patterns
### Putting side-effect services into XState context
### Changing signaling on one side only
### Adding persistent meeting features to in-memory room state
### Blocking or long-running work inside room write locks
## Error Handling
- Use `Result<Json<T>, (StatusCode, String)>` for auth handlers (`openmeet-server/src/auth/handlers.rs:22`).
- Send `SignalingMessage::Error` over WebSocket for invalid messages and SFU setup failures (`openmeet-server/src/signaling/handler.rs:94`).
- Use XState `onError` transitions for auth and media initialization (`openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`).
- Use `cleanup` + `resetContext` when leaving or retrying calls (`openmeet-client/src/xstate/machines/webrtc/index.ts:448`).
- Log server errors with `tracing::{error,warn,info}` in signaling/SFU modules.
## Cross-Cutting Concerns
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
