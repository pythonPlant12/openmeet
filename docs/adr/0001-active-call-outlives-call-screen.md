# The active call outlives the call screen

A signed-in user's call keeps running while they use the rest of the workspace: on desktop it sits in the workspace's main pane with a Connected panel in the sidebar, and on mobile the call screen collapses to a mini call. So the call's connection and media belong to the app, not to the meeting page, and leaving or unmounting the call screen no longer ends the call. We chose this over the earlier page-scoped call, which was simpler and ended the call on navigation, because people expect to read and answer chats during a call.

## Consequences

- Only one active call exists at a time. Joining another room asks to leave the current one first.
- A `/room/:id` link opened while signed in opens the call inside the workspace. Guests keep the full-screen call screen.
- Reloading the page ends the active call. There is no automatic resume.
