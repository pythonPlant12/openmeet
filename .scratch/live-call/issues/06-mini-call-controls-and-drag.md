# 06: Mini call controls and drag

**What to build:** The mini call carries mute, leave and expand buttons, shown on hover on desktop and on press on touch. I can drag it to any corner, it follows without lag, settles smoothly, and stays in that corner for the rest of the session. On a phone it sits above the bottom bar and clear of the notch and home indicator. Spec stories 46–56.

**Blocked by:** 01 (Shared corner drag for the self-view), 05 (The call outlives the call screen).

**Status:** done

- [x] Mute, leave and expand buttons on the tile, using the shared call button style; no button that opens the conversation.
- [x] Buttons appear on hover on desktop and on a press on touch; the video stays clear otherwise.
- [x] Drag to any corner through the shared corner-drag composable; the corner is remembered for the session.
- [x] Phone bottom bar and safe-area insets are passed as edges so the tile is never hidden or clipped.
- [x] Mini call component test: mute, leave and expand emit; hover and press reveal; drag ends in the nearest corner and the corner is kept.
