# 07: Join, Return to call, and the picture menu in the chat header

**What to build:** While a conversation has a live call I am not in, the header's two call buttons become one Join button; while it is my active call they become Return to call; without a live call the video and audio buttons stay as today. Clicking the header picture during a live call opens a small menu with Profile (or Group info) and Join call (or Return to call); without a live call it opens Profile or Group info directly. Spec stories 8–10, 25–29, 64.

**Blocked by:** 02 (Pressing call joins the live call), 03 (Live call ring in the list and chat header), 05 (The call outlives the call screen).

**Status:** done

- [x] The header reads the conversation's live call and the active call's session id to pick call buttons, Join, or Return to call; Join turns back into the call buttons when the live call ends.
- [x] Join starts a call on the conversation and navigates to the returned session; Return to call expands the active call without a prompt.
- [x] The picture button opens a dropdown built from the existing menu primitives, only while a live call exists, with the two items worded per direct or group and per joined or not.
- [x] Chat pane component test covers the three button states, the menu's items and wording, and the direct Profile or Group info click without a live call.
