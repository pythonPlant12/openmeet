# 01: Glass tones on Button and RoundButton

**What to build:** The `accent` tone of `Button` and `RoundButton` renders the teal glass, and a new `danger` tone renders a red glass built from the Harbor danger tokens with the same sheen, rim, inner shade, hover and dark-scope rules. The places that apply the teal glass class directly move to the tone.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Red glass style exists beside the teal one, using only Harbor danger tokens, with pointer-only hover and dark-scope overrides.
- [ ] `accent` and `danger` tones apply the glass; ghost, plain, soft and menu-item variants stay flat.
- [ ] The existing direct uses of the teal glass class go through the tone instead.
- [ ] Tone tests for both primitives.
- [ ] Start meeting looks unchanged in the running app.
