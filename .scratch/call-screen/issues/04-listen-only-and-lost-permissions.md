# 04: Listen-only and lost permissions

**What to build:** If the person denies mic or camera permission, they still enter and hear and see the others. The affected button shows a warning badge; tapping it asks again. If the permission is permanently denied, a short sheet explains how to allow it, with Open settings in the native app. If a permission is revoked or a track drops during the call, the track stops, the warning shows, and a `warning` haptic plays.

**Blocked by:** 03 (Enter the call without a join dialog).

**Status:** ready-for-agent

- [ ] Denied permission joins listen-only; remote media still plays.
- [ ] Warning badge on the affected button; tapping re-asks.
- [ ] Permanently denied: explanatory sheet; native app shows Open settings.
- [ ] Revoked or dropped track during the call: track stops, warning shows, `warning` haptic.
- [ ] Playwright test for a listen-only participant receiving media.
- [ ] Meeting media control test for the warning state and re-ask.
