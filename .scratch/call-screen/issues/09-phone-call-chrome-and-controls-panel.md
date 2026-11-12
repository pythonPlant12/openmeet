# 09: Phone call chrome and drag-up controls panel

**What to build:** On phone portrait the call screen has a top bar with the room name, audio output, invite and chat, and a bottom bar with mic▾, camera▾, share and leave, with safe-area padding. The bottom bar has a handle; swiping it up reveals the rest of the controls and settings (layout, pin participant, participants, dev tools, report bug), snapping open or closed with a `selection` haptic. Chat opens as a bottom sheet that starts half-height and expands to full height. Confirming leave plays a `medium` haptic. The collapse button stays hidden until the active call work lands.

**Blocked by:** 05 (Split mic and camera buttons).

**Status:** ready-for-agent

- [ ] Top bar and bottom bar as described, nothing hidden under the notch or home indicator.
- [ ] Drag-up panel snaps open and closed; `selection` haptic on snap.
- [ ] Chat as a half-height sheet that expands; video stays visible above it.
- [ ] `medium` haptic on confirmed leave.
- [ ] Audio output button present but wired in ticket 11.
- [ ] Checked by hand on a phone in the native app and in a mobile browser.
