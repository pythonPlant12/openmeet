# 05: The call outlives the call screen

**What to build:** A collapse button at the top-left of the call screen, and browser Back or the system back gesture, return me to the dashboard exactly as I left it with the call still running. A small fixed mini call tile in the bottom-right shows the person speaking, and tapping it returns me to the full call screen. Only Leave and a page reload end the call. Guests keep the full-screen call screen. This implements ADR-0001 as amended. Spec stories 31–46 (tile choice), 57, 59.

**Blocked by:** None (can start immediately).

**Status:** done

- [x] Everything that today ends the call when the call screen unmounts (end call, screen share stop, audio output following, ringing cancel) moves to an app-level active call owner; unmounting the call screen tears down only the screen.
- [x] The WebRTC machine keeps `collapsed` in context, toggled by COLLAPSE and EXPAND, and keeps the active call's conversation id and session id in context.
- [x] Collapse button at the top-left of the call screen on phone and desktop; it sends COLLAPSE and navigates to the dashboard, which restores its last sidebar and selected chat.
- [x] A route leave guard turns browser Back and the system back gesture into collapse; Leave and reload remain the only ways to end the call.
- [x] Opening the room route of the active call shows the call screen without re-joining; navigating to Profile, Group info or the account page keeps the call running.
- [x] A minimal mini call component, rendered by the app shell for signed-in users while collapsed: one tile chosen as screen share, then current speaker among others, then last speaker, then self view when alone; picture and name when the camera is off; mic-off mark via the name tag; tap expands; vanishes when the call ends. Fixed bottom-right for now.
- [x] Guests see no collapse button and no mini call; incoming rings on the dashboard behave as today.
- [x] WebRTC machine test: COLLAPSE keeps the call connected, EXPAND restores, LEAVE_ROOM ends it, ids kept in context. Mini call component test: tile choice order, camera-off fallback, tap expands, disappears when the call ends.
- [x] Two-browser e2e: B collapses, the dashboard shows the mini call with A, B expands and is back in the call with media.
