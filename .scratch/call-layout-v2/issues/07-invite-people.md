# 07: Invite people: shared content, phone sheet, desktop dialog, "Add people" card

**What to build:** Prefactor the invite dialog into shared invite content (no visible change), then: your friends listed with Invite → disabled "Invited", search filters friends and finds other people. Phone shows it as a dimmed bottom sheet titled "Invite people" that can be dragged taller; desktop as a centred dark dialog. On phone, an "Add people" card above the controls bar shows only while you are alone and hides with the call controls. The card, the top-bar invite button and the panel's Invite people row open it. Spec stories 48–51, 58–60, 62.

**Blocked by:** 01, 03.

**Status:** ready-for-agent

- [ ] Shared invite content used by sheet and dialog.
- [ ] Friends list, search, Invited state.
- [ ] Phone bottom sheet; desktop dialog.
- [ ] "Add people" card only while alone, hides with the call controls.
- [ ] Invite test retargeted to the shared content.
