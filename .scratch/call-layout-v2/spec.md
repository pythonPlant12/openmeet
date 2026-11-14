# Spec: Call layout v2

**Status:** ready-for-agent

## Problem Statement

The call screen works, but it looks and feels unlike the reference recordings I want it to match. It is light, the tiles are crowded with red mute and camera badges, ⋯ buttons and avatar name tags, the call controls are always on screen, the phone controls carry chevrons, and inviting someone is a small dropdown instead of a sheet with my friends and share targets. On desktop the controls only get out of the way in full screen, and in the speaker layout I can't get rid of the strip.

## Solution

The call screen takes the reference recordings as the model for both its look and its behaviour, with OpenMeet's own icons, words and Harbor tokens. The call screen is always dark. Buttons are rounder grey glass squircles, red-tinted while off and white while on. Tiles show only a name tag. A long-press hides or shows all call controls and name tags together; a tap pins. On a phone, an "Add people" card above the controls bar opens an invite sheet with share targets, the room's access, and my friends. On desktop, the call controls hide after 3 s without mouse movement, and the speaker layout's strip can be collapsed.

## User Stories

### Look

1. As a person in a call, I want the call screen always dark, so that video stands out and the screen matches the reference.
2. As a person in a call, I want the control buttons rounder (squircles between a rounded square and a circle) with a grey glass fill, so that they feel native on Apple devices.
3. As a person in a call, I want my mic or camera button to show a dark red-tinted fill with a red icon while it is off, so that I see my state at a glance.
4. As a person in a call, I want my camera button to show a solid white fill with a dark icon while it is on, so that I know I'm visible.
5. As a person in a call, I want the leave button to stay red, so that I never leave by accident.
6. As a person in the camera preview, I want its buttons to use the same grey fill as the controls bar, so that the preview looks like part of the call.
7. As a person in a call, I want the speaking ring to stay the Harbor accent, so that the app keeps one accent colour.
8. As a person using the rest of the workspace during a call, I want chats and the sidebar to stay light, so that only the call screen changes.

### Tiles

9. As a person in a call, I want tiles without red mute or camera-off badges, so that tiles stay clean.
10. As a person in a call, I want each tile's name tag to be a dark translucent pill with the name only, so that I know who is who without clutter.
11. As a person in a call, I want a mic-off icon inside the name tag when that person is muted, so that I still see who is muted.
12. As a phone user, I want the name tag centred at the bottom of the tile, so that it matches the reference.
13. As a desktop user, I want the name tag at the bottom-left of the tile, so that it matches the reference.
14. As a person in a call, I want the name tag to shrink to the mic-off icon while the call controls are hidden, so that the video is unobstructed but I still see who is muted.
15. As a person in a call, I want an unmuted person's name tag to disappear while the call controls are hidden, so that the video is fully clear.
16. As a touch user, I want no ⋯ button on tiles, so that tiles stay clean.
17. As a touch user, I want tapping a name tag to open that person's menu (pin, full screen, profile, host options) as a small sheet, so that per-person actions are still one tap away.
18. As a desktop user, I want the ⋯ button to appear on hover, so that per-person actions remain reachable with a mouse.
19. As a person in a call, I want an expand icon at the top-right of a video tile, so that I can make that tile full screen.

### Gestures and hiding the call controls

20. As a person in a call, I want tapping a tile to pin that person and switch to the speaker layout, so that I can focus on someone.
21. As a person in a call, I want tapping the pinned tile again to unpin it and return to my previous layout, so that I can go back.
22. As a touch user, I want a long-press anywhere on the video area to hide the top bar, the "Add people" card, the controls bar and the name tags together, so that I can see the video alone.
23. As a touch user, I want another long-press to bring them all back, so that the controls are never lost.
24. As a touch user, I want the call controls to slide and fade out and in, so that the change feels smooth.
25. As a native app user, I want a selection haptic when the call controls hide or show, so that I feel the change.
26. As a touch user, I want a tap on the empty space around the tiles to do nothing, so that I don't change anything by accident.
27. As a phone user, I want the call controls to stay until I long-press, so that they never vanish while I reach for them.
28. As a desktop user, I want the call controls and name tags to hide after 3 s without mouse movement, in and out of full screen, so that nothing covers the video.
29. As a desktop user, I want the call controls to return as soon as I move the mouse, so that I can act straight away.
30. As a person in a call, I want the call controls to stay visible while a menu, a sheet, or the chat is open, so that what I'm using doesn't disappear.
31. As a person in a call, I want the tiles to re-centre smoothly when the call controls hide or show, so that the layout doesn't jump.
32. As a person in a call, I want to choose the layout from the drag-up panel on a phone and from the ⋯ menu on desktop, so that long-press and right-click are free for other actions.

### Phone controls

33. As a phone user, I want the controls bar to read camera, mic, share screen, leave, so that the main actions are in thumb reach.
34. As a phone user, I want no chevrons on the controls bar, so that the bar is simple.
35. As a phone user, I want the drag-up panel to repeat the controls row at its top, so that I can still mute while the panel is open.
36. As a phone user, I want a Show chat row in the panel, so that I can open the chat from it.
37. As a phone user, I want Microphone, Camera, Audio output (only where it can change), Camera quality and Preview camera rows in the panel, so that choosing devices has one home.
38. As a phone user, I want a Layout choice (Grid, Speaker) in the panel, so that I can switch layouts.
39. As a phone user, I want a Show my own camera toggle in the panel, so that I can hide my own tile and see only the others.
40. As a returning caller, I want my Show my own camera choice remembered on this device, so that I don't set it every call.
41. As a phone user, I want an Invite people row in the panel, so that inviting is reachable from there too.
42. As a phone user, I want Developer tools and Report a bug rows at the end of the panel, so that rare actions stay out of the way.
43. As a phone user, I want no participants list with pin buttons in the panel, because tapping a tile already pins.
44. As a phone user, I want the top bar to show the room name pill with ›, then audio output, invite, and chat, so that secondary actions are out of the way.
45. As a phone user with my camera on, I want a camera flip button in the top bar, so that I can switch between front and back cameras.
46. As a phone user, I want tapping the room name to open the drag-up panel, so that the › leads somewhere useful.
47. As a phone user, I want no collapse chevron until the mobile mini call exists, so that I never see a control that does nothing.

### Inviting

48. As a phone user alone in a call, I want an "Add people" card above the controls bar, so that I can bring someone in.
49. As a phone user, I want the "Add people" card to disappear once someone else is in the call, so that it doesn't take space when it's no longer needed.
50. As a phone user, I want the card, the top-bar invite button and the panel's Invite people row all to open the same invite sheet, so that inviting works the same everywhere.
51. As a phone user, I want the invite sheet to be a dimmed bottom sheet titled "Invite people" that I can drag taller, so that I can see more friends.
52. As a person inviting, I want a Share target that opens the system share sheet, so that I can send the link through any app.
53. As a person inviting where the system share sheet doesn't exist, I want no Share target, so that I never see a button that does nothing.
54. As a person inviting, I want Copy link, WhatsApp, Telegram and Email targets, so that the common ways to share are one tap.
55. As a person inviting, I want a QR code target that shows the room link as a QR code, so that someone next to me can scan it.
56. As a person inviting, I want a line under the search showing the room's access (for example "Anyone with the link"), so that I know who can join.
57. As the host, I want "Edit access" on that line to change the access in place, so that I can open or lock the room before sharing.
58. As a signed-in person, I want my friends listed with an Invite button each, so that inviting a friend is one tap.
59. As a signed-in person, I want the search to filter my friends and also find other people, so that I can invite someone who isn't a friend yet.
60. As a person inviting, I want Invite to become a disabled "Invited" after I tap it, so that I don't invite someone twice.
61. As a guest who is not signed in, I want only the share targets and the access line, so that I can still share the link.
62. As a desktop user, I want the same invite content in a centred dark dialog, so that inviting works the same on every device.

### Desktop bars and layout

63. As a desktop user, I want the room name at the top-left of the call screen, so that I know which call I'm in.
64. As a desktop user, I want the chat button at the top-right, so that it is out of the way of the main controls.
65. As a desktop user, I want an invite button at the bottom-left that opens the invite dialog, so that inviting is always visible.
66. As a desktop user, I want the bottom centre to read mic▾, camera▾, share, ⋯, leave, so that the main controls are always in one place.
67. As a desktop user, I want a full screen button at the bottom-right, so that the call can take the whole display.
68. As a desktop user in the speaker layout, I want the strip of other tiles below the large tile, so that the speaker gets most of the space.
69. As a desktop user in the speaker layout, I want a small toggle to collapse the strip, so that the speaker fills the screen.
70. As a desktop user with the strip collapsed, I want my own view as a small picture in a corner, so that I can still see myself.

## Implementation Decisions

- **Supersedes** user stories 33–56 and the styling and "recordings are behaviour only" decisions of the earlier call-screen spec where they conflict. Everything else in that spec still holds: entry without a join dialog, saved call settings, split mic and camera buttons on desktop, camera preview, layout selection by form factor, the haptics map, the audio route picker.
- **Dark stage:** the call screen always applies the existing dark full-screen palette by redefining Harbor tokens in a call-screen scope. Components keep using Harbor tokens; no raw colours.
- **Call button style:** one shared style with a squircle radius between the current rounded square and a full circle, a grey glass fill, and three states: default, off (red-tinted fill, red icon) and on (white fill, dark icon). Leave keeps its red style. The phone top bar, phone controls bar, drag-up panel row, camera preview and desktop bar all use it.
- **Name tag:** the tile's red badge cluster is removed. The name tag owns the mute indicator and has a collapsed form (mic-off icon only, or nothing). On touch, the name tag is the trigger for the person's menu, which reuses the existing tile menu items; desktop keeps the ⋯ button on hover.
- **Call controls visibility (new module):** a composable owns whether the call controls are shown. Interface: a `visible` state; `toggle()` for a long-press; `activity()` for mouse movement; a hold that keeps controls visible while any menu, sheet or chat is open; and an idle timeout (3 s) that applies only on desktop. The call screen creates it once and passes `visible` to the top bar, the "Add people" card, the controls bar and the tiles.
- **Gestures:** a tap on a tile keeps using the existing pin/unpin layout function. The video grid reports a long-press to the call screen instead of opening the layout menu. The right-click layout menu is removed.
- **Phone controls bar and panel:** the drag-up panel keeps its physics; its content changes to the grouped rows. On phone, device selection moves from the split buttons' chevrons into panel rows; desktop keeps the split buttons.
- **Show my own camera:** a per-device setting stored with the saved call settings, never synced. When off, the self tile is left out of the layout input; the camera keeps sending.
- **Phone top bar:** room name pill (opens the panel), audio output, invite, camera flip (only while the camera is on), chat. The collapse chevron stays hidden.
- **Invite content (shared module):** one component holding the share row, search, access line and friends list, shown inside a phone bottom sheet and a desktop dialog. It reuses the current invite dialog's people search and invite calls and the existing access picker for "Edit access". The share row reuses the existing copy-link, WhatsApp and Telegram behaviour, adds the Web Share API (and the native app's share where present), a mail link and a QR code view. The QR code adds one small QR-code library to the client.
- **"Add people" card:** shown on phone only while the person is alone in the call, and hidden with the other call controls.
- **Desktop speaker layout:** the strip's collapsed state is local to the person. While collapsed, the layout reuses the phone 1:1 self-view picture for the person's own tile.
- **ADR 0001:** nothing here ties the call's lifetime to the meeting page.
- **Branding:** the reference app's icons, wording, colours and branding are not copied; lucide icons, OpenMeet copy and Harbor tokens are used.

## Testing Decisions

- Good tests check external behaviour: what the person sees, can tap, and what the call screen does in response. They don't assert on internal state or CSS classes beyond what a person would notice (for example "the name tag shows only the mic-off icon").
- **Call controls visibility composable (new seam, the only one):** unit test with fake timers: long-press toggles; desktop hides after 3 s idle and shows on activity; phone never auto-hides; an open menu, sheet or chat keeps controls visible and releases the hold when closed.
- **Participant tile component test (existing):** name tag content and position, mute icon, collapsed tag, no badges, tapping the name tag opens the person's menu on touch, ⋯ on hover on desktop, expand icon on video tiles.
- **Video grid component test (existing):** tap pins and unpins, long-press is reported to the call screen, collapsed strip shows the self-view picture, Show my own camera off removes the self tile. The layout function's unit test covers any change there.
- **Phone controls component test (existing):** bar order without chevrons, panel rows, Show my own camera toggle.
- **Phone top bar component test (existing):** room name opens the panel; camera flip shows only while the camera is on.
- **Invite dialog test (existing, retargeted to the shared invite content):** share row with Share hidden when the Web Share API is missing, QR code view, access line and host edit, friends list, search, Invite → Invited, guest variant.
- **Saved call settings unit test (existing):** Show my own camera saved and restored.
- **End-to-end (existing):** the multi-participant media test still proves media reaches the other person; the action-menu test is updated for the new invite entry points.
- **Not automated:** squircle look, slide-and-fade timing and haptics; checked by hand on a phone and on desktop against the recordings.
- Prior art: the existing participant tile, video grid, phone controls, phone top bar, invite dialog, call settings and meeting layout tests, and the two Playwright specs.

## Out of Scope

- The mobile mini call and the collapse chevron's behaviour (ADR 0001).
- A pop-out call window and per-call volume.
- Deafen, noise suppression, "Only show videos", soundboard and activities.
- A join lobby: entry stays one tap with no dialog.
- Changes to the rest of the workspace's look.

## Further Notes

- Reference recordings (local to the product owner, not in the repo): the phone call (`ScreenRecording_11-12-2026 24.mov`), the desktop call (`Screen Recording 2026-11-14 at 11.19.58.mov`), and the phone invite flow (`ScreenRecording_11-14-2026 11-52-16_1.MP4`).
- Work happens on `nikita/new-layout-2` in the root repo and the touched submodules.
- The implementation issues in this folder follow this order: dark stage and buttons; tiles and name tag; gestures and hiding; phone controls and panel; phone top bar; invite sheet; desktop bars and strip.
- Glossary terms used: Call screen, Grid layout, Speaker layout, Pin, Camera preview, Name tag, Mini call.
