# 03: Enter the call without a join dialog

**What to build:** Joining a meeting or a call, or accepting an incoming call, goes straight to the call screen. On the first call on a device, one permission prompt asks for mic and camera and the person enters with both off. Later calls restore the saved devices and mic state; the camera always starts off. A `success` haptic plays on joining.

**Blocked by:** 01 (Camera off releases the camera), 02 (Saved call settings).

**Status:** ready-for-agent

- [ ] The join dialog no longer appears for meetings, calls, or accepted incoming calls.
- [ ] First call: one permission prompt, mic and camera off.
- [ ] Later calls: saved devices and mic state restored, camera off.
- [ ] `success` haptic on joining.
- [ ] The Playwright prejoin test is rewritten; two browsers enter with both off and each turns mic and camera on and reaches the other.
