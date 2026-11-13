# 02: Chat view title transition and view-switch haptics

**What to build:** Changing the chat view blurs the old title out (about 200 ms), swaps the word at peak blur, and blurs the new title in (about 200 ms); the search placeholder swaps at the same moment. With reduced motion the title swaps instantly. Every pane's top-right view switch, and the header swipe, plays one `selection` haptic per view change.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Title blur-out, swap at peak blur, blur-in; the old and new titles never overlap.
- [ ] Search placeholder changes together with the title, without its own animation.
- [ ] `prefers-reduced-motion` swaps the title with no animation.
- [ ] One `selection` haptic per committed view change, from a tap or a swipe; none during the drag.
- [ ] The Groups and New panes' view switches play the same haptic.
- [ ] Conversations sidebar component test covers the transition, the reduced-motion swap, and the haptic from tap and swipe, with the haptics service mocked.
