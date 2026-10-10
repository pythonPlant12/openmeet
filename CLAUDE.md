# CLAUDE.md

Claude Code configuration for OpenMeet. `AGENTS.md` is the shared source of truth for all agents. It is imported below. Do not copy its content into this file. Update `AGENTS.md` when shared facts change, and keep only Claude Code-specific guidance here.

@AGENTS.md

## Claude Code Notes

### Current state vs. the codebase map

`.planning/codebase/*` and the Stack, Conventions, and Architecture sections of `AGENTS.md` were generated on 2026-06-19. They predate this later work, so verify against the code before you rely on them:

- **Social/messenger workspace**: friends, groups, conversations, messages, notifications, and call sessions live in `openmeet-server/src/social/` and `openmeet-client/src/components/dashboard-page/`. Live updates stream from `social/events.rs`.
- **Object storage**: RustFS (S3-compatible) stores avatars. The server code is in `openmeet-server/src/storage.rs`, and RustFS runs as the `rustfs` service in both Compose files.
- **Migrations**: there are many more than the two auth migrations listed in `AGENTS.md`. See `openmeet-server/migrations/`.
- **Lockfile**: `openmeet-server/Cargo.lock` now exists.
- **CI**: the single workflow `.github/workflows/production.yml` replaces `build.yml`, `test.yml`, and `deploy.yml`.
- **Planning**: `.planning/` is historical reference only. Its codebase map and concerns are useful context, but its phase plans and `STATE.md` are not maintained. Do not update them. Newer feature plans are in `docs/brainstorms/` and `docs/plans/`.

### Repository mechanics

- `openmeet-client/`, `openmeet-server/`, and `openmeet-native/` are Git submodules with their own branches and history. Commit inside each submodule first. Then commit the updated submodule pointer in the root repo (existing style: `chore: advance workspace submodule revisions`).
- Keep the same branch name across the root and every submodule that one change touches.
- Commit messages use Conventional Commits with a scope, for example `fix(sfu): ...`, `feat(workspace): ...`, `ci: ...`.
- NEVER add Claude attribution of any kind: no `Co-Authored-By: Claude` trailer, no "Generated with Claude Code" line, no AI mention in commit messages, PR titles, or PR descriptions. All git and GitHub operations are done only in the user's name, with the configured git identity and no extra authors.
- Signaling contract changes touch both `openmeet-server/src/signaling/message.rs` and `openmeet-client/src/services/signaling.ts` in the same change.

### Commands

Client (run in `openmeet-client/`, uses pnpm only):

```sh
pnpm type-check
pnpm lint
pnpm test:unit --run
pnpm test:browser --run
pnpm test:e2e          # includes e2e/multi-participant-media.spec.ts
pnpm build
```

Server (run in `openmeet-server/`):

```sh
cargo check
cargo test
```

On macOS, `cargo test` fails to link with `ld: library 'pq' not found` unless Homebrew's `libpq` is on the linker path: `RUSTFLAGS="-L /opt/homebrew/opt/libpq/lib" cargo test`. The dev `sfu` container runs `cargo watch`, so server edits rebuild and restart automatically and new migrations apply on restart.

Stack (run in the repo root): `make dev`, `make logs`, `make stop`, `make restart`. In dev, the frontend is on host port `5174`, the SFU/API is on `8081`, and RustFS is on `9000`/`9001`. The `seed` service loads `openmeet-server/dev/seed.sql` into the dev database.

These match the CI gates in `production.yml`: client type-check, lint, unit tests, and build; server `cargo check --release`, `cargo build --release`, and `cargo test`.

Native desktop app (run in `openmeet-native/`, Tauri 2; needs `../openmeet-client`):

```sh
pnpm dev               # loads the dev frontend on 5174, so run `make dev` first
pnpm build             # builds openmeet-client, then the release bundles
cargo clippy --manifest-path src-tauri/Cargo.toml -- -D warnings
```

`openmeet-native` is private and marked `update = none` in `.gitmodules`, so CI and deploys skip it; fetch it with `git submodule update --init --checkout openmeet-native`. Release builds serve the client from `http://localhost:47652`. That origin must be in the server's `CORS_ALLOWED_ORIGINS`. See `openmeet-native/README.md`. CI does not build the native app yet.

### Safety

- Never read, print, or commit real `.env` files, TLS material in `certs/`, VPS credentials, or TURN secrets. The `.env.example` files are templates only.
- Do not run `deploy.sh` and do not SSH to the VPS unless the user explicitly asks. `deploy.sh` removes every Docker container on the host.
- Ask before you push, open PRs, or do anything that touches production.
