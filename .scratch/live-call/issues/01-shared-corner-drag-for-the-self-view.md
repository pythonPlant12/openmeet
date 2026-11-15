# 01: Shared corner drag for the self-view

**What to build:** On a phone 1:1 call, dragging my own self-view picture follows my finger with no lag, and letting go settles it smoothly into the nearest corner. The drag logic becomes one shared corner-drag composable that the mini call reuses later. Spec stories 53, 54, 58.

**Blocked by:** None (can start immediately).

**Status:** done

- [x] One corner-drag composable owns pointer capture, the drag threshold, the live offset and the snap to the nearest corner; the video grid's inline self-view drag code is removed.
- [x] During a drag the picture moves with a transform only and no transition; only the snap animates, with the existing snap easing.
- [x] A move under the threshold is a tap and does not change the corner; a drag does not pin, long-press or hide the call controls.
- [x] Safe-area edges are passed in, so the picture keeps clear of the notch and home indicator in full screen as today.
- [x] Composable test with pointer events: follows the pointer, snaps to the nearest corner on release, keeps the corner, treats a short move as a tap. The video grid's self-view test still passes.
