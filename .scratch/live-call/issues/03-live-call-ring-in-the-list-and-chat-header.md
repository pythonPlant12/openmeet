# 03: Live call ring in the conversations list and the chat header

**What to build:** A purple-red-yellow gradient ring replaces the presence border on a group's picture while the group has a live call I belong to, and on a friend's picture while that friend is in a direct live call with me. A friend's call with other people never shows. The ring appears and disappears live as people connect and leave. Spec stories 13–17, 20–24, 30.

**Blocked by:** None (can start immediately).

**Status:** done

- [x] Conversations carry `liveCall: { id, memberIds } | null` on the list and single-conversation responses; direct conversations get it only for a call between the two people, groups for any member. `memberIds` are the users currently connected to the call's room.
- [x] The client re-fetches conversations on the existing calls live-update event so the ring tracks joins and leaves without a reload.
- [x] One new Harbor token set for the three gradient stops; no raw hex in components.
- [x] The picture's presence border gets an "in live call" state drawn as the gradient; presence border classes are not applied while it shows; the presence dot stays; presence returns when the call ends.
- [x] Ring on conversations list rows and the chat header picture only; message sender pictures unchanged; rows still open the chat on click.
- [x] Conversations sidebar and chat pane component tests cover both display rules, the no-ring case for someone else's call, and the border replacement.
