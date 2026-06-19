---
type: codebase-map
focus: quality
artifact: conventions
analysis_date: 2026-06-19
---

# Coding Conventions

**Analysis Date:** 2026-06-19

## Naming Patterns

**Files:**
- Vue pages use PascalCase with `Page` suffix in `openmeet-client/src/pages/`, for example `openmeet-client/src/pages/LoginPage.vue`, `openmeet-client/src/pages/DashboardPage.vue`, and `openmeet-client/src/pages/MeetingPage.vue`.
- Vue layout components use `The*` names in `openmeet-client/src/components/layout/`, for example `openmeet-client/src/components/layout/TheNavbar.vue` and `openmeet-client/src/components/layout/TheFooter.vue`.
- Vue feature components use PascalCase under feature folders, for example `openmeet-client/src/components/meeting-page/JoinMeetingDialog.vue`, `openmeet-client/src/components/meeting-page/VideoGrid.vue`, and `openmeet-client/src/components/landing-page/FeatureCard.vue`.
- UI primitives are grouped by kebab-case directory and PascalCase component file, for example `openmeet-client/src/components/ui/button/Button.vue` with `openmeet-client/src/components/ui/button/index.ts`.
- Client composables use `use*` camelCase files in `openmeet-client/src/composables/`, for example `openmeet-client/src/composables/useAuth.ts`, `openmeet-client/src/composables/useTheme.ts`, and `openmeet-client/src/composables/useMediaDevices.ts`.
- Client service files use kebab-case when the domain has multiple words, for example `openmeet-client/src/services/auth-api.ts` and `openmeet-client/src/services/webrtc-sfu.ts`.
- XState machines live in domain folders with `index.ts` and `types.ts`, for example `openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/xstate/machines/auth/types.ts`, and `openmeet-client/src/xstate/machines/webrtc/actors.ts`.
- Rust modules use snake_case file and module names under `openmeet-server/src/`, for example `openmeet-server/src/auth/handlers.rs`, `openmeet-server/src/sfu/peer_connection.rs`, and `openmeet-server/src/signaling/message.rs`.

**Functions:**
- Client exported composables use `use*` names and return grouped reactive state/actions, for example `useAuth()` in `openmeet-client/src/composables/useAuth.ts` and `useTheme()` in `openmeet-client/src/composables/useTheme.ts`.
- Vue event handlers use `handle*` names inside `<script setup>`, for example `handleLogin()` and `handleRetry()` in `openmeet-client/src/pages/LoginPage.vue`.
- Client service methods use verb names inside exported service objects, for example `authApi.login()`, `authApi.register()`, `authApi.refresh()`, `authApi.logout()`, and `authApi.me()` in `openmeet-client/src/services/auth-api.ts`.
- XState actor constants use lower camelCase with `Actor` suffix, for example `loginActor`, `registerActor`, `checkSessionActor`, `refreshTokenActor`, and `logoutActor` in `openmeet-client/src/xstate/machines/auth/index.ts`.
- Rust functions and methods use snake_case, for example `create_pool()` in `openmeet-server/src/db/mod.rs`, `health_check()` in `openmeet-server/src/main.rs`, and `extract_user_id()` in `openmeet-server/src/auth/handlers.rs`.
- Rust handlers are named by route action, for example `register`, `login`, `refresh`, `logout`, and `me` in `openmeet-server/src/auth/handlers.rs`.

**Variables:**
- Client local state and computed values use lower camelCase, for example `isAuthenticating`, `isCheckingSession`, `errorMessage`, and `currentUser` in `openmeet-client/src/composables/useAuth.ts`.
- Client constants that represent environment-derived singleton values use SCREAMING_SNAKE_CASE, for example `API_BASE_URL` in `openmeet-client/src/services/auth-api.ts`.
- XState events are UPPER_SNAKE_CASE enum values, for example `AuthEventType.LOGIN`, `AuthEventType.REFRESH_TOKEN`, and `AuthEventType.GO_TO_REGISTER` in `openmeet-client/src/xstate/machines/auth/types.ts`.
- Rust local variables use snake_case, for example `database_url`, `jwt_secret`, `access_token_minutes`, and `refresh_token_days` in `openmeet-server/src/main.rs`.
- Rust constants use SCREAMING_SNAKE_CASE, for example `MIGRATIONS` in `openmeet-server/src/main.rs` and `RTP_BROADCAST_CAPACITY` in `openmeet-server/src/sfu/room.rs`.

**Types:**
- Client interfaces use PascalCase nouns, for example `User`, `AuthResponse`, `LoginRequest`, and `RegisterRequest` in `openmeet-client/src/services/auth-api.ts`.
- Client enums use PascalCase type names and UPPER_SNAKE_CASE members, for example `AuthState` and `AuthEventType` in `openmeet-client/src/xstate/machines/auth/types.ts`.
- XState event unions are discriminated by `type`, for example `AuthEvents` in `openmeet-client/src/xstate/machines/auth/types.ts`.
- Rust structs and type aliases use PascalCase, for example `AppState` in `openmeet-server/src/main.rs`, `DbPool` in `openmeet-server/src/db/mod.rs`, and `AuthResponse` in `openmeet-server/src/auth/models.rs`.

## Code Style

**Formatting:**
- Use Prettier for client source formatting via `npm run format` / `yarn format`, defined as `prettier --write src/` in `openmeet-client/package.json`.
- ESLint delegates formatting concerns to Prettier through `skipFormatting` from `@vue/eslint-config-prettier/skip-formatting` in `openmeet-client/eslint.config.ts`.
- Client TypeScript and Vue code generally uses 2-space indentation, semicolon-terminated statements in most authored `.ts` files, and single quotes, as shown in `openmeet-client/src/services/auth-api.ts` and `openmeet-client/src/xstate/machines/auth/index.ts`.
- Some generated or scaffolded config files omit semicolons, for example `openmeet-client/eslint.config.ts` and `openmeet-client/playwright.config.ts`; follow the surrounding file style when editing config.
- Rust formatting follows standard `rustfmt` conventions: 4-space indentation, snake_case names, grouped `use` statements, and trailing commas in multi-line structures, as shown in `openmeet-server/src/main.rs` and `openmeet-server/src/auth/handlers.rs`.

**Linting:**
- Run client lint with `yarn lint` or `npm run lint` from `openmeet-client/`; this runs `lint:oxlint` then `lint:eslint` via `run-s lint:*` in `openmeet-client/package.json`.
- `lint:oxlint` runs `oxlint . --fix -D correctness --ignore-path .gitignore` from `openmeet-client/package.json`.
- `lint:eslint` runs `eslint . --fix --cache` from `openmeet-client/package.json`.
- ESLint targets `**/*.{ts,mts,tsx,vue}` and ignores `**/dist/**`, `**/dist-ssr/**`, and `**/coverage/**` in `openmeet-client/eslint.config.ts`.
- ESLint uses `eslint-plugin-vue` essential rules, `@vue/eslint-config-typescript` recommended rules, Vitest rules for `src/**/__tests__/*`, Playwright rules for `e2e/**/*.{test,spec}.{js,ts,jsx,tsx}`, and Oxlint recommended rules in `openmeet-client/eslint.config.ts`.
- Project-specific ESLint relaxations are explicit: `@typescript-eslint/no-explicit-any` is off and `vue/multi-word-component-names` is off in `openmeet-client/eslint.config.ts`.
- Rust CI runs `cargo check`, `cargo check --release`, and `cargo test`; Clippy is present but commented out in `.github/workflows/test.yml`.

## Import Organization

**Order:**
1. Standard library / Node imports first, for example `node:url` in `openmeet-client/vitest.config.ts` and `std::net::SocketAddr` in `openmeet-server/src/main.rs`.
2. External package imports next, for example Vue, XState, Router, and UI library imports in `openmeet-client/src/pages/LoginPage.vue`, or Axum/Diesel/Tokio imports in `openmeet-server/src/auth/handlers.rs`.
3. Absolute app imports using `@/` next in client code, for example `@/services/auth-api` and `@/utils` in `openmeet-client/src/xstate/machines/auth/index.ts`.
4. Relative local imports last, for example `./types` in `openmeet-client/src/xstate/machines/auth/index.ts` and crate-local `crate::...` imports in server modules like `openmeet-server/src/auth/handlers.rs`.

**Path Aliases:**
- Use `@/*` for client source imports; it maps to `./src/*` in `openmeet-client/tsconfig.json` and resolves to `src` in `openmeet-client/vite.config.ts`.
- Prefer `@/components/...`, `@/composables/...`, `@/services/...`, and `@/xstate/...` over deep relative paths in client code, as shown in `openmeet-client/src/pages/LoginPage.vue` and `openmeet-client/src/xstate/machines/auth/index.ts`.
- Server modules use explicit `crate::` paths for cross-module references, for example `crate::auth`, `crate::db`, `crate::schema`, and `crate::sfu` in `openmeet-server/src/main.rs` and `openmeet-server/src/auth/handlers.rs`.

## Error Handling

**Patterns:**
- Client composables that require injection should fail fast with `throw new Error(...)`, as in `useAuth()` in `openmeet-client/src/composables/useAuth.ts` and the auth actor check in `openmeet-client/src/pages/LoginPage.vue`.
- Client API wrappers should centralize HTTP error translation through a helper. `handleResponse<T>()` in `openmeet-client/src/services/auth-api.ts` checks `response.ok`, reads `response.text()`, and throws `AuthApiError` with a status.
- Client utility parsing should return safe nullable/falsy values instead of throwing for invalid user-controlled input, as `jwtUtils.parse()` returns `null` in `openmeet-client/src/utils.ts`.
- Client retryable API flows should catch and degrade locally when appropriate, for example `authApi.me()` attempts `refresh()` and uses `.catch(() => null)` in `openmeet-client/src/services/auth-api.ts`.
- XState machines should map actor failures into explicit failure states and store readable errors in context through `setError`, as in `openmeet-client/src/xstate/machines/auth/index.ts`.
- Rust HTTP handlers should return `Result<_, (StatusCode, String)>` aliases and convert fallible operations with `.map_err(...)`, as `ApiResult<T>` and auth handlers do in `openmeet-server/src/auth/handlers.rs`.
- Rust startup code can use `.expect(...)` for required environment/configuration failures, for example `DATABASE_URL`, `JWT_SECRET`, migrations, and TLS certificate loading in `openmeet-server/src/main.rs`.
- Rust domain/service code should prefer `anyhow::Result` for internal WebRTC/SFU operations where errors are propagated across async boundaries, as in `openmeet-server/src/sfu/peer_connection.rs` and `openmeet-server/src/sfu/repository.rs`.

## Logging

**Framework:**
- Client: direct `console.log` / `console.error` in WebRTC, signaling, preview, and current tests.
- Server: `tracing` macros (`info!`, `warn!`, `error!`, `debug!`) initialized by `tracing_subscriber::fmt()` in `openmeet-server/src/main.rs`.

**Patterns:**
- Server startup and infrastructure logs use `info!`, for example database pool and metrics initialization in `openmeet-server/src/main.rs`.
- Server WebSocket and SFU flows use structured component messages with participant and room IDs, for example `openmeet-server/src/signaling/handler.rs` and `openmeet-server/src/sfu/room.rs`.
- Server recoverable failures use `warn!`, for example invalid signaling messages in `openmeet-server/src/signaling/handler.rs` and missing participants in `openmeet-server/src/sfu/room.rs`.
- Server operation failures use `error!`, for example send/serialization failures in `openmeet-server/src/signaling/handler.rs`.
- Client WebRTC and signaling services prefix logs with component tags like `[WebRTCServiceSFU]`, `[SignalingService]`, and `[webrtcMachine]` in `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/services/signaling.ts`, and `openmeet-client/src/xstate/machines/webrtc/actors.ts`.
- Avoid untagged debug logging in new tests and source. Existing untagged logs appear in `openmeet-client/src/composables/__tests__/useAuth.test.ts` and `openmeet-client/src/composables/__tests__/useAuth.browser.test.ts`.

## Comments

**When to Comment:**
- Use comments for non-obvious architecture, lifecycle, and protocol behavior, for example WebSocket task roles in `openmeet-server/src/signaling/handler.rs`, refresh-token semantics in `openmeet-client/src/router/index.ts`, and room cleanup semantics in `openmeet-server/src/sfu/room.rs`.
- Use comments for operational constraints, for example TLS and NAT/TURN/STUN configuration in `openmeet-server/src/main.rs` and `openmeet-server/src/signaling/handler.rs`.
- Avoid comments that simply restate names. Existing simple section comments in `openmeet-server/src/auth/handlers.rs` are acceptable for route grouping but new comments should explain why/constraints.

**JSDoc/TSDoc:**
- Client code does not use a JSDoc/TSDoc convention. Prefer TypeScript interfaces and clear function names over docblocks in files like `openmeet-client/src/services/auth-api.ts` and `openmeet-client/src/xstate/machines/auth/types.ts`.
- Rust uses `///` doc comments for public functions and types in protocol-heavy modules, for example `websocket_handler()`, `handle_socket()`, and `handle_message()` in `openmeet-server/src/signaling/handler.rs`, and `Room` methods in `openmeet-server/src/sfu/room.rs`.

## Function Design

**Size:**
- Keep client composables and service helpers small and focused. `useAuth()` in `openmeet-client/src/composables/useAuth.ts` exposes computed state and actor actions only; `handleResponse<T>()` in `openmeet-client/src/services/auth-api.ts` owns HTTP response parsing.
- Keep XState actor functions thin and delegate side effects to services, as `loginActor`, `registerActor`, `checkSessionActor`, and `refreshTokenActor` do in `openmeet-client/src/xstate/machines/auth/index.ts`.
- Rust handlers can contain route-level orchestration, but extract repeated logic into helpers, as `create_tokens()` and `extract_user_id()` do in `openmeet-server/src/auth/handlers.rs`.
- Long protocol functions exist in `openmeet-server/src/signaling/handler.rs` and `openmeet-server/src/sfu/room.rs`; new code should prefer smaller helper functions around specific message/track behaviors.

**Parameters:**
- Client event handlers generally close over refs/composables rather than accepting many parameters, as `handleLogin()` in `openmeet-client/src/pages/LoginPage.vue` uses `email.value`, `password.value`, and `authActor.send()`.
- Client service functions accept typed request DTOs, for example `LoginRequest`, `RegisterRequest`, and token strings in `openmeet-client/src/services/auth-api.ts`.
- Rust route handlers use Axum extractors in parameter lists, for example `State(state): State<AppState>` and `Json(req): Json<LoginRequest>` in `openmeet-server/src/auth/handlers.rs`.
- Rust async SFU helpers pass IDs as `&str` and shared services as `Arc<dyn ...>` or lock guards, as in `handle_message()` in `openmeet-server/src/signaling/handler.rs`.

**Return Values:**
- Client composables return plain objects containing computed refs and callable actor methods, as in `openmeet-client/src/composables/useAuth.ts`.
- Client API methods return `Promise<T>` with response interfaces, as in `openmeet-client/src/services/auth-api.ts`.
- XState action helpers mutate context through `assign(...)` and actor results flow through `onDone`/`onError`, as in `openmeet-client/src/xstate/machines/auth/index.ts`.
- Rust HTTP handlers return `Json<T>`, `StatusCode`, or `Result<..., (StatusCode, String)>`, as in `openmeet-server/src/auth/handlers.rs`.

## Module Design

**Exports:**
- Client composables export named functions, for example `export function useAuth()` in `openmeet-client/src/composables/useAuth.ts`.
- Client service modules export singleton objects for cohesive API clients, for example `export const authApi` in `openmeet-client/src/services/auth-api.ts`.
- Client type modules export enums, interfaces, and discriminated unions from domain `types.ts` files, for example `openmeet-client/src/xstate/machines/auth/types.ts`.
- Vue UI directories export barrel indexes for primitives, for example `openmeet-client/src/components/ui/button/index.ts`, `openmeet-client/src/components/ui/card/index.ts`, and `openmeet-client/src/components/ui/dialog/index.ts`.
- Rust modules are declared from `openmeet-server/src/main.rs` and grouped by feature directories (`auth`, `db`, `signaling`, `sfu`). Each feature exposes a `mod.rs` such as `openmeet-server/src/auth/mod.rs` and `openmeet-server/src/sfu/mod.rs`.

**Barrel Files:**
- Use barrel files for UI primitive folders so consumers import from folder roots, for example `import { Button } from '@/components/ui/button'` in `openmeet-client/src/pages/LoginPage.vue`.
- Avoid adding broad app-level barrels unless there is an existing folder-level convention; current barrels are local to UI primitives and Rust feature modules.

---

*Convention analysis: 2026-06-19*
