# The active call outlives the call screen

A signed-in user's call keeps running while they use the rest of the workspace. The call screen collapses to a mini call, a small draggable tile over the dashboard and every other page, on every form factor. So the call's connection and media belong to the app, not to the meeting page, and leaving or unmounting the call screen no longer ends the call. We chose this over the earlier page-scoped call, which was simpler and ended the call on navigation, because people expect to read and answer chats during a call. An earlier form of this decision put the desktop call in the workspace's main pane with a Connected panel in the sidebar; that was dropped before being built in favour of one collapsed form, the mini call, for every device.

## Consequences

- Only one active call exists at a time. Joining another room asks to leave the current one first.
- A `/room/:id` link opened while signed in opens the call inside the workspace. Guests keep the full-screen call screen.
- Only the Leave button and a page reload end the call. Browser Back and the call screen's collapse button collapse it to the mini call. There is no automatic resume after a reload.
