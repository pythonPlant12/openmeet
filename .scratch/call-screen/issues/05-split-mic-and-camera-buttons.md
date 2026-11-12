# 05: Split mic and camera buttons

**What to build:** The mic and camera buttons are split buttons. Tapping the main part toggles the mic or camera directly, turns red when off, and plays a `light` haptic. A chevron after a small separator opens the menu with a `medium` haptic. The mic menu has Microphone (radio list), Speaker (where the platform can switch outputs) and Input volume (a slider with a live level meter). The camera menu has Camera (radio list), Preview camera and Quality.

**Blocked by:** 01 (Camera off releases the camera).

**Status:** ready-for-agent

- [ ] Tap toggles; off state is red; `light` haptic.
- [ ] Chevron opens the menu on pointer and touch; `medium` haptic.
- [ ] Mic menu: microphones, speakers where supported, input volume with level meter.
- [ ] Camera menu: cameras, Preview camera (wired in ticket 06), Quality.
- [ ] Device switch from the menu still reaches the other people.
- [ ] Meeting media control test rewritten for the split button.
