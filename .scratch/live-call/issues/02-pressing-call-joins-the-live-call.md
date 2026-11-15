# 02: Pressing call on a conversation with a live call joins it

**What to build:** When a group or direct conversation already has a live call, pressing the call button puts me in that call instead of showing "Could not start call." A member who declined or missed the ring, or was added after the call began, can join too. Nobody is rung again. Spec stories 1–7, 12.

**Blocked by:** None (can start immediately).

**Status:** done

- [x] Starting a call on a conversation with an active session returns that session's id and room id, says whether it was created or joined, and no longer returns a conflict.
- [x] The caller's member row becomes accepted whether it was pending, declined, or missing; members who never answered keep their original ring and expiry.
- [x] A session nobody has entered yet counts as joinable (the second caller in the gap joins the first caller's session).
- [x] A session whose meeting has ended still gives way to a new call, as today.
- [x] The client skips the "starting" state when the response says joined and navigates to the session as it does for a fresh call.
- [x] Pure server tests for the created-versus-joined classification and for which member rows become accepted.
- [x] Two-browser e2e test: A starts a group call, B presses the header's call button, both see each other's media in one room.
