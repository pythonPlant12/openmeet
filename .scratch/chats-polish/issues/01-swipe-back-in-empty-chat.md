# 01: Swipe-back works in an empty chat

**What to build:** On a phone, a right swipe anywhere in a chat that has no messages goes back to the conversations list, exactly as it does in a chat with messages. Swipes that start on buttons, links or fields are still ignored, and swiping a message in a full chat still starts a reply.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] The root cause of the gesture not starting in an empty chat is found and fixed at its source, without widening the excluded targets.
- [ ] A right swipe in an empty chat goes back on touch; mouse drags and desktop do nothing, as before.
- [ ] Swipes starting on the empty state's buttons or fields do not go back.
- [ ] Chat pane component test covers the empty-chat swipe and an excluded target.
- [ ] Checked by hand on a phone-width viewport in the running app.
