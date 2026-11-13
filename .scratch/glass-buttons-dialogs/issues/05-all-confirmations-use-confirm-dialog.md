# 05: All other confirmations use ConfirmDialog

**What to build:** Quit group, delete group, leave call and every other confirmation in the app use the shared confirmation dialog, with the same actions as before and a `warning` haptic on destructive confirms. The old one-off confirmation markup is removed.

**Blocked by:** 04 (ConfirmDialog, first used by remove friend).

**Status:** ready-for-agent

- [ ] Every confirmation in the app uses ConfirmDialog; none keeps its own markup.
- [ ] Each confirmation still runs the same action, covered by its caller test.
- [ ] Titles and consequence lines are short and specific ("Quit Design team?" / "You'll stop receiving its messages.").
- [ ] Checked by hand on phone and desktop widths.
