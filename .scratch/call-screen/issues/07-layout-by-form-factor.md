# 07: Layout by form factor

**What to build:** The call screen picks its layout from the number of people, the form factor, the pin and screen share. Phone portrait 1:1: the other person full screen and your own view as a small picture you can drag to any corner. 2–4 people: a 2-column grid that fills the screen. 5 or more: the speaker layout with a scrollable strip. Screen share takes the stage with people in a strip. Phone landscape and desktop: a grid that fits the window's shape.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Layout selection is one pure function with unit tests for each case.
- [ ] Phone 1:1 self-view is draggable and snaps to a corner.
- [ ] Tiles cover-fit with faces centred; no wasted space.
- [ ] Video grid component test per case.
- [ ] Checked by hand at phone portrait, phone landscape and desktop sizes.
