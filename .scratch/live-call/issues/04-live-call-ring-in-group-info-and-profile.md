# 04: Live call ring in Group info and Profile

**What to build:** In Group info, every member who is currently in the group's live call shows the gradient ring; other members keep their presence border. On a friend's Profile the ring shows only while there is a direct live call between us. Spec stories 18, 19.

**Blocked by:** 03 (Live call ring in the conversations list and the chat header).

**Status:** ready-for-agent

- [ ] Group info member rows read the group's live call `memberIds` and apply the ring to those members, live as they join and leave.
- [ ] Profile applies the ring only when the direct conversation with that person has a live call.
- [ ] No other surface gains the ring.
- [ ] Group info and Profile component tests cover members in and out of the call, and the Profile privacy rule.
