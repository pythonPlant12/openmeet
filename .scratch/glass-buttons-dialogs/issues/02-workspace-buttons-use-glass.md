# 02: Workspace filled buttons use the glass tones

**What to build:** Every filled teal or red button in the signed-in workspace (panes, chat, friends, groups, calls, account) uses the `accent` or `danger` tone, so they all show the glass look. Ghost buttons and red menu text stay flat.

**Blocked by:** 01 (Glass tones on Button and RoundButton).

**Status:** ready-for-agent

- [ ] No filled teal or red button in the workspace keeps a flat one-off style.
- [ ] No direct use of the glass classes outside the primitives in the workspace.
- [ ] Existing workspace component tests pass; type-check, lint and build pass.
- [ ] Checked by hand on phone and desktop widths.
