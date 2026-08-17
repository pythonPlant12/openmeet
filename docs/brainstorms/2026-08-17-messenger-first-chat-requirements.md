---
date: 2026-08-17
topic: messenger-first-chat
---

# Messenger-First Chat

## Summary

OpenMeet will become a messenger-first product with a Telegram-inspired authenticated dashboard, persistent direct and group conversations, and voice/video calls launched from those conversations. Every call shares its conversation's message history, while messages use multi-device end-to-end encryption.

---

## Problem Frame

OpenMeet currently centers on temporary meeting rooms. Its dashboard exposes friends and calls, but not an ongoing place to communicate; the room chat exists only while its in-memory meeting exists. People who want to keep a conversation before, during, and after a call need another messenger.

The product direction is to make messaging the primary place people return to, without losing reliable voice and video conferences. This requires durable conversations, well-defined group access, and privacy that remains meaningful across a user's devices.

---

## Actors

- A1. Registered user: starts conversations, sends encrypted messages, joins calls, and authorizes devices.
- A2. Direct-message requester: asks to start a direct conversation with a registered user who may not know them.
- A3. Conversation recipient: accepts or declines a direct-message request.
- A4. Group creator or admin: manages durable group membership and group access policy.
- A5. Group member: participates in messages and calls subject to group rules.
- A6. Giphy: third-party GIF provider whose search and asset loads are outside OpenMeet E2EE.

---

## Key Flows

- F1. Open or request a direct conversation
  - **Trigger:** User selects a friend or tries to message another registered user.
  - **Actors:** A1, A2, A3
  - **Steps:** A friend opens an existing direct thread immediately. A non-friend creates a request. Recipient accepts or declines; acceptance opens one shared direct thread.
  - **Outcome:** Direct messaging is available only after an existing friendship or recipient approval.
  - **Covered by:** R2, R4, R5

- F2. Create and manage a group
  - **Trigger:** User creates a group conversation.
  - **Actors:** A1, A4, A5
  - **Steps:** Creator names group and selects Open link, Password, or Friends-only access. Creator may appoint admins. Admins invite or remove members and manage access; eligible invitees may join.
  - **Outcome:** Group remains a durable conversation with clear membership authority and admission behavior.
  - **Covered by:** R6, R7, R8

- F3. Read and send conversation messages
  - **Trigger:** User opens a conversation, scrolls upward, or sends text, emoji, or GIF.
  - **Actors:** A1, A5, A6
  - **Steps:** Client loads newest messages, requests older pages only when needed, encrypts an outgoing message, and delivers it to authorized participants. Typing `/` shows commands; `/giphy` searches and sends a selected GIF with disclosure.
  - **Outcome:** Conversation remains responsive with long history and no OpenMeet service receives message plaintext.
  - **Covered by:** R9, R10, R11, R12, R13

- F4. Call from a conversation
  - **Trigger:** User selects voice or video call in a direct or group conversation.
  - **Actors:** A1, A5
  - **Steps:** Call starts for that conversation. Participants enter its room and open chat during call. A standalone new meeting first creates a group conversation.
  - **Outcome:** Messages sent before, during, and after a call appear in one conversation history.
  - **Covered by:** R14, R15, R16

---

## Requirements

**Messenger workspace**

- R1. Authenticated dashboard must become a responsive Telegram-inspired messenger workspace with conversation navigation, search, active conversation content, and call actions; it must use OpenMeet visual identity rather than Telegram branding or assets.
- R2. Dashboard must list direct conversations, pending direct-message requests, and group conversations with useful current-state indicators such as latest activity and unread state.
- R3. Selecting a friend must open that friend's direct conversation and expose voice/video call actions.
- R4. A registered user who is not an accepted friend may initiate a direct-message request, but may not enter a normal direct conversation until recipient accepts it.
- R5. Recipient must be able to accept or decline a direct-message request without exposing an accepted conversation on decline.

**Groups and access**

- R6. Group creation must require creator to choose one access policy: Open link, Password, or Friends-only.
- R7. Group creator may grant or revoke admin role; only creator and admins may add or remove members or change group access policy.
- R8. Group admins may add registered users who are not friends where group policy permits. Friends-only admission must apply the established meeting rule: a new member must be an accepted friend of every authenticated current member.

**Encrypted messages and history**

- R9. Direct and group messages must persist as ordered conversation history, loaded newest-first and paginated upward with cursor-based infinite scroll; opening a conversation must not load its entire history.
- R10. Message plaintext, message search terms, and encryption key material must remain available only to authorized client devices; OpenMeet services must not log or persist plaintext.
- R11. Multi-device access must require approval from an existing signed-in device and support an optional user-controlled recovery passphrase for encrypted history recovery.
- R12. Conversation composer must provide an emoji picker and send selected Unicode emoji as normal encrypted message content.
- R13. When composer input begins with `/`, it must show available commands. Initial command set contains `/giphy`; before use, UI must disclose that Giphy can observe searches and asset loads even though selected GIF message is encrypted in conversation transport and storage.

**Calls and chat continuity**

- R14. Direct and group conversation headers must provide voice and video call actions.
- R15. A call started from a conversation must use that conversation as its chat thread, restoring existing history in the in-call chat and persisting messages sent during the call after it ends.
- R16. Creating a standalone meeting must first create a persistent group conversation whose selected policy governs admission and whose thread receives the call chat.

**Static media storage**

- R17. Chat-related static assets must use private S3-compatible storage, separated from application public assets and protected by lifecycle and access controls.
- R18. Select SeaweedFS as initial self-hosted object storage because it is active, mature, S3-compatible, and Apache-2.0 licensed; do not use archived MinIO or pre-1.0 RustFS as primary storage.

---

## Acceptance Examples

- AE1. **Covers R1, R2, R3.** Given an authenticated user with multiple threads, when they open dashboard on desktop or mobile and select a friend, their direct thread opens without leaving messenger workspace and offers call controls.
- AE2. **Covers R4, R5.** Given Alice and Bob are not friends, when Alice requests a direct message and Bob declines, Alice cannot read or send messages in a normal Bob thread.
- AE3. **Covers R6, R7, R8.** Given a Password group with Alice as creator and Bob as member, when Alice appoints Bob admin, Bob may invite a non-friend; a non-admin member cannot change access or remove someone.
- AE4. **Covers R8.** Given a Friends-only group with two authenticated members, when an invitee is not an accepted friend of either member, direct join is refused even with a group link.
- AE5. **Covers R9.** Given a conversation has thousands of messages, when user opens it, only newest page loads; when user reaches its top, older page prepends without changing visible message position unexpectedly.
- AE6. **Covers R10, R11.** Given a user approves a new device, when that device joins their account, it can decrypt authorized history; server-side records and logs contain no message plaintext or usable key material.
- AE7. **Covers R12, R13.** Given user composes a message, when they open emoji picker or type `/`, emoji insertion works and command list includes `/giphy`; selecting Giphy first displays third-party disclosure.
- AE8. **Covers R14, R15, R16.** Given a group thread has prior messages, when a member starts a video call and sends a message in in-call chat, that message appears in same group history after every participant leaves.

---

## Success Criteria

- Users can use OpenMeet as their primary persistent message workspace and transition to voice/video without fragmenting chat history.
- Authorized users can restore history on an approved or recovered device; OpenMeet cannot read message plaintext.
- Long conversations remain responsive because initial loads and older-history requests are bounded.
- Group creators/admins can enforce Open link, Password, and Friends-only admission without weakening existing meeting access guarantees.
- Planning can map cryptographic lifecycle, persistence, call-room integration, and storage without inventing product behavior.

---

## Scope Boundaries

### Deferred for later

- Additional slash commands beyond `/giphy`, stickers, bots, reactions, message editing/deletion, read receipts, and typing indicators.
- End-to-end encryption for SFU voice/video media, which is distinct from encrypted messages.
- Advanced group roles beyond creator, admin, and member.
- Generic user file attachments beyond static assets needed by initial chat media integration.

### Outside this product's identity

- Telegram trademarks, proprietary artwork, account interoperability, or protocol compatibility.
- Public, unmoderated social-feed behavior.
- Server-readable message backups presented as end-to-end encryption.

---

## Key Decisions

- Messenger-first dashboard: persistent conversations become authenticated home, while calls remain first-class actions within threads.
- Conversation-owned calls: avoids separate room-only chat history and ensures before/during/after-call context remains together.
- Direct-message requests for strangers: allows discovery without opening unsolicited private threads.
- Creator/admin group control: durable membership needs stronger authority than temporary collaborative meeting controls.
- Multi-device E2EE with approval and optional recovery: balances secure device enrollment with recoverability.
- Giphy with disclosure: preserves requested GIF feature while making third-party privacy boundary explicit.
- SeaweedFS for static media: operational maturity and permissive licensing outweigh Rust implementation preference for initial storage.

---

## Dependencies / Assumptions

- Existing authentication, friendship, social presence, call invitations, SFU rooms, and current Open/Password/Friends-only policy behavior remain foundations for this work.
- Giphy API credentials, terms, rate limits, and content policy must allow intended integration.
- Client platforms provide browser cryptographic APIs required for device keys, encryption, and recovery flows.
- SeaweedFS deployment remains private behind OpenMeet infrastructure; storage encryption alone is not considered end-to-end encryption.

---

## Outstanding Questions

### Deferred to Planning

- [Affects R9-R11][Technical] Choose reviewed multi-device E2EE protocol and define device enrollment, membership change, recovery, revocation, and lost-device behavior.
- [Affects R9][Technical] Define conversation pagination ordering, cursor semantics, retention, and transaction-safe authorization checks.
- [Affects R8, R14-R16][Technical] Reconcile durable group membership and access policies with ephemeral SFU rooms without holding room locks during database or signaling operations.
- [Affects R13, R17][Needs research] Confirm Giphy API product terms, secure search/proxy boundary, cache lifecycle, and abuse/content controls.
- [Affects R17-R18][Technical] Define private bucket layout, signed access, static-media lifecycle, backup, and recovery operations for SeaweedFS.
- [Affects R1-R16][Testing] Define automated two-browser and multi-device test coverage for encrypted message exchange, history restoration, group admission, pagination, and call/chat continuity.
