# 08: Tile interactions

**What to build:** Tapping a tile pins that person and switches to the speaker layout; tapping the pinned tile unpins it and returns to the previous layout (`selection` haptic). The pin is local and single. A long-press on the tile area (touch) or a right-click (desktop) opens the layout menu with Grid and Speaker (`medium` haptic). Tiles shrink slightly while pressed, the person speaking gets a teal ring, and each tile has a ⋯ button (on hover on desktop, always on touch) with pin, full screen for that tile, and the participant's options.

**Blocked by:** 07 (Layout by form factor).

**Status:** ready-for-agent

- [ ] Tap to pin and unpin; previous layout restored; `selection` haptic.
- [ ] Long-press and right-click open the layout menu; `medium` haptic; a layout change plays `selection`.
- [ ] Press shrink, teal speaking ring (Harbor accent).
- [ ] Tile ⋯ menu reuses the existing pin and participant actions.
- [ ] Video grid and participant tile tests cover pin, unpin and the layout menu.
