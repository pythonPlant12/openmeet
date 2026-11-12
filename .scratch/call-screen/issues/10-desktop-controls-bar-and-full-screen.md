# 10: Desktop controls bar and full screen

**What to build:** On desktop the controls bar reads [mic▾][camera▾] · [share][chat][⋮] · [leave], with Full screen on the far right. ⋮ holds screen share, invite, layout, pin participant, participants, dev tools and report bug. In full screen, the controls and top bar hide after 3 s without mouse movement and come back on mouse movement. Below the phone breakpoint the phone layout from ticket 09 applies. Losing the connection or a failed reconnect plays an `error` haptic.

**Blocked by:** 05 (Split mic and camera buttons).

**Status:** ready-for-agent

- [ ] Bar layout and ⋮ contents as described, reusing the existing action menu items.
- [ ] Full screen enters and exits; controls auto-hide after 3 s and return on mouse move.
- [ ] `error` haptic on lost connection or failed reconnect.
- [ ] Component test for the ⋮ contents and the auto-hide.
