# Spec: Glass buttons and dialogs

**Status:** ready-for-agent

## Problem Statement

Filled buttons look different across the app. Start meeting in the navbar has a teal glass look I like, but most other filled teal buttons are flat, and red buttons (leave, remove friend, quit group) are flat red with no matching glass. Confirmation dialogs, such as the one for quitting a group, each have their own padding and button layout, and on a phone they are centred desktop dialogs instead of the bottom sheets I expect.

## Solution

Every filled button uses one of two glass styles: teal glass for primary actions and red glass for destructive ones, both coming from the button primitives so nobody styles them by hand. Every confirmation uses one shared confirmation dialog: a bottom action sheet on phones and a compact dialog on desktop, with the same spacing everywhere. Form dialogs get the same padding, header and footer rules.

## User Stories

1. As a user, I want every filled primary button to have the same teal glass look as Start meeting, so that primary actions are easy to recognise.
2. As a user, I want every filled destructive button to have a red glass look that matches the teal one, so that dangerous actions are clear but still part of the same design.
3. As a user, I want ghost buttons and red text items in menus to stay flat, so that only the main action in a place stands out.
4. As a pointer user, I want glass buttons to darken on hover and keep white text, so that hover never hurts contrast.
5. As a touch user, I want glass buttons to show a pressed state instead of a hover state, so that touch feedback is clear.
6. As a user in a dark call screen, I want the glass buttons to use the dark tokens, so that they fit the dark stage.
7. As a developer, I want the glass to come from the `accent` and `danger` tones of the button primitives, so that I never add the classes by hand.
8. As a phone user, I want confirmations to open as a bottom action sheet, so that the buttons are within reach of my thumb.
9. As a phone user, I want the action on top and Cancel below, both full width, so that the layout matches the platform I know.
10. As a phone user, I want the sheet to respect the home indicator area, so that no button sits under it.
11. As a desktop user, I want confirmations as a compact centred dialog with the buttons side by side on the right, so that they are quick to answer with the mouse.
12. As a user, I want every confirmation to show an icon, a short title and one line that states the consequence, so that I know what will happen before I confirm.
13. As a user, I want the destructive action in a confirmation to use the red glass, so that I see that it can't be undone.
14. As a keyboard user, I want focus to start on Cancel and Escape to close the confirmation, so that I can't confirm by accident.
15. As a user, I want confirming to run exactly the same action as before (remove friend, quit group, delete group, leave call), so that only the look changes.
16. As a user, I want form dialogs (Create group, Invite and the others) to use the same padding, header and footer, so that all pop-ups feel like one design.
17. As a native app user, I want a `warning` haptic when I confirm a destructive action, so that I feel its weight.

## Implementation Decisions

- Add a red glass style built from the Harbor danger tokens, the twin of the existing teal glass style, with the same sheen, rim, inner shade and hover rule, and dark-scope overrides.
- The `Button` and `RoundButton` primitives map their `accent` tone to the teal glass and a new `danger` tone to the red glass. Ghost, plain, soft and menu-item variants stay flat.
- Migration is expand–contract: tones first, then callers in the workspace and in the call screen and navbar, then no direct use of the glass classes remains outside the primitives.
- New shared `ConfirmDialog` UI primitive: props for icon, title, consequence line, action label and tone, and busy state; emits confirm and cancel. It renders as the existing sheet primitive on phones and as the existing dialog primitive on desktop, switching at the existing phone breakpoint.
- Spacing: 24 px around, 8 px between title and consequence line, 24 px before the buttons, on the Harbor scale.
- Confirmed destructive actions play the `warning` haptic.
- Glossary terms: none new.

## Testing Decisions

- Test what users see and what events fire, not class lists, except that a tone test may assert the glass style is applied.
- Button and RoundButton tone tests, in the style of the existing UI primitive tests.
- ConfirmDialog component test: content, button order per form factor, confirm and cancel events, Escape, initial focus.
- Each migrated confirmation keeps a caller test proving the same action still fires, starting with remove friend in the profile dialog test.
- Prior art: the presence dot, avatar mosaic, meeting invite dialog and profile dialog tests.

## Out of Scope

- Redesigning the Profile and Group info pages (separate spec, blocked by this one).
- New colours: only the existing Harbor tokens are used.

## Further Notes

Comes from the grilling session of 2026-11-12/13.
