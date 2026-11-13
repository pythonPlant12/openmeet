# 04: ConfirmDialog, first used by remove friend

**What to build:** A shared confirmation dialog: icon, short title, one consequence line, the action and Cancel. On phones it is a bottom action sheet with full-width stacked buttons (action on top) and safe-area padding; on desktop a compact centred dialog with the buttons side by side on the right. Remove friend is the first confirmation to use it, and a confirmed destructive action plays a `warning` haptic.

**Blocked by:** 01 (Glass tones on Button and RoundButton).

**Status:** ready-for-agent

- [ ] ConfirmDialog primitive built on the existing sheet and dialog primitives, switching at the existing phone breakpoint.
- [ ] Spacing: 24 px around, 8 px title to line, 24 px before the buttons.
- [ ] Focus starts on Cancel; Escape and tapping outside cancel.
- [ ] The action uses the `danger` or `accent` tone as passed.
- [ ] Remove friend uses it and still removes the friend; `warning` haptic on confirm.
- [ ] ConfirmDialog component test and the profile dialog caller test.
