---
doc_type: codebase-map
focus: arch
status: current
refreshed: 2026-06-19
---

<!-- refreshed: 2026-06-19 -->
# Architecture

**Analysis Date:** 2026-06-19

## System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                    Browser Vue SPA                          │
│        `openmeet-client/src/main.ts`                         │
├──────────────────┬──────────────────┬───────────────────────┤
│ Vue Pages        │ XState Machines  │ Browser Services      │
│ `src/pages/`     │ `src/xstate/`    │ `src/services/`       │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │ HTTP /auth       │ WebSocket /ws      │ WebRTC media
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│               Rust Axum SFU/API Server                      │
│          `openmeet-server/src/main.rs`                       │
├──────────────────┬──────────────────┬───────────────────────┤
│ Auth API         │ Signaling        │ SFU Media Router      │
│ `src/auth/`      │ `src/signaling/` │ `src/sfu/`            │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│ PostgreSQL, in-memory room state, TURN/STUN, metrics/logging │
│ `openmeet-server/migrations/`, `deployment/`, `observability/`│
└─────────────────────────────────────────────────────────────┘
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

**Overall:** Split frontend/backend client-server architecture with a browser-managed state-machine UI and a Rust Axum SFU backend.

**Key Characteristics:**
- Use Vue page/components for rendering and XState machines for cross-page auth/meeting state (`openmeet-client/src/App.vue`, `openmeet-client/src/xstate/machines/`).
- Use browser service classes for side-effectful APIs that are not serializable XState context (`openmeet-client/src/services/`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`).
- Use Axum route modules for HTTP/WebSocket entry points and domain modules for auth, signaling, and SFU media (`openmeet-server/src/main.rs`).
- Use PostgreSQL only for account/session data; meeting room state and media routing state live in memory (`openmeet-server/src/auth/`, `openmeet-server/src/sfu/repository.rs`).
- Use SFU selective forwarding: each participant has one server-side peer connection, incoming tracks fan out through broadcast channels and per-receiver writer tasks (`openmeet-server/src/sfu/room.rs`).

## Layers

**Frontend shell and routing:**
- Purpose: Mount the Vue app, provide global actors, and route users between landing/auth/dashboard/meeting pages.
- Location: `openmeet-client/src/main.ts`, `openmeet-client/src/App.vue`, `openmeet-client/src/router/index.ts`
- Contains: App bootstrap, `<RouterView>`, route guards, page-to-route mapping.
- Depends on: Vue, Vue Router, global XState machines, cookie utilities.
- Used by: All pages and composables.

**Frontend pages and UI components:**
- Purpose: Render user flows and meeting UI while delegating state transitions to composables/machines.
- Location: `openmeet-client/src/pages/`, `openmeet-client/src/components/`
- Contains: Route-level pages, layout components, meeting controls, video grid, chat panel, shadcn-vue style UI primitives.
- Depends on: `openmeet-client/src/composables/`, `openmeet-client/src/xstate/machines/`, `openmeet-client/src/services/` types.
- Used by: Vue Router and page templates.

**Frontend composable state access:**
- Purpose: Provide typed Vue-computed accessors and event dispatch wrappers around injected XState actors.
- Location: `openmeet-client/src/composables/useAuth.ts`, `openmeet-client/src/composables/useWebrtc.ts`
- Contains: `inject()` calls, computed selectors, action wrappers such as `joinRoom()` and `sendChatMessage()`.
- Depends on: Actors provided by `openmeet-client/src/App.vue`.
- Used by: Pages and components that need auth or meeting state.

**Frontend side-effect services:**
- Purpose: Encapsulate browser APIs and network I/O outside Vue components.
- Location: `openmeet-client/src/services/auth-api.ts`, `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/services/webrtc-sfu.ts`
- Contains: Fetch client, WebSocket client, `RTCPeerConnection`, media-device access, event dispatch helpers.
- Depends on: Browser `fetch`, `WebSocket`, `RTCPeerConnection`, `navigator.mediaDevices`, Vite env vars.
- Used by: XState actors in `openmeet-client/src/xstate/machines/`.

**Backend HTTP/API layer:**
- Purpose: Expose process health, metrics, WebSocket signaling, and authentication endpoints.
- Location: `openmeet-server/src/main.rs`, `openmeet-server/src/auth/routes.rs`, `openmeet-server/src/auth/handlers.rs`
- Contains: Axum router, route handlers, CORS, state extraction, HTTP JSON responses.
- Depends on: `AppState`, Diesel pool, JWT config, room repository, Prometheus handle.
- Used by: Browser SPA via `/auth/*`, `/health`, `/metrics`, `/ws`.

**Backend auth/data layer:**
- Purpose: Persist users and refresh tokens, hash passwords, issue/validate access tokens.
- Location: `openmeet-server/src/auth/`, `openmeet-server/src/db/mod.rs`, `openmeet-server/src/schema.rs`, `openmeet-server/migrations/`
- Contains: Diesel models, SQL migrations, pool creation, JWT utility, request/response DTOs.
- Depends on: PostgreSQL, Diesel Async, Argon2, jsonwebtoken, SHA-256 refresh-token hashing.
- Used by: Auth route handlers and frontend auth API client.

**Backend signaling layer:**
- Purpose: Convert WebSocket JSON messages into room, peer connection, negotiation, media state, and chat operations.
- Location: `openmeet-server/src/signaling/handler.rs`, `openmeet-server/src/signaling/message.rs`
- Contains: WebSocket send/receive tasks, message parsing/serialization, participant ID assignment, room join/leave cleanup.
- Depends on: SFU room/repository/peer abstractions, `tokio::mpsc`, `futures_util`, metrics, tracing.
- Used by: Axum `/ws` route.

**Backend SFU media layer:**
- Purpose: Own rooms, participants, server-side peer connections, RTP packet forwarding, RTCP feedback.
- Location: `openmeet-server/src/sfu/`
- Contains: `Room`, `ParticipantConnection`, `SfuPeerConnection`, `RtpPacketBuffer`, `RoomRepository`.
- Depends on: `webrtc` crate, Tokio locks/channels/tasks, tracing, metrics from signaling.
- Used by: Signaling handler.

**Deployment/edge layer:**
- Purpose: Build containers, serve SPA, terminate TLS, route domains, expose TURN/STUN and observability.
- Location: `openmeet-client/Dockerfile`, `openmeet-server/Dockerfile`, `deployment/nginx/nginx.conf`, `deployment/coturn/turnserver.conf.template`, `observability/`, `.github/workflows/`
- Contains: Multi-stage builds, Nginx reverse proxy, Prometheus scrape config, Loki config, GitHub Actions build/test/deploy workflows.
- Depends on: Docker Compose files, VPS environment, GitHub Actions, Let's Encrypt cert paths.
- Used by: Local development, production deployment, CI/CD.

## Data Flow

### Primary Meeting Join and Media Path

1. User opens `/room/:id`; Vue Router resolves `MeetingPage` (`openmeet-client/src/router/index.ts:48`).
2. `MeetingPage` shows join settings, calls `initMedia()` with selected devices (`openmeet-client/src/pages/MeetingPage.vue:192`).
3. `webrtcMachine` enters `initializingMedia` and invokes `initMediaActor` (`openmeet-client/src/xstate/machines/webrtc/index.ts:254`).
4. `initMediaActor` creates `SignalingService`, connects to `VITE_SFU_WSS_URL`, creates `WebRTCServiceSFU`, and calls `initializeMedia()` (`openmeet-client/src/xstate/machines/webrtc/actors.ts:35`).
5. Browser media capture runs via `navigator.mediaDevices.getUserMedia()` (`openmeet-client/src/services/webrtc-sfu.ts:65`).
6. `MeetingPage` sends `JOIN_ROOM`; `webrtcMachine` invokes `joinRoomActor` (`openmeet-client/src/xstate/machines/webrtc/index.ts:285`).
7. `joinRoomActor` registers signaling handlers, sends `join`, creates a peer connection, and sends an offer (`openmeet-client/src/xstate/machines/webrtc/actors.ts:57`).
8. Axum upgrades `/ws` and `handle_socket()` assigns a participant ID with send/receive tasks (`openmeet-server/src/signaling/handler.rs:27`).
9. `handle_message(SignalingMessage::Join)` creates/fetches a room, creates a `ParticipantConnection`, creates an `SfuPeerConnection`, and adds the participant (`openmeet-server/src/signaling/handler.rs:156`).
10. `handle_message(SignalingMessage::Offer)` sets the remote description and returns an answer (`openmeet-server/src/signaling/handler.rs:352`).
11. Client `WebRTCServiceSFU` handles server answer and sets remote description (`openmeet-client/src/services/webrtc-sfu.ts:180`).
12. Server `Room::handle_incoming_track()` registers sender tracks, creates broadcast channels, and forwards tracks to other participants (`openmeet-server/src/sfu/room.rs:226`).
13. Client remote tracks are assigned to participants using `streamOwnerMap` and `REMOTE_TRACK_RECEIVED` events (`openmeet-client/src/xstate/machines/webrtc/index.ts:88`).

### Authentication Path

1. Login/register pages dispatch `LOGIN` or `REGISTER` into `authMachine` (`openmeet-client/src/xstate/machines/auth/index.ts:175`).
2. XState invokes `loginActor` or `registerActor`, which calls `authApi` (`openmeet-client/src/xstate/machines/auth/index.ts:8`).
3. `authApi` sends HTTP requests to `VITE_API_URL` `/auth/login` or `/auth/register` (`openmeet-client/src/services/auth-api.ts:49`).
4. Axum nests auth routes under `/auth` (`openmeet-server/src/main.rs:107`).
5. `register()` hashes passwords with Argon2, inserts users with Diesel, and creates tokens (`openmeet-server/src/auth/handlers.rs:24`).
6. `login()` verifies Argon2 hashes and creates tokens (`openmeet-server/src/auth/handlers.rs:73`).
7. `create_tokens()` issues a JWT access token, creates a random refresh token, hashes it, and stores it in `refresh_tokens` (`openmeet-server/src/auth/handlers.rs:200`).
8. `authMachine` saves tokens to cookies and navigates to `/dashboard` (`openmeet-client/src/xstate/machines/auth/index.ts:93`).

### SFU Forwarding and Renegotiation Flow

1. A participant's server-side peer connection fires `on_track`; signaling delegates to `Room::handle_incoming_track()` (`openmeet-server/src/signaling/handler.rs:278`).
2. The room stores `SenderTrackInfo` and creates a Tokio broadcast channel for RTP packets (`openmeet-server/src/sfu/room.rs:247`).
3. The room adds local forwarding tracks to other participants' peer connections and sends `StreamOwner` before forwarding (`openmeet-server/src/sfu/room.rs:298`).
4. The room spawns a reader task to read RTP from `TrackRemote` and publish packets into the broadcast channel (`openmeet-server/src/sfu/room.rs:385`).
5. The room spawns per-receiver writer tasks to rewrite SSRC, store packets in `RtpPacketBuffer`, and write RTP into local tracks (`openmeet-server/src/sfu/room.rs:450`).
6. The room spawns RTCP feedback handlers for PLI/NACK forwarding and retransmission (`openmeet-server/src/sfu/room.rs:641`).
7. Late joiners receive existing tracks through server-initiated renegotiation offers (`openmeet-server/src/signaling/handler.rs:377`).
8. Client `handleServerOffer()` answers renegotiation offers (`openmeet-client/src/services/webrtc-sfu.ts:196`).

### Build, Deploy, and Runtime Flow

1. CI builds frontend with Node/Yarn and backend with Cargo (`.github/workflows/build.yml:14`, `.github/workflows/build.yml:49`).
2. CI runs frontend lint/unit tests and backend `cargo test`/`cargo check` after build success (`.github/workflows/test.yml:13`, `.github/workflows/test.yml:42`).
3. Deploy workflow SSHes to a VPS and runs `deploy.sh` (`.github/workflows/deploy.yml:30`).
4. `deploy.sh` ensures certificates and env files exist, builds services, starts Docker Compose, then checks running containers (`deploy.sh:16`).
5. Production Nginx routes `openmeets.eu` to the frontend container and `sfu.openmeets.eu` `/ws`, `/health`, `/auth/` to the SFU server (`deployment/nginx/nginx.conf:16`, `deployment/nginx/nginx.conf:46`).
6. Prometheus scrapes SFU `/metrics`, node-exporter, and cAdvisor (`observability/prometheus.yaml:4`).

**State Management:**
- Frontend auth state lives in `authMachine` context and cookie storage (`openmeet-client/src/xstate/machines/auth/index.ts`).
- Frontend meeting state lives in `webrtcMachine` context with a `Map<string, Participant>` and `streamOwnerMap` (`openmeet-client/src/xstate/machines/webrtc/index.ts:12`).
- Non-serializable WebSocket/WebRTC services are module-level singletons in `openmeet-client/src/xstate/machines/webrtc/actors.ts`.
- Server process state lives in `AppState` (`openmeet-server/src/main.rs:31`).
- Server room/media state lives in `InMemoryRoomRepository` with `Arc<RwLock<HashMap<String, Arc<RwLock<Room>>>>>` (`openmeet-server/src/sfu/repository.rs:28`).
- Persistent state is PostgreSQL users and refresh tokens (`openmeet-server/src/schema.rs`).

## Key Abstractions

**XState machines:**
- Purpose: Make auth and meeting flows explicit, event-driven, and inspectable.
- Examples: `openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`
- Pattern: Machine state + context + invoked actors + actions/guards.

**Injected actor composables:**
- Purpose: Hide `inject()` and machine event shape behind Vue-friendly computed values and methods.
- Examples: `openmeet-client/src/composables/useAuth.ts`, `openmeet-client/src/composables/useWebrtc.ts`
- Pattern: `inject()` actor, derive `computed()` selectors, return action wrappers.

**Service classes:**
- Purpose: Own side effects and browser APIs outside Vue rendering and XState context.
- Examples: `openmeet-client/src/services/signaling.ts`, `openmeet-client/src/services/webrtc-sfu.ts`, `openmeet-client/src/services/auth-api.ts`
- Pattern: Class or object module with typed methods and callbacks.

**Signaling message enum/union:**
- Purpose: Keep browser and server signaling contracts aligned.
- Examples: `openmeet-server/src/signaling/message.rs`, `openmeet-client/src/services/signaling.ts`
- Pattern: Tagged message envelope using `type` with camelCase fields.

**Room repository:**
- Purpose: Isolate room storage behind a trait so storage can be replaced without rewriting signaling.
- Examples: `openmeet-server/src/sfu/repository.rs`
- Pattern: `async_trait` trait object stored as `Arc<dyn RoomRepository>` in `AppState`.

**Room:**
- Purpose: Aggregate participants, sender tracks, negotiated tracks, and media forwarding tasks for one meeting room.
- Examples: `openmeet-server/src/sfu/room.rs`
- Pattern: Mutable room protected by `Arc<RwLock<Room>>` in repository.

**ParticipantConnection:**
- Purpose: Bundle participant metadata, WebSocket outbound channel, peer connection, and shutdown notification.
- Examples: `openmeet-server/src/sfu/participant.rs`
- Pattern: Data holder with `send()`, `set_peer_connection()`, `get_shutdown_receiver()`.

**SfuPeerConnection:**
- Purpose: Wrap WebRTC-rs peer connection setup and SDP/ICE operations with SFU defaults.
- Examples: `openmeet-server/src/sfu/peer_connection.rs`
- Pattern: `Arc<Mutex<SfuPeerConnection>>` wrapping `Arc<RTCPeerConnection>`.

**RtpPacketBuffer:**
- Purpose: Store recent RTP packets for NACK retransmission per receiver.
- Examples: `openmeet-server/src/sfu/packet_buffer.rs`
- Pattern: `RwLock` protected ring-buffer-like map keyed by sequence number.

## Entry Points

**Frontend application:**
- Location: `openmeet-client/src/main.ts`
- Triggers: Browser loads `openmeet-client/index.html` and Vite bundle.
- Responsibilities: Initialize theme, create Vue app, install router, mount `#app`.

**Frontend routes:**
- Location: `openmeet-client/src/router/index.ts`
- Triggers: Browser navigation to `/`, `/login`, `/register`, `/dashboard`, `/room/:id`.
- Responsibilities: Select page components and enforce basic token/cookie navigation rules.

**Meeting page:**
- Location: `openmeet-client/src/pages/MeetingPage.vue`
- Triggers: Route `/room/:id`.
- Responsibilities: Join dialog, media settings, call lifecycle, chat, controls, connection status.

**Backend process:**
- Location: `openmeet-server/src/main.rs`
- Triggers: Cargo binary or Docker `CMD ["/app/openmeet-server"]`.
- Responsibilities: Load env, migrate DB, create pools/state, install metrics recorder, bind HTTP/TLS server.

**Backend routes:**
- Location: `openmeet-server/src/main.rs`, `openmeet-server/src/auth/routes.rs`
- Triggers: HTTP requests to `/health`, `/metrics`, `/auth/*`, `/ws`.
- Responsibilities: Health, metrics rendering, auth JSON API, WebSocket upgrade.

**WebSocket signaling:**
- Location: `openmeet-server/src/signaling/handler.rs`
- Triggers: Browser `SignalingService.connect()` to SFU `/ws`.
- Responsibilities: Participant lifecycle, signaling message handling, room creation/removal, peer connection setup.

**CI/CD:**
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

**What happens:** WebSocket and WebRTC service instances are non-serializable browser objects.
**Why it's wrong:** XState context is used as serializable app state; storing `WebSocket`, `RTCPeerConnection`, or `MediaStream` service instances in context makes state snapshots harder to reason about.
**Do this instead:** Keep service instances in `openmeet-client/src/xstate/machines/webrtc/actors.ts` and expose stateful results through machine events/context as done by `initMediaActor` and `joinRoomActor`.

### Changing signaling on one side only

**What happens:** The server enum and TypeScript union duplicate message names and field casing.
**Why it's wrong:** A one-sided change makes WebSocket JSON fail to deserialize or leaves handlers unreachable.
**Do this instead:** Update `openmeet-server/src/signaling/message.rs`, `openmeet-client/src/services/signaling.ts`, and affected machine events in `openmeet-client/src/xstate/machines/webrtc/types.ts` together.

### Adding persistent meeting features to in-memory room state

**What happens:** `Room` and `InMemoryRoomRepository` store live participants/tracks only.
**Why it's wrong:** Process restart or horizontal scaling loses rooms and makes room lookup process-local.
**Do this instead:** Use PostgreSQL-backed models/migrations under `openmeet-server/migrations/` and a new repository implementation behind `RoomRepository` in `openmeet-server/src/sfu/repository.rs` for durable room metadata.

### Blocking or long-running work inside room write locks

**What happens:** Signaling and room operations acquire `room_lock.write().await` before mutating participants/tracks.
**Why it's wrong:** Holding write locks while performing slow network/media operations can delay other room operations.
**Do this instead:** Collect data while locked, release locks with `drop(...)`, then spawn or await external work, following the lock-release pattern near room deletion in `openmeet-server/src/signaling/handler.rs:127`.

## Error Handling

**Strategy:** Errors are propagated to the nearest protocol boundary: frontend services throw/log, XState transitions to `error` or failed states, auth HTTP handlers return `(StatusCode, String)`, WebSocket signaling sends `SignalingMessage::Error`, and SFU media tasks log and clean up.

**Patterns:**
- Use `Result<Json<T>, (StatusCode, String)>` for auth handlers (`openmeet-server/src/auth/handlers.rs:22`).
- Send `SignalingMessage::Error` over WebSocket for invalid messages and SFU setup failures (`openmeet-server/src/signaling/handler.rs:94`).
- Use XState `onError` transitions for auth and media initialization (`openmeet-client/src/xstate/machines/auth/index.ts`, `openmeet-client/src/xstate/machines/webrtc/index.ts`).
- Use `cleanup` + `resetContext` when leaving or retrying calls (`openmeet-client/src/xstate/machines/webrtc/index.ts:448`).
- Log server errors with `tracing::{error,warn,info}` in signaling/SFU modules.

## Cross-Cutting Concerns

**Logging:** Frontend uses `console.log/error` in services, machines, and meeting components. Backend uses `tracing_subscriber` in `openmeet-server/src/main.rs` and `tracing` macros in `openmeet-server/src/signaling/` and `openmeet-server/src/sfu/`.

**Validation:** Frontend route guards validate token presence/expiration in `openmeet-client/src/router/index.ts`. Backend request validation is basic JSON deserialization plus DB constraints and explicit checks in `openmeet-server/src/auth/handlers.rs`. Signaling validation relies on serde enum deserialization in `openmeet-server/src/signaling/message.rs`.

**Authentication:** Frontend stores access and refresh tokens in cookies via `openmeet-client/src/utils.ts`; backend issues JWT access tokens and hashed refresh tokens via `openmeet-server/src/auth/jwt.rs` and `openmeet-server/src/auth/handlers.rs`. Meeting `/room/:id` does not require auth in router metadata (`openmeet-client/src/router/index.ts:48`).

**Metrics/observability:** Backend exposes `/metrics` through `metrics-exporter-prometheus` (`openmeet-server/src/main.rs:89`) and increments SFU counters/gauges in `openmeet-server/src/signaling/handler.rs`. Prometheus scrape config is in `observability/prometheus.yaml`; Grafana is routed by `deployment/nginx/nginx.conf`.

**Configuration:** Frontend uses Vite env vars in `openmeet-client/src/services/auth-api.ts`, `openmeet-client/src/xstate/machines/webrtc/actors.ts`, and `openmeet-client/src/services/webrtc-sfu.ts`. Backend uses environment variables in `openmeet-server/src/main.rs` and `openmeet-server/src/signaling/handler.rs`. Deployment uses env files and Docker Compose through `deploy.sh`.

---

*Architecture analysis: 2026-06-19*
