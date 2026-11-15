# 08: Leave-first pop-up and Call again

**What to build:** While I am in a call, any action that would put me in a different call first asks "Leave current call?" with Cancel and Leave and join. This covers Join buttons, picture menu items, incoming-call Accept, room links and Call again in the calls history. Call again on a conversation with a live call joins it. Return to call never prompts. Spec stories 11, 60–64.

**Blocked by:** 02 (Pressing call joins the live call), 05 (The call outlives the call screen).

**Status:** ready-for-agent

- [ ] One app-level confirm dialog built from the existing dialog primitives, used by every entry point that would join a different room while a call is active.
- [ ] Cancel leaves the active call untouched; Leave and join ends it and continues into the new call.
- [ ] Returning to the active call from any entry point never prompts.
- [ ] Call again on a conversation with a live call joins that call.
- [ ] Dashboard chat state test: the pop-up appears for Join and Call again while another call is active, Cancel keeps the call, and Call again joins a live call.
