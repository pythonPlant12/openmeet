---
date: 2026-08-09
topic: meeting-action-menus-room-security
---

# Meeting Action Menus and Room Security

## Summary

Add responsive action menus to dashboard and meeting experiences, complete navbar width animation across application state changes, and introduce ephemeral server-enforced Open, Password, and Friends-only meeting policies.

---

## Problem Frame

Meeting and dashboard actions are currently distributed across separate controls and page sections. Frequent actions such as starting calls, inviting friends, changing layout, and reporting bugs lack one predictable menu surface.

Meeting access is currently controlled only by possession of room ID. Participants cannot protect active rooms with password or friendship rules, and client-only restrictions would not prevent direct signaling joins.

Navbar content also changes between routes and authentication states without consistently animating its horizontal size, making otherwise polished transitions feel abrupt.

---

## Actors

- A1. Authenticated participant: joins meetings, invites friends, and may change active room security.
- A2. Anonymous participant: joins Open or Password meetings and may remain after policy changes.
- A3. Friend/invitee: receives invitation to current room and may need authentication or password before entry.
- A4. Meeting server: owns current room policy, validates joins, and broadcasts policy changes.

---

## Key Flows

- F1. Dashboard action menu
  - **Trigger:** User opens menu through ellipsis button or page context action.
  - **Actors:** A1
  - **Steps:** User starts new meeting, reviews friends with presence, calls one friend, or opens prefilled bug report.
  - **Outcome:** Selected action executes without requiring navigation through dashboard sections.
  - **Covered by:** R2, R3, R4, R5

- F2. Meeting action menu
  - **Trigger:** Participant opens menu through ellipsis button or page context action.
  - **Actors:** A1, A2
  - **Steps:** Participant controls chat/media, changes view, invites a friend when authenticated, disconnects, or reports bug.
  - **Outcome:** Menu reflects live call state and selected action updates meeting immediately.
  - **Covered by:** R2, R6, R7, R8, R9, R10

- F3. Change room security
  - **Trigger:** Authenticated participant selects Open, Password, or Friends-only.
  - **Actors:** A1, A2, A4
  - **Steps:** Participant configures policy; server validates actor; room policy changes; everyone receives notification and menu status update.
  - **Outcome:** Future joins follow new policy while current participants remain connected.
  - **Covered by:** R11, R12, R13, R14, R17

- F4. Join restricted room
  - **Trigger:** Visitor follows room link whose current policy is not Open.
  - **Actors:** A1, A2, A3, A4
  - **Steps:** Password visitor supplies password, or Friends-only visitor authenticates; server validates access before room admission.
  - **Outcome:** Eligible visitor joins; ineligible visitor receives recoverable explanation without media/signaling admission.
  - **Covered by:** R13, R14, R15, R16

---

## Requirements

**Navbar motion**

- R1. Navbar must smoothly animate horizontal size whenever content width changes, including route transitions, login, logout, and authenticated-user content changes.

**Shared action-menu behavior**

- R2. Dashboard and meeting menus must use shadcn-style primitives, include icons for every option, and open from both visible ellipsis control and right-click/long-press context action.
- R3. Menus must remain keyboard accessible, usable on touch devices, and visually consistent with Harbor palette.

**Dashboard menu**

- R4. Dashboard menu must offer visually green New meeting action and visually red Report a bug action that opens prefilled GitHub issue in new tab.
- R5. Dashboard menu must show friends with online status on left and let user call each friend; New meeting remains independently available.

**Meeting menu**

- R6. Meeting menu must show Open chat or Close chat according to current chat state.
- R7. Authenticated participants must see friends and may invite any friend to current room; invitation must reference existing room rather than create another.
- R8. Change view must offer Grid and Speaker. Speaker follows active speaker automatically unless user pins participant; pinned participant remains emphasized until unpinned or leaves.
- R9. Audio and Video actions must display current enabled/disabled state and toggle live local tracks.
- R10. Meeting menu must offer Disconnect and visually red Report a bug action; bug action opens prefilled GitHub issue with non-sensitive meeting context.

**Room security**

- R11. Meeting policy must support Open, Password, and Friends-only states and display current state in meeting menu.
- R12. Any authenticated participant currently in room may change policy; every participant must receive toast naming new state and observe updated menu status.
- R13. Password policy applies to future joins, keeps existing participants connected, and requires server validation before admission.
- R14. Friends-only policy applies to future joins, keeps existing participants including anonymous guests connected, and admits visitor only when visitor is authenticated and accepted friend of every authenticated participant currently in room.
- R15. Anonymous visitor to Friends-only room must be sent through login and returned to same room for access recheck.
- R16. Access restrictions must be enforced server-side; direct signaling must not bypass password or friendship checks.
- R17. Policy and password exist only for lifetime of in-memory room and reset when room is removed or server restarts.
- R18. Security updates must not expose room password to other participants or client logs.
- R19. Friends-only must automatically return to Open when no authenticated participants remain after explicit departure or 60-second reconnect grace expires; remaining guests receive policy update.
- R20. Same authenticated account must not hold multiple simultaneous participant connections in one room.
- R21. Admitted participant must receive one-use, room-bound reconnect grant lasting 60 seconds so brief signaling loss can recover without reapplying newer policy.
- R22. Current-room invitation opened after original room instance ends must show Meeting ended and must not recreate Open room with same ID.

---

## Acceptance Examples

- AE1. **Covers R1.** Given anonymous landing navbar, when login succeeds and authenticated actions replace anonymous actions, capsule width transitions without instant jump.
- AE2. **Covers R2, R3.** Given dashboard on touch device, when user long-presses supported menu area or taps ellipsis, same accessible action set opens.
- AE3. **Covers R5, R7.** Given friend Bob is offline, when user selects Bob in meeting menu, Bob receives invitation to current room when next checking invitations.
- AE4. **Covers R6, R9.** Given chat open and microphone muted, menu labels actions Close chat and Enable audio; selecting each immediately updates state and labels.
- AE5. **Covers R8.** Given Speaker view follows Alice, when user pins Bob and Alice speaks, Bob remains emphasized; when Bob leaves, view resumes automatic speaker selection.
- AE6. **Covers R12, R13.** Given two existing participants, when authenticated participant enables Password, both see notification, remain connected, and future visitor cannot join without correct password.
- AE7. **Covers R14, R15.** Given Friends-only room with two authenticated participants and one existing guest, when anonymous visitor follows link, existing guest stays while visitor logs in and must be accepted friend of both authenticated participants.
- AE8. **Covers R16, R18.** Given restricted room, when client sends direct join without required proof, server refuses admission and does not disclose password or credential detail.
- AE9. **Covers R17.** Given restricted room becomes empty and is removed, when same room ID is later recreated, policy is Open with no prior password.
- AE10. **Covers R19.** Given Friends-only room has guests and last authenticated participant leaves, room becomes Open and guests see policy-change toast.
- AE11. **Covers R20, R21.** Given authenticated participant is connected, second simultaneous join for same account is rejected, while original connection may recover once with valid 60-second reconnect grant.
- AE12. **Covers R22.** Given invitation references ended room instance, opening invitation shows Meeting ended and no room is recreated.

---

## Success Criteria

- Users can find frequent dashboard and meeting actions from one consistent menu on mouse, keyboard, and touch devices.
- Navbar width changes animate smoothly across routes and authentication states.
- Existing friends and call features remain functional, and current-room invitations do not create unintended rooms.
- Open, Password, and Friends-only policies correctly gate future joins under automated client/server tests.
- Existing participants remain connected and receive visible policy-change notifications.
- Two-participant bidirectional media remains stable under each admission policy.
- Planning can map every flow and conditional behavior without inventing product rules.

---

## Scope Boundaries

- Room security is not persisted after in-memory room lifecycle.
- No permanent host or room owner is introduced.
- No lobby, manual admission, waiting room, or per-user approval is included.
- Existing participants are not disconnected when security becomes stricter.
- Friends-only ignores anonymous participants already inside when evaluating future visitor friendships.
- Friends-only automatically becomes Open when no authenticated participants remain.
- Bug reporting does not store reports in OpenMeet; it opens GitHub.
- No additional meeting layouts beyond Grid and Speaker.

---

## Key Decisions

- Any authenticated participant may change room policy: collaborative control preferred over host ownership.
- Friends-only requires relationship with every authenticated current participant: strongest selected friendship rule.
- Existing guests remain after policy change: avoid disrupting active calls.
- Security is ephemeral: matches current in-memory room lifecycle.
- Menu supports ellipsis and context action: discoverability plus desktop efficiency.
- Speaker mode combines automatic detection and manual pinning: dynamic by default, stable on demand.
- Duplicate account joins are rejected while one-use 60-second grants preserve legitimate reconnects.
- Current-room invitations bind to room instance and expire when that instance ends.

---

## Dependencies / Assumptions

- Existing friend relationships, presence, call invitations, authentication, and in-memory room lifecycle remain source of truth.
- Invitations may be delivered through current polling behavior; real-time notification transport is not required.
- Report links include only non-sensitive diagnostic context.
- Password input has reasonable length limits and is never retained in plaintext beyond validation needs.

---

## Outstanding Questions

### Deferred to Planning

- [Affects R1][Technical] Determine measurement strategy for animating between dynamic navbar content widths.
- [Affects R2][Technical] Determine shared composition between shadcn dropdown and context-menu triggers.
- [Affects R8][Needs research] Determine reliable active-speaker signal using available browser/WebRTC data.
- [Affects R12-R18][Technical] Design authenticated signaling identity, password verification, policy broadcast, and race-safe room admission without long-lived room locks across database work.
- [Affects R15][Technical] Preserve room destination safely through authentication redirect.
