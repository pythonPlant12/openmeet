# Spec: Call screen

**Status:** ready-for-agent

## Problem Statement

Every time I join a meeting or a call, a heavy join dialog asks me to pick my mic and camera again, because nothing is remembered. In the call, tapping the mic opens a menu instead of muting, so muting takes two steps. On a phone, the tiles waste space, the controls bar is crowded and hard to reach, and the chat covers the video. There is no physical feedback for my own actions in the call, although the messenger has it.

## Solution

I enter the call straight away. On my first call on a device, the app asks once for mic and camera permission and I enter with both off; the first time I turn the camera on, a camera preview lets me check myself and pick devices. After that, the app remembers my devices and my mic state, and the camera always starts off. The mic and camera are split buttons: tap to toggle, chevron for devices and settings. The layout adapts to phone portrait, phone landscape and desktop, tiles can be pinned, and the controls are arranged for each form factor. Haptics confirm my own actions and a few high-signal call events.

## User Stories

1. As a person joining a call, I want to enter without a join dialog, so that joining takes one tap.
2. As a first-time caller on a device, I want one permission prompt for mic and camera when I enter, so that I'm asked only once.
3. As a first-time caller, I want to enter with mic and camera off, so that nobody sees or hears me before I'm ready.
4. As a person who denied permission, I want to still hear and see the others, so that I can follow the call.
5. As a person who denied permission, I want the mic and camera buttons to show a warning I can tap to ask again, so that I can fix it without leaving.
6. As a person whose permission was permanently denied, I want a short sheet that explains how to allow it, with Open settings in the native app, so that I know what to do.
7. As a person whose permission is revoked during a call, I want the affected track to stop and its button to show the warning, so that I know why the others lost me.
8. As a person whose track dropped, I want a warning haptic, so that I notice even when I'm not looking.
9. As a first-time caller, I want my first camera turn-on to open a camera preview, so that I can check how I look before others see me.
10. As a person in the camera preview, I want microphone and camera selects over the bottom of the video, so that I can pick devices while I see the result.
11. As a person in the camera preview, I want a Turn on camera bubble below the video, so that confirming is one tap.
12. As a person in the camera preview, I want tapping outside to close it and leave the camera off, so that I can back out.
13. As a returning caller, I want my first camera turn-on to switch the camera on straight away, so that I'm not asked again.
14. As a returning caller, I want Preview camera in the camera menu, so that I can check myself whenever I want.
15. As a first-time caller, I want my first mic tap to simply unmute, so that the mic has no extra step.
16. As a returning caller, I want my chosen devices and my mic state restored, so that I don't set them up again.
17. As a returning caller, I want the camera to always start off, so that it never turns on by surprise, for example when I accept an incoming call.
18. As a person whose saved device is unplugged, I want the call to use the system default without asking, so that joining never blocks.
19. As a person accepting an incoming call from a chat, I want the same no-dialog entry, so that answering is instant.
20. As a person in a call, I want tapping the mic button to mute or unmute directly, so that muting is one step.
21. As a person in a call, I want tapping the camera button to turn it on or off directly, so that it's one step.
22. As a person in a call, I want a muted mic or an off camera to show red, so that I see my state at a glance.
23. As a person in a call, I want a chevron inside the button, after a small separator, to open the device menu, so that switching devices is always available.
24. As a person in a call, I want the mic menu to list microphones, speakers (where the platform can switch them), and an input volume slider with a live level meter, so that I can fix my audio without leaving.
25. As a person in a call, I want the camera menu to list cameras, Preview camera, and Quality, so that I can adjust my video.
26. As a person in a call, I want my camera light to go off when the camera is off, so that I trust it's really off.
27. As a person in a call, I want turning the camera back on to reach the others without the call reconnecting, so that nothing interrupts.
28. As a phone user in a 1:1 call, I want the other person full screen and my own view as a small picture I can drag to any corner, so that I see them as large as possible.
29. As a phone user in a call of 2–4 people, I want a 2-column grid that fills the screen, so that no space is wasted.
30. As a phone user in a call of 5 or more, I want the person speaking large and the others in a strip I can scroll, so that the call stays readable.
31. As a phone user, I want a screen share to take the stage with people in a strip, so that I can read the shared screen.
32. As a landscape or desktop user, I want a grid that fits the window's shape, so that tiles use the space well.
33. As a person in a call, I want tapping a tile to pin that person and switch to the speaker layout, so that I can focus on them.
34. As a person in a call, I want tapping the pinned tile again to unpin it and return to my previous layout, so that I can go back.
35. As a person in a call, I want my pin to be only mine, so that I don't change anyone else's view.
36. As a touch user, I want a long-press on the tile area to open the layout menu (Grid or Speaker), so that I can switch layouts.
37. As a desktop user, I want a right-click on the tile area to open the same layout menu, so that it works with a mouse.
38. As a person in a call, I want a tile to shrink slightly while I press it, so that I see my touch landed.
39. As a person in a call, I want a teal ring around the person speaking, so that I know who is talking.
40. As a person in a call, I want a ⋯ button on each tile (on hover on desktop, always on touch), with pin, full screen for that tile, and the participant's options, so that per-person actions are close at hand.
41. As a phone user, I want a top bar with the room name, audio output, invite and chat, so that secondary actions are out of the way.
42. As a phone user, I want a bottom bar with mic, camera, share and leave, with safe-area padding, so that the main actions are in thumb reach.
43. As a phone user, I want to swipe up the bottom bar to reveal the rest of the controls and settings, so that I reach everything with one hand.
44. As a phone user, I want chat to open as a bottom sheet that I can expand, so that the video stays visible.
45. As a phone user, I want the audio output button to open the system's route picker (speaker, earpiece, headphones), so that I can choose where I hear the call.
46. As a browser user where output switching exists, I want a Speaker submenu instead, and no button where it doesn't, so that I never see a control that does nothing.
47. As a desktop user, I want the bar to read mic▾, camera▾ · share, chat, ⋮ · leave, so that the main controls are always visible.
48. As a desktop user, I want the ⋮ menu to hold screen share, invite, layout, pin participant, participants, dev tools and report bug, so that rarer actions have one home.
49. As a desktop user, I want a Full screen button, so that the call can take the whole display.
50. As a desktop user in full screen, I want the controls to hide after 3 s without mouse movement and to come back when I move the mouse, so that nothing covers the video.
51. As a narrow-window desktop user, I want the phone layout below the phone breakpoint, so that the call still fits.
52. As a native app user, I want a light haptic when I toggle my mic or camera, so that I feel the change.
53. As a native app user, I want a medium haptic when a device menu or the layout menu opens, and when I confirm leaving, so that heavier actions feel heavier.
54. As a native app user, I want a selection haptic on pin, unpin, a layout change, and the controls panel snapping, so that state changes are felt.
55. As a native app user, I want a success haptic when I join and an error haptic when the connection is lost or reconnecting fails, so that I notice what happened.
56. As a native app user, I want no haptic when other people join, leave or raise a hand, so that the phone doesn't buzz all call long.

## Implementation Decisions

- Glossary terms: **Meeting**, **Call**, **Call screen**, **Grid layout**, **Speaker layout**, **Pin**, **Camera preview**. Workstream applies to both meetings and calls, because they share the call screen.
- Media path prefactor: turning the camera off stops the camera track and replaces the sender's track with nothing; turning it on captures again and replaces the track on the same sender, like the existing device switch. No renegotiation. The mic keeps disabling its track.
- Entry: the call screen captures mic and camera once at entry (the one permission prompt) and adds both senders, then starts with the mic disabled and the camera stopped. If capture fails, the call continues listen-only; the media path must accept a call with no local tracks.
- New saved call settings module, per device, never synced: chosen microphone, camera and speaker, the "camera preview seen" flag, and the mic state. Missing devices fall back to the system default. The camera's on state is never saved.
- The join dialog is removed from the meeting and call flows; its device preview moves into the new camera preview pop-up.
- The meeting media control becomes a split button: the main part toggles, the chevron opens the menu. Input volume is a gain stage on the outgoing mic with a live level meter.
- Layout selection is a pure function of the number of people, the form factor, the pin, and screen share; the video grid renders its result. Pins are local and single; a pin switches to the speaker layout, and unpinning returns to the previous layout. The existing layout and pin actions in the meeting action menu are reused.
- Phone chrome: top bar (room name, audio output, invite, chat; collapse is hidden until the active call work lands), bottom bar (mic▾, camera▾, share, leave) with a drag-up panel holding the rest. Desktop: centred bar with ⋮ and Full screen.
- Audio output: a native command opens the iOS route picker and the Android output list; browsers use `setSinkId` where it exists, otherwise the control is hidden.
- Haptics map: toggle `light`; menu open, layout menu, leave confirmed `medium`; pin, unpin, layout change, panel snap `selection`; joined `success`; permission lost or track dropped `warning`; connection lost or reconnect failed `error`; nothing for other people's events.
- Styling: Harbor tokens only; the speaking ring is the Harbor accent; glass tones come from the glass-buttons spec when it has landed.
- Respect ADR 0001 (the active call outlives the call screen): nothing here may tie the call's lifetime more tightly to the meeting page.

## Testing Decisions

- Test external behaviour: what the person sees and hears, which events and haptics fire; never internal state.
- Main seam: the multi-participant Playwright test with two browsers. It proves entry without a join dialog with mic and camera off, that turning each on later reaches the other person, that camera off → on still reaches them, and that a device change still reaches them. The existing prejoin test is rewritten.
- Meeting media control component test: split button toggle, chevron menu, warning state and re-ask.
- Video grid component test: layout per people count, form factor, pin and screen share; tap to pin, long-press for the layout menu.
- Saved call settings unit test: save, restore, missing-device fallback, camera never restored on.
- Haptics are mocked at the haptics service.
- Not automated: the drag-up panel's physics and the native audio route command; checked by hand on a phone.
- Prior art: the multi-participant media e2e, meeting media control, participant tile, meeting action menu, and video quality tests.

## Out of Scope

- The active call that keeps running while browsing the workspace, the mini call, and the collapse button's behaviour (ADR 0001, separate spec).
- Native background audio.
- Signed-in workspace polish, Profile and Group info pages.

## Further Notes

The two screen recordings shown in the grilling session are references for behaviour only; the look stays Harbor.
