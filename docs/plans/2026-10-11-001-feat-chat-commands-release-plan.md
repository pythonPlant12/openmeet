---
title: "feat: Release chat commands and social polish"
type: feat
status: completed
created: 2026-10-11
---

## Summary

Release accumulated client and server work for chat commands, GIF attachments, reply attachment previews, social request cards, status-avatar consistency, and local seed reliability.

## Implementation Units

### U1. Chat Composer and Social UI

**Goal:** Ship slash commands, Giphy selection, mentions, reply attachment previews, request cards, and visual refinements.

**Requirements:** Chat messages support richer composer and reply flows without regressing meeting chat.

**Dependencies:** Server message and GIF API support.

**Files:** `openmeet-client/src/components/dashboard-page/chat/`, `openmeet-client/src/components/dashboard-page/`, `openmeet-client/src/pages/DashboardPage.vue`, `openmeet-client/src/services/social-api.ts`, affected client tests.

**Approach:** Preserve existing Harbor components and authenticated attachment flow; keep GIF secrets server-side.

**Test scenarios:** Composer keyboard flows, async GIF selection, group mentions, reply attachment labels, request-card actions, responsive status/avatar UI.

**Verification:** Client tests, type checks, build, formatter, and lint pass.

### U2. Social API and Giphy Proxy

**Goal:** Expose reply attachment metadata, invitation/avatar data, pending-request presence, and a bounded Giphy proxy.

**Requirements:** Preserve privacy rules and prevent client Giphy key exposure.

**Dependencies:** U1 consumes the extended response types.

**Files:** `openmeet-server/src/social/`, server unit tests.

**Approach:** Use batched data loading, server-side API credentials, bounded upstream concurrency, and existing authenticated routes.

**Test scenarios:** Metadata serialization, Giphy failure mapping, limiter behavior, and pending-request presence visibility.

**Verification:** Rust format and compile checks pass; run linked tests in CI.

### U3. Development Seed Reliability

**Goal:** Make Compose seed wait for completed migrations and use valid group codes.

**Requirements:** `seed` completes after all schema constraints exist.

**Dependencies:** None.

**Files:** `docker-compose.dev.yml`, `openmeet-server/dev/seed.sql`.

**Approach:** Wait for latest embedded Diesel migration and use deterministic valid base62 fixture codes.

**Test expectation:** Compose configuration validates; container replay is verified in CI or a Docker-enabled environment.

## Verification

- Client unit tests, type check, build, Prettier, Oxlint, and ESLint pass.
- Server format and compile checks pass.
- Compose configuration validates.
- Pull-request CI completes before merge.
