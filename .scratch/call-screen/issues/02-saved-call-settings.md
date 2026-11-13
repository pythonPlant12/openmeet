# 02: Saved call settings

**What to build:** A per-device store for the chosen microphone, camera and speaker, the "camera preview seen" flag, and the mic state. It is never synced to the account. A saved device that no longer exists falls back to the system default, and the camera's on state is never saved.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Save and restore devices, the preview-seen flag and the mic state.
- [ ] Missing device falls back to the system default without error.
- [ ] Unavailable or throwing storage does not break the call.
- [ ] Unit tests for each rule.
