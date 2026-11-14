# 03: Showing and hiding the call controls

**What to build:** A call controls visibility composable (visible state, toggle, activity, hold while a menu/sheet/chat is open, 3 s idle timeout on desktop only). Long-press anywhere on the video area hides or shows the top bar, the controls bar and the name tags (tags collapse) with a slide-and-fade, smooth tile re-centring and a selection haptic. Tap on a tile pins/unpins; tap on empty space does nothing; phone never auto-hides. Desktop hides after 3 s without mouse movement, in and out of full screen. The long-press and right-click layout menu is removed. Spec stories 20–32.

**Blocked by:** 02.

**Status:** ready-for-agent

- [ ] Visibility composable with a fake-timer unit test (toggle, desktop idle, phone no auto-hide, hold).
- [ ] Long-press toggles; tap pins; empty-space tap ignored.
- [ ] Desktop idle hide outside full screen too.
- [ ] Open menu, sheet or chat keeps controls visible.
- [ ] Layout menu on long-press/right-click removed; video grid test updated.
