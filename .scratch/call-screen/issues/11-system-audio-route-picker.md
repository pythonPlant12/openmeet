# 11: System audio route picker

**What to build:** The phone top bar's audio output button opens the system route picker: in the iOS native app the system picker (speaker, earpiece, headphones), in the Android native app the device's output list. In browsers that can switch outputs it opens a Speaker submenu; where they can't (for example iOS Safari) the button is hidden.

**Blocked by:** 09 (Phone call chrome and drag-up controls panel).

**Status:** ready-for-agent

- [ ] Native command in the native app opens the iOS route picker; Android lists outputs.
- [ ] Browser fallback uses output switching where it exists; otherwise the button is hidden.
- [ ] Native app clippy passes.
- [ ] Checked by hand on an iPhone with headphones and on Android.
