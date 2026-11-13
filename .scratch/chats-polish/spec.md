# Spec: Chats polish

**Status:** ready-for-agent

## Problem Statement

On a phone, swiping right to leave a chat works only when the chat has messages. In an empty chat the swipe does nothing, so I'm stuck hunting for the back arrow. When I switch the chat view (Chats, Group chats, Friends chats) the title snaps to the new word with no transition, and the switch gives no physical feedback in the native app, while the rest of the messenger does.

## Solution

Swipe-back works in every chat, empty or not. Changing the chat view blurs the old title out, swaps the word at the peak of the blur, and blurs the new title in. Every pane's top-right view switch plays a light selection haptic, whether the change came from a tap or a swipe.

## User Stories

1. As a phone user, I want a right swipe in an empty chat to go back, so that I leave a chat the same way whether it has messages or not.
2. As a phone user, I want the swipe-back in an empty chat to ignore swipes that start on its buttons or fields, so that I can still use them.
3. As a phone user, I want swipe-back in a full chat to keep starting a reply when I swipe a message, so that nothing I rely on changes.
4. As a user, I want the chat view title to blur out and the new title to blur in, so that the change feels deliberate instead of abrupt.
5. As a user, I want the word to change at the moment of the strongest blur, so that I never see the two titles overlap.
6. As a user, I want the search placeholder to follow the chat view at the same moment, so that the header always describes one chat view.
7. As a user who prefers reduced motion, I want the title to change instantly, so that the interface respects my setting.
8. As a native app user, I want a selection haptic when I change the chat view with the top-right switch, so that I feel the change.
9. As a native app user, I want the same haptic when I change the chat view with a swipe on the header, so that both ways feel the same.
10. As a native app user, I want the haptic on the Groups and New panes' view switches too, so that every pane behaves alike.
11. As a native app user, I want exactly one haptic per view change and none during the drag, so that feedback stays meaningful.
12. As an Android browser user, I want the existing vibration fallback to play for the view change, so that I get the same feedback where the browser supports it.

## Implementation Decisions

- The swipe-back gesture in the chat pane excludes interactive targets; the empty state of a chat must not block the gesture. Find the root cause (an excluded element covering the empty chat, or an area that does not receive the pointer events) and fix it there, without widening the excluded list.
- The title transition is about 200 ms blur-and-fade out, word swap at peak blur, about 200 ms blur-and-fade in, built with the motion library the sidebar already uses. `prefers-reduced-motion` swaps without animation.
- The chat view switch and the header swipe both call the existing haptics service with the `selection` feedback once per committed view change.
- Glossary terms: **Chat view** (Chats, Group chats, Friends chats).

## Testing Decisions

- Test external behaviour only: what the user sees and which haptic is requested, never internal state.
- The chat pane component test covers swipe-back in an empty chat and the excluded targets.
- The conversations sidebar component test covers the title transition (and the reduced-motion swap), the placeholder change, and one `selection` haptic per change from a tap and from a swipe.
- Haptics are mocked at the haptics service, as the scroll haptics test does.
- Prior art: the chat pane, conversations sidebar, chat filter controls, and horizontal swipe tests.

## Out of Scope

- Profile and Group info pages, dialogs, and glass buttons (separate specs).
- Any change to the chat view table (titles, actions, order).

## Further Notes

Comes from the grilling session of 2026-11-12/13; see `GLOSSARY.md`.
