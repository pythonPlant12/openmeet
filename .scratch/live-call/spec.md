# Spec: Live calls and the mini call

**Status:** ready-for-agent

## Problem Statement

When someone in my group chat has already started a call, pressing the call button gives me "Could not start call." instead of putting me in the call. If I declined the ring, or missed it, there is no way into the call at all. I cannot see from the chat list or the chat header that a call is going on, or who in the group is in it. And once I am in a call, I cannot go back to my chats: leaving the call screen hangs up.

## Solution

A call that at least one person is connected to is a **live call**. Any member of its conversation can join it at any time, silently, from the chat header's Join button or the picture menu. A gradient ring on a picture shows a live call: on the group's picture for a group live call I belong to, on a friend's picture for a direct live call with me, and on the pictures of the members who are in the group's live call in Group info. The ring never shows a friend's call with someone else. In a call, a collapse button at the top-left of the call screen, and browser Back, return me to the dashboard with the call running as a **mini call**: a small draggable tile in a corner showing the person speaking, with mute, leave and expand. Only Leave and a page reload end the call.

## User Stories

### Joining a live call

1. As a group member, I want pressing the call button while the group has a live call to put me in that call, so that I never get an error for a call that already exists.
2. As a group member who declined the ring, I want to still be able to join the live call later, so that declining a ring does not lock me out for an hour.
3. As a group member who missed the ring, I want to join the live call from the chat, so that a missed ring is not a missed call.
4. As a person joining a live call, I want nobody to be rung again, so that joining is silent.
5. As a member who never answered the original ring, I want my ring to keep going until it expires as it does today, so that joining by someone else changes nothing for me.
6. As the second person to press call in the moment between the first person pressing call and entering the room, I want to join the first person's call, so that two calls are never started for one conversation.
7. As a friend, I want a direct live call with me to be joinable from our chat in the same way, so that direct and group calls behave alike.
8. As a person in a chat with a live call I am not in, I want the header's two call buttons replaced by one Join button, so that the action is obvious.
9. As a person in a chat whose live call is my active call, I want the header to show one Return to call button, so that I get back with one tap.
10. As a person in a chat with no live call, I want the video and audio call buttons as today, so that nothing changes for normal calls.
11. As a person using Call again in the calls history for a conversation with a live call, I want to join that call, so that every call action on a conversation with a live call joins it.
12. As a person whose live call ends while I look at the chat, I want the Join button to turn back into the call buttons, so that I never join a call that is over.

### Seeing a live call

13. As a person looking at the conversations list, I want a purple-red-yellow gradient ring on a group's picture while the group has a live call I am a member of, so that I see the call at a glance.
14. As a person looking at the conversations list, I want the same ring on a friend's picture while that friend is in a direct live call with me, so that I see they are waiting or talking.
15. As a friend of someone who is in a call with other people, I want no ring on their picture, so that their calls stay private.
16. As a person in a call, I want the ring on my own conversation's picture whether or not I am in the call, so that the ring means "live" not "mine".
17. As a person in a chat, I want the chat header's picture to carry the same ring under the same two rules, so that the header agrees with the list.
18. As a person viewing Group info, I want the ring on every member who is in the group's live call, so that I see who is talking.
19. As a person viewing a friend's Profile, I want the ring only when there is a direct live call between us, so that the privacy rule holds there too.
20. As a person looking at a chat thread, I want no ring on message sender pictures, so that the thread stays calm.
21. As a person watching the list, I want the ring to appear and disappear as people connect and leave, without reloading, so that it is trustworthy.
22. As a person looking at a picture with the ring, I want the ring to take the place of the presence border, so that a picture never has two borders.
23. As a person looking at a picture with the ring, I want the presence dot to stay as today, so that mic state is not implied.
24. As a person looking at a picture, I want the presence border back as soon as the live call ends, so that presence is never lost.

### The picture menu

25. As a person in a chat with a live call, I want clicking the header picture to open a small menu instead of Profile, so that I can choose.
26. As a person in a direct chat with a live call, I want the menu to read Profile and Join call, so that both actions are one tap away.
27. As a person in a group chat with a live call, I want the menu to read Group info and Join call, so that it matches the direct case.
28. As a person whose live call is my active call, I want the second item to read Return to call, so that the menu reflects where I am.
29. As a person in a chat with no live call, I want clicking the header picture to open Profile or Group info directly, as today, so that nothing changes without a call.
30. As a person using the conversations list, I want rows to keep opening the chat on click, so that the ring changes nothing about navigation there.

### Collapsing the call

31. As a person in a call, I want a collapse button at the top-left of the call screen on phone and desktop, so that I can go back to my chats without hanging up.
32. As a person who collapses the call, I want to land on the dashboard exactly as I left it, with the same selected chat if any, so that I pick up where I was.
33. As a person who presses browser Back on the call screen, I want the call to collapse rather than end, so that Back is safe.
34. As a phone user who uses the system back gesture on the call screen, I want the same collapse, so that the gesture is safe.
35. As a person who navigates to a Profile, Group info, or the account page during a call, I want the call to keep running, so that the whole app is usable in a call.
36. As a person in a call, I want only the Leave button and a page reload to end the call, so that I never hang up by accident.
37. As a guest who is not signed in, I want the full-screen call screen without a collapse button, so that I never see a control that leads nowhere.

### The mini call

38. As a person with a collapsed call, I want a small tile in a corner over the dashboard and every other page, so that the call is always in sight.
39. As a person with a collapsed call, I want the tile to show the person speaking among the others, so that I see who is talking.
40. As a person with a collapsed call, I want the tile to keep the last speaker while nobody speaks, so that it does not flicker.
41. As a person with a collapsed call where someone shares their screen, I want the share in the tile, so that I can follow it.
42. As a person alone in a collapsed call, I want my own view in the tile, so that the tile is never empty.
43. As a person with a collapsed call, I want the tile to show the person's picture and name when their camera is off, so that I still know who it is.
44. As a person with a collapsed call, I want a mic-off mark on the tile's name tag when that person is muted, so that the tile reads like a call screen tile.
45. As a person with a collapsed call, I want tapping the tile to expand back to the full call screen, so that returning is one tap.
46. As a person with a collapsed call, I want an expand button on the tile that does the same, so that the control is discoverable.
47. As a person with a collapsed call, I want a mute button on the tile, so that I can mute without expanding.
48. As a person with a collapsed call, I want a leave button on the tile, so that I can hang up without expanding.
49. As a person with a collapsed call, I want no button that opens the conversation on the tile, so that the tile stays small.
50. As a desktop user, I want the tile's buttons to appear on hover, so that the video stays clear.
51. As a phone user, I want the tile's buttons to show on a press, so that they are reachable by touch.
52. As a person with a collapsed call, I want to drag the tile to any corner, so that it never covers what I am reading.
53. As a person who dragged the tile, I want it to follow my finger or pointer with no lag, so that the drag feels direct.
54. As a person who lets go of the tile, I want it to settle smoothly into the nearest corner, so that the move feels finished.
55. As a person who dragged the tile, I want the corner remembered for the rest of the session, so that it stays where I put it.
56. As a phone user, I want the tile to sit above the bottom bar and clear of the screen's notch and home indicator, so that it is never hidden or clipped.
57. As a person with a collapsed call, I want the tile to vanish when the call ends, so that nothing lingers.
58. As a phone user in a 1:1 call, I want my own self-view picture on the call screen to drag and snap as smoothly as the mini call, so that both feel the same.
59. As a person on the dashboard, I want an incoming ring for another call to show as today, so that the mini call changes nothing about ringing.

### One active call

60. As a person in a call who presses Join on another conversation, I want a pop-up asking whether to end my current call first, so that I never lose a call by accident.
61. As a person in that pop-up, I want Cancel and Leave and join, so that both outcomes are clear.
62. As a person in a call who accepts an incoming ring, I want the same pop-up, so that accepting is safe.
63. As a person in a call who opens a room link, I want the same pop-up, so that links are safe.
64. As a person in a call who chooses Return to call anywhere, I want no pop-up, so that returning is instant.

## Implementation Decisions

- **Terms:** this spec uses the glossary's "live call", "active call", "mini call", "call screen", "Profile", "Group info" and "presence". ADR-0001 was amended on 2026-11-15: the mini call is the only collapsed form on every device; the earlier main-pane and Connected-panel idea is dropped.
- **Live call fact (server):** a live call is an active call session whose room has a meeting with at least one connected participant, or an active call session that nobody has entered yet (story 6). The server already tracks connected participants per meeting and already notifies call members on join and leave; that notification is the trigger for live-call updates.
- **Start-call contract:** starting a call on a conversation that has a live call no longer returns a conflict. It returns the existing session's id and room id, marks the caller as accepted if they were pending, declined, or had no member row (a member added after the call began), and sends no new ring. The response says whether the session was created or joined so the client can skip the "starting" state.
- **Reading a live call (API):** conversations carry their live call: `liveCall: { id, memberIds } | null`. Direct conversations get it only when the live call is between the two people. Group conversations get it for any member of the group. `memberIds` lists the users currently connected to the call's room, which is what Group info and Profile need. This is served on the conversation list, on a single conversation, and re-fetched on the existing calls live-update event, so no new event type is needed.
- **Privacy rule lives on the server:** the client never receives another person's calls except through a conversation it is a member of, so the two display rules follow from the data. The client adds no further filtering.
- **Joining through the call screen:** the call screen's current entry (session lookup, then respond-accept) keeps working. The chat header's Join and the picture menu both start a call on the conversation and navigate to the returned session, which is the same path as today for a fresh call.
- **Ring (client):** the picture's presence border gets a third state, "in live call", drawn as the purple-red-yellow gradient with one new Harbor token set for the three stops. While in that state the presence border classes are not applied. The presence dot stays. The ring is applied in the conversations list rows, the chat header, Group info member rows and Profile; nowhere else.
- **Header call controls:** the chat header's call buttons become a single Join or Return to call button by reading the conversation's live call and the active call's session. The picture button opens a dropdown (existing menu primitives) with Profile or Group info and Join call or Return to call only while a live call exists.
- **Call ownership moves to the app shell:** the WebRTC actor already lives in the app shell. Everything that today ends the call when the call screen unmounts (end call, screen share stop, audio output following, ringing cancel) moves to an app-level active call owner, so unmounting the call screen only tears down the screen. The call screen becomes a view of the active call. The webrtc machine gains the collapsed state as context, not as a new machine state: `collapsed: boolean` toggled by COLLAPSE and EXPAND, and the active call's conversation id and session id are kept in context so the dashboard can recognise its own live call.
- **Collapse and routing:** the call screen's top-left button sends COLLAPSE and navigates to the dashboard. The dashboard restores its last state from the existing remembered sidebar and selected-chat state. Browser Back from the call screen is treated as collapse by a route leave guard that sends COLLAPSE instead of ending the call. Expand navigates back to the call's room route. The room route, when opened while that call is already active, shows the call screen without re-joining.
- **Mini call (new module, one component):** rendered by the app shell while an active call is collapsed and the user is signed in. Interface: it reads the active call from the WebRTC composable; emits expand, toggle-mute and leave. It chooses one tile in this order: a screen share, the current speaker among others, the last speaker, the self view when alone. It reuses the participant tile for the video, picture, name tag and mic-off mark, in mobile size.
- **Corner drag (new shared module, one composable):** one corner-drag composable owns pointer capture, the drag threshold, the live offset during a drag and the snap to the nearest corner. During the drag the element moves with a transform only, with no transition. Only the snap animates, with the existing snap easing. The video grid's self-view and the mini call both use it; the self-view's inline drag code is removed. Safe-area insets and the phone bottom bar are passed in as edges.
- **Leave-first pop-up:** one app-level confirm dialog (existing dialog primitives) used by every entry point that would join a different room while a call is active: Join buttons, picture menu items, incoming-call Accept, room links, and Call again. Returning to the active call never prompts.
- **Guests:** the collapse button and the mini call render only for signed-in users; ADR-0001 keeps guests on the full-screen call screen.
- **Not changed:** the signaling contract, the SFU, the ringing flow, the presence system, and the call history, beyond the Call again rule.

## Testing Decisions

- Good tests check what the person sees and can do: a ring on a picture, a Join button, a menu with two items, a tile that ends in the bottom-left corner, a call that is still connected after Back. They do not assert on machine internals or CSS classes beyond what a person notices.
- **End-to-end, two browsers (existing seam, the Playwright multi-participant media spec as prior art):** A starts a group call; B's chat header shows Join; B joins the same room and both see each other's media. B collapses; B's dashboard shows the mini call with A; B expands and is back in the call. This proves stories 1, 8, 31, 38 and 45 against the real server.
- **Conversations sidebar component test (existing):** the ring appears on a group row with a live call and on a direct row whose live call includes me; no ring for any other case; the ring replaces the presence border; rows still open the chat.
- **Chat pane component test (existing):** Join and Return to call replace the call buttons; picture click opens the two-item menu with a live call and opens Profile or Group info without one; the menu's second item wording.
- **Group info and Profile component tests (existing):** ring on members who are in the live call; no ring on others; Profile ring only for a direct live call with me.
- **Dashboard chat state test (existing):** Call again on a conversation with a live call joins it; the leave-first pop-up appears when another call is active and Cancel leaves the active call untouched.
- **WebRTC machine unit test (existing):** COLLAPSE keeps the call connected; EXPAND restores; LEAVE_ROOM ends it; the active call's conversation and session ids are kept in context.
- **Mini call component test (new component, existing browser test pattern):** tile choice order with and without a screen share, speaker changes, alone; picture and name when camera is off; expand, mute and leave emit; buttons on hover on desktop and on press on touch; disappears when the call ends.
- **Corner drag composable test (new, with pointer events in the browser runner, prior art is the video grid's self-view drag test):** the element follows the pointer with no transition during the drag; releasing snaps to the nearest corner; a move under the threshold is a tap; the corner is kept. The video grid's self-view test keeps passing on the shared composable.
- **Server unit tests (existing, database-free, in the call-sessions module):** the classification of "created" versus "joined" and of which member rows become accepted stays in a pure function with a test; the live-call SQL condition gets a test like the existing room-admission one.
- **Not automated:** the gradient's look, the snap's feel and the haptics; checked by hand on a phone and on desktop.

## Out of Scope

- Mic state on pictures outside the call screen.
- A live-call banner inside the chat thread.
- An "Open conversation" button on the mini call.
- Automatic resume of a call after a page reload.
- Guests collapsing a call.
- Changes to ringing, to who is rung, or to the ring's expiry.
- Multiple active calls.
- Showing a friend's calls with other people in any form.

## Further Notes

- The ring's three colours are one new token set in the Harbor palette so dark scopes can restyle them; no raw hex in components.
- The glossary term "live call" was added during the grilling session; "active call" keeps meaning the one you are connected to, and the spec never uses "ongoing call" or "call in progress".
- The self-view drag's lag comes from moving the picture through its layout position while a transition class is still attached; the shared composable fixes both pictures at once.
