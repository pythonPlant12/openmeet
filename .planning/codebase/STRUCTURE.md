---
doc_type: codebase-map
focus: arch
status: current
refreshed: 2026-06-19
---

# Codebase Structure

**Analysis Date:** 2026-06-19

## Directory Layout

```text
openmeet/
├── .github/workflows/          # GitHub Actions build, test, deploy pipelines
├── .planning/codebase/         # Generated GSD codebase maps
├── certs/                      # Development TLS certificate files
├── deployment/                 # Production edge service configuration
│   ├── coturn/                 # TURN server config template
│   └── nginx/                  # Public Nginx reverse-proxy config
├── docs/                       # Root documentation and system overview
├── observability/              # Prometheus, Loki, Promtail, Grafana config
├── openmeet-client/            # Vue 3 / TypeScript SPA submodule
│   ├── docs/                   # Client documentation
│   ├── public/                 # Static assets copied by Vite
│   ├── src/                    # Client application source
│   │   ├── assets/             # Global CSS and static source assets
│   │   ├── components/         # Vue UI/layout/meeting components
│   │   ├── composables/        # Vue composables for actor/service access
│   │   ├── config/             # Client configuration modules
│   │   ├── lib/                # Shared UI/library helpers
│   │   ├── pages/              # Route-level page components
│   │   ├── router/             # Vue Router configuration
│   │   ├── services/           # HTTP, WebSocket, WebRTC service wrappers
│   │   ├── xstate/             # State-machine definitions and types
│   │   ├── App.vue             # App shell and global actor providers
│   │   ├── main.ts             # Browser entry point
│   │   └── utils.ts            # Cookie and JWT utilities
│   ├── Dockerfile              # Frontend multi-stage Docker build
│   ├── docker-nginx.conf       # Container-local SPA Nginx config
│   ├── package.json            # Client dependencies and scripts
│   ├── vite.config.ts          # Vite and path alias config
│   └── yarn.lock               # Client package lockfile
├── openmeet-server/            # Rust Axum SFU/API submodule
│   ├── docs/                   # Server documentation
│   ├── migrations/             # Diesel PostgreSQL migrations
│   ├── src/                    # Server source
│   │   ├── auth/               # Auth routes, handlers, DTOs, JWT
│   │   ├── db/                 # Diesel Async pool setup
│   │   ├── sfu/                # Room, participant, peer, media forwarding
│   │   ├── signaling/          # WebSocket signaling handler and contracts
│   │   ├── main.rs             # Server entry point
│   │   └── schema.rs           # Generated Diesel schema
│   ├── Cargo.toml              # Rust package/dependencies
│   ├── diesel.toml             # Diesel CLI config
│   └── Dockerfile              # Backend multi-stage Docker build
├── .gitmodules                 # Client/server submodule declarations
├── deploy.sh                   # VPS deployment script
├── docker-compose.dev.yml      # Development service orchestration
├── docker-compose.yaml         # Production service orchestration
├── init-ssl.sh                 # Development SSL setup helper
└── Makefile                    # Docker Compose convenience targets
```

## Directory Purposes

**Root repository:**
- Purpose: Compose the frontend and backend submodules with deployment, observability, and documentation.
- Contains: `openmeet-client/`, `openmeet-server/`, `deployment/`, `observability/`, `docs/`, `.github/workflows/`.
- Key files: `.gitmodules`, `Makefile`, `deploy.sh`, `docker-compose.dev.yml`, `docker-compose.yaml`, `docs/README.md`.

**`openmeet-client/`:**
- Purpose: Browser SPA for authentication, dashboard, room joining, video grid, chat, and controls.
- Contains: Vue source, Vite config, Tailwind config, test config, Docker build files.
- Key files: `openmeet-client/src/main.ts`, `openmeet-client/src/App.vue`, `openmeet-client/src/router/index.ts`, `openmeet-client/package.json`, `openmeet-client/vite.config.ts`.

**`openmeet-client/src/pages/`:**
- Purpose: Route-level Vue pages.
- Contains: Auth pages, dashboard, landing, meeting room, 404.
- Key files: `openmeet-client/src/pages/MeetingPage.vue`, `openmeet-client/src/pages/LoginPage.vue`, `openmeet-client/src/pages/RegisterPage.vue`, `openmeet-client/src/pages/DashboardPage.vue`, `openmeet-client/src/pages/LandingPage.vue`, `openmeet-client/src/pages/NotFoundPage.vue`.

**`openmeet-client/src/components/`:**
- Purpose: Reusable Vue components grouped by feature and UI primitive families.
- Contains: `layout/`, `landing-page/`, `meeting-page/`, `ui/`.
- Key files: `openmeet-client/src/components/layout/TheNavbar.vue`, `openmeet-client/src/components/meeting-page/VideoGrid.vue`, `openmeet-client/src/components/meeting-page/ParticipantTile.vue`, `openmeet-client/src/components/meeting-page/MeetingControls.vue`, `openmeet-client/src/components/meeting-page/ChatPanel.vue`.

**`openmeet-client/src/components/ui/`:**
- Purpose: Shadcn-vue/reka-style UI primitives with component folders and `index.ts` barrels.
- Contains: `button/`, `badge/`, `dialog/`, `dropdown-menu/`, `scroll-area/`, `sheet/`, `spinner/`.
- Key files: `openmeet-client/src/components/ui/button/Button.vue`, `openmeet-client/src/components/ui/dialog/index.ts`, `openmeet-client/src/components/ui/sheet/index.ts`.

**`openmeet-client/src/composables/`:**
- Purpose: Vue composables for state-machine access and browser/UI behaviors.
- Contains: Injected actor accessors, fullscreen lock, media device discovery, theme initialization.
- Key files: `openmeet-client/src/composables/useAuth.ts`, `openmeet-client/src/composables/useWebrtc.ts`, `openmeet-client/src/composables/useMediaDevices.ts`, `openmeet-client/src/composables/useTheme.ts`, `openmeet-client/src/composables/useFullscreenLock.ts`.

**`openmeet-client/src/services/`:**
- Purpose: Side-effectful client integrations with backend HTTP, WebSocket signaling, and browser WebRTC APIs.
- Contains: Auth API client, signaling service, SFU WebRTC service.
- Key files: `openmeet-client/src/services/auth-api.ts`, `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/services/webrtc-sfu.ts`.

**`openmeet-client/src/xstate/`:**
- Purpose: Application state machines and typed machine contracts.
- Contains: `machines/auth/` and `machines/webrtc/`.
- Key files: `openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/xstate/machines/auth/types.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`, `openmeet-client/src/xstate/machines/webrtc/types.ts`.

**`openmeet-client/src/router/`:**
- Purpose: SPA route mapping and navigation guards.
- Contains: Router singleton.
- Key files: `openmeet-client/src/router/index.ts`.

**`openmeet-client/src/lib/` and `openmeet-client/src/config/`:**
- Purpose: Shared helpers and branded configuration.
- Contains: Utility class merging/color helpers and branding config.
- Key files: `openmeet-client/src/lib/utils.ts`, `openmeet-client/src/lib/colors.ts`, `openmeet-client/src/config/branding.config.ts`.

**`openmeet-server/`:**
- Purpose: Rust backend that exposes auth HTTP APIs, WebSocket signaling, SFU media routing, metrics, and health endpoints.
- Contains: Rust source, Diesel migrations, Dockerfile, server docs.
- Key files: `openmeet-server/src/main.rs`, `openmeet-server/Cargo.toml`, `openmeet-server/diesel.toml`, `openmeet-server/Dockerfile`.

**`openmeet-server/src/auth/`:**
- Purpose: User registration/login/session API.
- Contains: Route definitions, handlers, JWT utility, Diesel models and request/response DTOs.
- Key files: `openmeet-server/src/auth/routes.rs`, `openmeet-server/src/auth/handlers.rs`, `openmeet-server/src/auth/jwt.rs`, `openmeet-server/src/auth/models.rs`, `openmeet-server/src/auth/mod.rs`.

**`openmeet-server/src/signaling/`:**
- Purpose: WebSocket protocol, participant lifecycle, SDP/ICE/media-state/chat signaling.
- Contains: Handler and message enum.
- Key files: `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/signaling/message.rs`, `openmeet-server/src/signaling/mod.rs`.

**`openmeet-server/src/sfu/`:**
- Purpose: Selective forwarding unit domain model and media forwarding logic.
- Contains: Room repository, rooms, participants, peer connection wrapper, RTP packet buffer.
- Key files: `openmeet-server/src/sfu/repository.rs`, `openmeet-server/src/sfu/room.rs`, `openmeet-server/src/sfu/participant.rs`, `openmeet-server/src/sfu/peer_connection.rs`, `openmeet-server/src/sfu/packet_buffer.rs`, `openmeet-server/src/sfu/mod.rs`.

**`openmeet-server/src/db/`:**
- Purpose: Async PostgreSQL connection pool setup.
- Contains: Type alias and pool builder.
- Key files: `openmeet-server/src/db/mod.rs`.

**`openmeet-server/migrations/`:**
- Purpose: PostgreSQL schema creation for durable auth data.
- Contains: Diesel migration directories.
- Key files: `openmeet-server/migrations/20251201000000_create_users/up.sql`, `openmeet-server/migrations/20251201000001_create_refresh_tokens/up.sql`.

**`deployment/`:**
- Purpose: Production edge networking configuration.
- Contains: Nginx reverse proxy config and Coturn template.
- Key files: `deployment/nginx/nginx.conf`, `deployment/coturn/turnserver.conf.template`.

**`observability/`:**
- Purpose: Metrics and log collection configuration.
- Contains: Prometheus scrape config, Loki, Promtail, Grafana directory.
- Key files: `observability/prometheus.yaml`, `observability/loki-config.yaml`, `observability/promtail-config.yaml`, `observability/grafana/`.

**`.github/workflows/`:**
- Purpose: CI/CD automation.
- Contains: Build, test, and deploy workflows.
- Key files: `.github/workflows/build.yml`, `.github/workflows/test.yml`, `.github/workflows/deploy.yml`.

## Key File Locations

**Entry Points:**
- `openmeet-client/src/main.ts`: Browser app bootstrap.
- `openmeet-client/src/App.vue`: Root component and global actor providers.
- `openmeet-client/src/router/index.ts`: SPA route table and auth guard.
- `openmeet-server/src/main.rs`: Backend process startup, route registration, migrations, metrics, TLS.
- `deploy.sh`: Production VPS deployment entry script.
- `Makefile`: Local Docker Compose convenience entry points.

**Configuration:**
- `openmeet-client/vite.config.ts`: Vite plugins, dev server, `@` alias.
- `openmeet-client/tsconfig.app.json`: TypeScript app compiler options and path alias.
- `openmeet-client/tailwind.config.js`: Tailwind CSS configuration.
- `openmeet-client/eslint.config.ts`: Client lint configuration.
- `openmeet-client/vitest.config.ts`: Client unit test configuration.
- `openmeet-client/playwright.config.ts`: Client E2E test configuration.
- `openmeet-server/Cargo.toml`: Rust package dependencies.
- `openmeet-server/diesel.toml`: Diesel schema generation config.
- `deployment/nginx/nginx.conf`: Public HTTP/TLS routing.
- `deployment/coturn/turnserver.conf.template`: TURN server template.
- `observability/prometheus.yaml`: Metrics scrape targets.
- `.github/workflows/build.yml`: Build pipeline.
- `.github/workflows/test.yml`: Test pipeline.
- `.github/workflows/deploy.yml`: Deploy pipeline.

**Core Logic:**
- `openmeet-client/src/xstate/machines/auth/index.ts`: Auth state transitions and invoked actors.
- `openmeet-client/src/xstate/machines/webrtc/index.ts`: Meeting state transitions and participant/stream context.
- `openmeet-client/src/xstate/machines/webrtc/actors.ts`: Signaling/WebRTC service lifecycle and callbacks.
- `openmeet-client/src/services/signaling.ts`: Browser WebSocket signaling protocol wrapper.
- `openmeet-client/src/services/webrtc-sfu.ts`: Browser WebRTC peer connection and media logic.
- `openmeet-client/src/pages/MeetingPage.vue`: Meeting UI orchestration.
- `openmeet-server/src/signaling/handler.rs`: WebSocket message dispatch and SFU join/negotiation logic.
- `openmeet-server/src/signaling/message.rs`: Rust signaling message contract.
- `openmeet-server/src/sfu/room.rs`: Room membership and RTP/RTCP forwarding.
- `openmeet-server/src/sfu/peer_connection.rs`: WebRTC-rs peer connection configuration.
- `openmeet-server/src/sfu/repository.rs`: Room storage abstraction.
- `openmeet-server/src/auth/handlers.rs`: Auth API implementation.

**Data and Persistence:**
- `openmeet-server/src/db/mod.rs`: Async PostgreSQL pool.
- `openmeet-server/src/schema.rs`: Generated Diesel schema for `users` and `refresh_tokens`.
- `openmeet-server/migrations/20251201000000_create_users/up.sql`: Users table and email index.
- `openmeet-server/migrations/20251201000001_create_refresh_tokens/up.sql`: Refresh token table and indexes.

**Testing:**
- `openmeet-client/src/xstate/machines/auth/__tests__/auth.machine.test.ts`: Auth machine unit tests.
- `openmeet-server/src/signaling/message.rs`: Inline Rust tests for signaling serialization.
- `openmeet-server/src/sfu/repository.rs`: Inline Rust tests for room repository.
- `openmeet-server/src/sfu/peer_connection.rs`: Inline Rust tests for peer connection creation/config.
- `openmeet-client/vitest.config.ts`: Unit test runner config.
- `openmeet-client/playwright.config.ts`: E2E test runner config.
- `.github/workflows/test.yml`: CI test commands for frontend and backend.

**Build and Runtime:**
- `openmeet-client/Dockerfile`: Build Vue app and serve static files from Nginx.
- `openmeet-client/docker-nginx.conf`: SPA fallback, assets cache, health check.
- `openmeet-server/Dockerfile`: Compile Rust binary and run slim Debian image.
- `docker-compose.dev.yml`: Local development services.
- `docker-compose.yaml`: Production services.
- `deployment/nginx/nginx.conf`: Public reverse proxy for frontend, SFU, Grafana.

## Naming Conventions

**Files:**
- Vue route pages use PascalCase with `Page` suffix: `openmeet-client/src/pages/MeetingPage.vue`, `openmeet-client/src/pages/LoginPage.vue`.
- Vue layout components use `The` prefix for app-wide shell components: `openmeet-client/src/components/layout/TheNavbar.vue`, `openmeet-client/src/components/layout/TheFooter.vue`.
- Vue feature components use PascalCase and live under feature folders: `openmeet-client/src/components/meeting-page/ParticipantTile.vue`.
- Vue composables use `useX.ts`: `openmeet-client/src/composables/useAuth.ts`, `openmeet-client/src/composables/useWebrtc.ts`.
- Client service modules use kebab-case or domain names: `openmeet-client/src/services/auth-api.ts`, `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/services/signaling.ts`.
- XState machine folders contain `index.ts`, `types.ts`, and optional `actors.ts`: `openmeet-client/src/xstate/machines/webrtc/index.ts`.
- Rust modules use snake_case: `openmeet-server/src/sfu/peer_connection.rs`, `openmeet-server/src/sfu/packet_buffer.rs`.
- Rust module directories expose `mod.rs`: `openmeet-server/src/auth/mod.rs`, `openmeet-server/src/sfu/mod.rs`, `openmeet-server/src/signaling/mod.rs`.
- Diesel migrations use timestamped directories with `up.sql` and `down.sql`: `openmeet-server/migrations/20251201000000_create_users/up.sql`.

**Directories:**
- Client source directories are feature/layer nouns: `pages`, `components`, `composables`, `services`, `xstate`, `router`.
- Meeting-specific components live under `openmeet-client/src/components/meeting-page/`.
- UI primitives live under component-family folders with barrels: `openmeet-client/src/components/ui/dialog/index.ts`.
- Server source directories are backend domains: `auth`, `db`, `signaling`, `sfu`.
- Deployment support is split by service: `deployment/nginx/`, `deployment/coturn/`, `observability/`.

## Where to Add New Code

**New frontend route/page:**
- Primary code: `openmeet-client/src/pages/NewFeaturePage.vue`
- Route registration: `openmeet-client/src/router/index.ts`
- Shared layout/UI: `openmeet-client/src/components/layout/` or `openmeet-client/src/components/<feature-name>/`
- Tests: `openmeet-client/src/**/__tests__/` or matching Vitest location.

**New meeting UI component:**
- Primary code: `openmeet-client/src/components/meeting-page/<ComponentName>.vue`
- State access: use `openmeet-client/src/composables/useWebrtc.ts`
- Types: update `openmeet-client/src/xstate/machines/webrtc/types.ts` when component needs new machine events/context.

**New shared UI primitive:**
- Implementation: `openmeet-client/src/components/ui/<primitive-name>/<PrimitiveName>.vue`
- Barrel export: `openmeet-client/src/components/ui/<primitive-name>/index.ts`
- Styling helpers: use `openmeet-client/src/lib/utils.ts` and existing Tailwind patterns.

**New frontend API integration:**
- Primary code: `openmeet-client/src/services/<domain>-api.ts`
- State orchestration: add actor/actions to `openmeet-client/src/xstate/machines/<domain>/` or existing machine.
- UI access: expose computed/actions through `openmeet-client/src/composables/`.
- Env config: read Vite env vars in service modules, not components.

**New WebSocket signaling message:**
- Server contract: `openmeet-server/src/signaling/message.rs`
- Client contract: `openmeet-client/src/services/signaling.ts`
- Server behavior: `openmeet-server/src/signaling/handler.rs`
- Client behavior: `openmeet-client/src/xstate/machines/webrtc/actors.ts` and `openmeet-client/src/xstate/machines/webrtc/index.ts`
- UI trigger/display: `openmeet-client/src/pages/MeetingPage.vue` or `openmeet-client/src/components/meeting-page/`.

**New auth endpoint:**
- Route: `openmeet-server/src/auth/routes.rs`
- Handler: `openmeet-server/src/auth/handlers.rs`
- Request/response models: `openmeet-server/src/auth/models.rs`
- Client API: `openmeet-client/src/services/auth-api.ts`
- Client machine changes: `openmeet-client/src/xstate/machines/auth/index.ts` and `openmeet-client/src/xstate/machines/auth/types.ts`.

**New persistent backend table:**
- Migration: `openmeet-server/migrations/<timestamp>_<description>/up.sql` and `down.sql`
- Schema update: regenerate/update `openmeet-server/src/schema.rs` through Diesel CLI conventions.
- Models: add to appropriate domain file such as `openmeet-server/src/auth/models.rs` or create a new domain under `openmeet-server/src/<domain>/`.
- DB access: use `state.pool.get().await` pattern from `openmeet-server/src/auth/handlers.rs`.

**New SFU/media behavior:**
- Room-level behavior: `openmeet-server/src/sfu/room.rs`
- Participant metadata: `openmeet-server/src/sfu/participant.rs`
- Peer connection setup: `openmeet-server/src/sfu/peer_connection.rs`
- Packet retransmission/buffering: `openmeet-server/src/sfu/packet_buffer.rs`
- Signaling trigger: `openmeet-server/src/signaling/handler.rs`

**New room storage implementation:**
- Trait: extend `openmeet-server/src/sfu/repository.rs`
- Implementation: add a new repository module under `openmeet-server/src/sfu/` and export it from `openmeet-server/src/sfu/mod.rs`
- Wiring: replace `InMemoryRoomRepository::new()` in `openmeet-server/src/main.rs`

**New observability target/dashboard:**
- Metrics emission: backend module where event occurs, using existing `metrics` crate patterns in `openmeet-server/src/signaling/handler.rs`
- Scrape config: `observability/prometheus.yaml`
- Dashboard/config: `observability/grafana/`
- Reverse proxy, if public: `deployment/nginx/nginx.conf`

**New deployment service:**
- Service config: `deployment/<service>/`
- Container wiring: `docker-compose.dev.yml` and `docker-compose.yaml`
- CI/CD changes: `.github/workflows/build.yml`, `.github/workflows/test.yml`, `.github/workflows/deploy.yml`
- Deployment script changes: `deploy.sh`

## Special Directories

**`openmeet-client/node_modules/`:**
- Purpose: Installed client dependencies.
- Generated: Yes
- Committed: No

**`openmeet-server/target/`:**
- Purpose: Cargo build outputs.
- Generated: Yes
- Committed: No

**`openmeet-client/dist/`:**
- Purpose: Vite production build output uploaded/served by Docker build.
- Generated: Yes
- Committed: No

**`openmeet-server/src/schema.rs`:**
- Purpose: Diesel schema generated from migrations.
- Generated: Yes
- Committed: Yes

**`openmeet-server/migrations/`:**
- Purpose: Durable database schema history.
- Generated: No
- Committed: Yes

**`certs/` and `openmeet-server/certs/`:**
- Purpose: Development TLS certificate material.
- Generated: Yes
- Committed: Contains certificate-related files; do not read or quote private key contents.

**`.env*` files in root/client/server:**
- Purpose: Environment configuration for local and production runtime.
- Generated: User-created from examples
- Committed: Examples only; do not read or quote real env contents.

**`.planning/codebase/`:**
- Purpose: GSD codebase-map outputs consumed by planning/execution commands.
- Generated: Yes
- Committed: Intended project documentation.

**`.github/workflows/`:**
- Purpose: GitHub-hosted build, test, and deploy automations.
- Generated: No
- Committed: Yes

---

*Structure analysis: 2026-06-19*
