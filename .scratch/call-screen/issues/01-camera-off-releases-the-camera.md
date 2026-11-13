# 01: Camera off releases the camera

**What to build:** Turning the camera off stops the camera, so the device's camera light goes off. Turning it on captures the camera again and the other people see the video again, without the call reconnecting.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Camera off stops the track and replaces the sender's track with nothing.
- [ ] Camera on captures again with the active camera and quality, and replaces the track on the same sender; no renegotiation.
- [ ] Mic mute behaviour is unchanged.
- [ ] Two-browser Playwright test: the other person sees video after off → on.
- [ ] Existing multi-participant e2e tests pass.
