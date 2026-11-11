# Chats Header Switcher Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the single teal "+" button in the Chats header with a two-button control that cycles the list between Chats, Group chats and Friends chats. The teal action and the switch icon change with the view, and a horizontal swipe on the header also cycles the views.

**Architecture:** One pure module, `conversations/chat-filter.ts`, holds the three views (title, search label, empty text, teal action, switch target) and the filtering function. `ChatFilterControls.vue` renders the two buttons with animated icon changes. `ConversationsSidebar.vue` owns the current view through `v-model:filter`, and `DashboardPage.vue` filters with it. The swipe reuses `useHorizontalSwipe` from the media viewer plan.

**Tech Stack:** Vue 3 `<script setup>`, TypeScript, motion-v (`AnimatePresence`, `motion`), `@respeak/lucide-motion-vue` animated icons, Harbor `RoundButton`/`RoundButtonGroup`, Vitest + @vue/test-utils.

**Spec:** the Requirements section below, taken from the request on 2026-11-11.

**Depends on:** `docs/plans/2026-11-11-001-feat-media-viewer-plan.md` Task 2 (`useHorizontalSwipe`). Run that plan first, or move Task 2 of that plan to the front of this one.

## Requirements

From the user (mobile and desktop chats):

1. Instead of the single green button, show a control in the style of the reference image. The left button is green, and both its icon and its color change with the view.
2. The icons and actions can be swiped, and the search follows the view.
3. In "Chats" the left (green) button starts a meeting. The other button shows the animated group icon.
4. Tapping it switches the title and the search to "Group chats". The left button becomes Create new group (green). The other button now switches to "Friends chats".
5. In "Friends chats" the left button is Add new friend (green), which moves you to the friends search list. The other button switches back to "Chats", where everything is shown.

The reference image ("Image #2") did not come through to the planner. The layout below is the planner's reading: one white `RoundButtonGroup` pill on the header's right, holding [teal action][switch]. **The user should confirm against the image before Task 3 starts.**

Calls made in this plan (the user can override them):

| View (`ChatFilter`) | Title | Search label | Teal action | Switch button → next view |
|---|---|---|---|---|
| `all` | Chats | Search chats | Start meeting, `CirclePlusAnimated` | `UsersAnimated`, "Show group chats" → `groups` |
| `groups` | Group chats | Search group chats | Create group, `UsersRoundAnimated` | `MessageCircleAnimated`, "Show friends chats" → `direct` |
| `direct` | Friends chats | Search friends chats | Add friend, `UserRoundPlusAnimated` | `MessageSquareAnimated`, "Show all chats" → `all` |

- A left swipe on the header (title row) goes to the next view in the table. A right swipe goes to the previous one (`all` ← `direct` wraps).
- The search text is kept when the view changes, and the results are re-filtered.
- Pending direct-message requests show in `all` and `direct`. Group invitations show in `all` and `groups`.
- The open conversation stays open even when the new view hides its row.
- The header badge keeps counting all conversations, whatever the view.
- The view starts at `all` on each load and is not persisted.

## Global Constraints

- Colors only from Harbor tokens. Teal actions use `RoundButton tone="accent"` (white icon, hover to `harbor-accent-hover`). The switch uses `tone="plain"` inside a `RoundButtonGroup` (AGENTS.md Styling Guide).
- Hover is pointer-only. Touch uses explicit active state.
- Every button has an `aria-label` and `title` with the action name from the table.
- Respect `prefers-reduced-motion`: icons and title switch without animation.
- Client gates: `pnpm type-check`, `pnpm lint`, `pnpm test:unit --run`, `pnpm build` pass.
- Commits are Conventional Commits with a scope, inside `openmeet-client/`, with no AI attribution lines.

## Review Focus

1. A search with a query that matches only rows outside the view shows the view's own empty text, not "No conversations yet". Test in Task 1 (`emptyText` per view) and Task 3 (`shows the view's empty text`).
2. Selecting text or typing in the search field must not count as a header swipe. `useHorizontalSwipe` already ignores `input`. Test in Task 3 (`does not switch views from a drag in the search field`).
3. Add friend must open the friends search on mobile too, where the sidebar shows one section at a time. Test in Task 4 (`add-friend opens the people search`).
4. Switching views must not clear the search query. Test in Task 3 (`keeps the query when switching views`).
5. The open conversation stays selected after a view change that hides it. Test in Task 4 (`keeps the selected conversation open`).

---

## File Structure

- Create `openmeet-client/src/components/dashboard-page/conversations/chat-filter.ts`: view table, `nextChatFilter`, `previousChatFilter`, `filterConversations`.
- Create `openmeet-client/src/components/dashboard-page/conversations/__tests__/chat-filter.test.ts`
- Create `openmeet-client/src/components/dashboard-page/conversations/ChatFilterControls.vue`: the [teal action][switch] pill.
- Create `openmeet-client/src/components/dashboard-page/conversations/__tests__/ChatFilterControls.test.ts`
- Modify `openmeet-client/src/components/dashboard-page/conversations/ConversationsSidebar.vue:163-193`: header, `v-model:filter`, swipe, `add-friend` event, empty text, request and invitation visibility.
- Modify `openmeet-client/src/components/dashboard-page/conversations/__tests__/ConversationsSidebar.test.ts`
- Modify `openmeet-client/src/pages/DashboardPage.vue`: `chatFilter` ref, `filteredConversations` (line 396), `@add-friend` (near line 2452).

### Task 1: View table and filtering

**Files:**
- Create: `openmeet-client/src/components/dashboard-page/conversations/chat-filter.ts`
- Test: `openmeet-client/src/components/dashboard-page/conversations/__tests__/chat-filter.test.ts`

**Interfaces:**
- Produces:
  - `export type ChatFilter = 'all' | 'groups' | 'direct'`
  - `export type ChatFilterAction = 'start-meeting' | 'create-group' | 'add-friend'`
  - `export interface ChatFilterView { title: string; searchLabel: string; emptyText: string; noMatchText: string; action: ChatFilterAction; actionLabel: string; actionIcon: Component; next: ChatFilter; switchLabel: string; switchIcon: Component }`
  - `export const CHAT_FILTER_VIEWS: Record<ChatFilter, ChatFilterView>`: values from the Requirements table. `emptyText`: "No conversations yet." / "No group chats yet." / "No friends chats yet.". `noMatchText`: "No conversations match your search." / "No group chats match your search." / "No friends chats match your search."
  - `export function nextChatFilter(filter: ChatFilter): ChatFilter` and `export function previousChatFilter(filter: ChatFilter): ChatFilter`
  - `export function filterConversations(conversations: Conversation[], filter: ChatFilter, query: string, nameOf: (conversation: Conversation) => string): Conversation[]`. Kind filter: `groups` → `kind === 'group'`, `direct` → `kind === 'direct'`. Then a case-insensitive substring match on `nameOf`, the same as `DashboardPage.vue:396-403` today. Order is kept.

- [ ] **Step 1: Write the failing tests**

```ts
it('cycles all → groups → direct → all and back', ...)
it('filters by kind and query together, keeping order', ...)   // 2 groups + 2 direct; ('groups','') → 2 groups; ('direct','bo') → the direct named 'Bob'
it('has distinct titles, labels and empty texts per view', ...) // CHAT_FILTER_VIEWS.groups.title === 'Group chats', etc.
```

- [ ] **Step 2: Run to verify failure**

Run: `cd openmeet-client && pnpm test:unit --run src/components/dashboard-page/conversations/__tests__/chat-filter.test.ts`
Expected: FAIL. Module not found.

- [ ] **Step 3: Implement `chat-filter.ts` with the values above**

- [ ] **Step 4: Run to verify pass**

Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add src/components/dashboard-page/conversations/chat-filter.ts src/components/dashboard-page/conversations/__tests__/chat-filter.test.ts
git commit -m "feat(workspace): add chat views for all, group and friends chats"
```

### Task 2: `ChatFilterControls.vue`

**Files:**
- Create: `openmeet-client/src/components/dashboard-page/conversations/ChatFilterControls.vue`
- Test: `openmeet-client/src/components/dashboard-page/conversations/__tests__/ChatFilterControls.test.ts`

**Interfaces:**
- Consumes: Task 1 `ChatFilter`, `ChatFilterAction`, `CHAT_FILTER_VIEWS`.
- Produces: `<ChatFilterControls :filter="ChatFilter" @action="(action: ChatFilterAction) => …" @switch="(next: ChatFilter) => …" />`

Render a `RoundButtonGroup` with two `RoundButton`s: the teal action first (`tone="accent"`) and the switch second (`tone="plain"`). Each icon sits in `AnimatePresence mode="popLayout"` keyed by `filter`, sliding up 8 px with a fade over 200 ms. Play the icon's `animate` prop once after each change, the same way `LiquidTabBar.vue` plays `pressedKey`.

- [ ] **Step 1: Write the failing tests**

```ts
it('labels the buttons for the current view', ...)    // filter 'groups' → buttons aria-label 'Create group' and 'Show friends chats'
it('emits the action and the next view', ...)         // click first → action 'create-group'; click second → switch 'direct'
```

- [ ] **Step 2: Run to verify failure**

Run: `pnpm test:unit --run src/components/dashboard-page/conversations/__tests__/ChatFilterControls.test.ts`
Expected: FAIL. Component not found.

- [ ] **Step 3: Implement the component as described**

- [ ] **Step 4: Run to verify pass**

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/components/dashboard-page/conversations/ChatFilterControls.vue src/components/dashboard-page/conversations/__tests__/ChatFilterControls.test.ts
git commit -m "feat(workspace): add the chat view switch with a teal action"
```

### Task 3: Sidebar header, swipe, and view-aware lists

**Files:**
- Modify: `openmeet-client/src/components/dashboard-page/conversations/ConversationsSidebar.vue:163-193` (header). Also the empty text at line 278 and the request and invitation sections.
- Test: `openmeet-client/src/components/dashboard-page/conversations/__tests__/ConversationsSidebar.test.ts`

**Interfaces:**
- Consumes: Task 1 (`CHAT_FILTER_VIEWS`, `nextChatFilter`, `previousChatFilter`), Task 2 (`ChatFilterControls`), media viewer plan Task 2 (`useHorizontalSwipe(target, { onSwipe, disabled?, threshold? })`).
- Produces: new model `filter` (`defineModel<ChatFilter>('filter', { required: true })`) and new event `'add-friend'`. The `'start-meeting'` and `'create-group'` events stay. The `PaneHeader` `title` becomes `CHAT_FILTER_VIEWS[filter].title`, and the title text changes with the same 200 ms slide. The `#trailing` slot holds `ChatFilterControls`, and its `@action` emits the matching event. `SearchPill` `label` becomes `searchLabel`. `useHorizontalSwipe` is attached to the header's title row: a `ref` on a wrapper around `PaneHeader`, with `next` → `nextChatFilter` and `previous` → `previousChatFilter`.

- [ ] **Step 1: Write the failing tests** (extend the existing mount helper with `filter: 'all'`)

```ts
it('shows the view title, search label and controls', ...)            // filter 'groups' → h1 'Group chats', search aria-label 'Search group chats'
it('switches views from the switch button', ...)                      // click 'Show group chats' → emitted update:filter ['groups']
it('switches views with a header swipe', ...)                         // pointerdown x=300, pointerup x=150 on header → update:filter ['groups']
it('does not switch views from a drag in the search field', ...)      // same drag starting on the <input> → no update:filter
it('keeps the query when switching views', ...)                       // query 'al', switch → no update:query emitted
it("shows the view's empty text", ...)                                // filter 'groups', conversations [] , query 'x' → 'No group chats match your search.'
it('emits add-friend from the teal action in friends chats', ...)
```

- [ ] **Step 2: Run to verify failure**

Run: `pnpm test:unit --run src/components/dashboard-page/conversations/__tests__/ConversationsSidebar.test.ts`
Expected: the new tests FAIL. The existing tests fail only on the missing `filter` prop, so add it to the mount helper.

- [ ] **Step 3: Implement the header and list changes described above**

Remove the old `DropdownMenu` with the "Start a meeting or create a group" items. Show direct requests when `filter !== 'groups'` and group invitations when `filter !== 'direct'`.

- [ ] **Step 4: Run to verify pass**

Expected: PASS (old and new tests).

- [ ] **Step 5: Commit**

```bash
git add src/components/dashboard-page/conversations/ConversationsSidebar.vue src/components/dashboard-page/conversations/__tests__/ConversationsSidebar.test.ts
git commit -m "feat(workspace): switch chat views from the header and by swiping"
```

### Task 4: Dashboard wiring

**Files:**
- Modify: `openmeet-client/src/pages/DashboardPage.vue`: `filteredConversations` at line 396, the `ConversationsSidebar` usage near line 2430-2454, `setPeopleSearchOpen` at line 1903.
- Test: no new unit test. Filtering is covered by Task 1 and the sidebar behavior by Task 3. The two Review Focus checks for this task are run in the app (Step 3).

**Interfaces:**
- Consumes: Task 1 `filterConversations`, `ChatFilter`. Task 3 `v-model:filter`, `@add-friend`.
- Produces: `const chatFilter = ref<ChatFilter>('all')`. `filteredConversations` becomes `filterConversations(conversations.value, chatFilter.value, searchQuery.value, conversationName)`. `@add-friend="setPeopleSearchOpen(true)"`.

- [ ] **Step 1: Implement the wiring above**

- [ ] **Step 2: Run the client gates**

Run: `pnpm type-check && pnpm lint && pnpm test:unit --run && pnpm build`
Expected: all pass.

- [ ] **Step 3: Verify in the running app** (desktop `http://localhost:5174` and the iOS simulator)

Check `add-friend opens the people search`: in Friends chats, tap Add friend. The Friends panel shows with its search field focused, on desktop and on a phone-width layout.

Check `keeps the selected conversation open`: open a direct chat, switch to Group chats. The chat stays open and its row is hidden.

Also check: icons and title animate on each switch; a swipe on the header cycles views; the badge count does not change between views.

- [ ] **Step 4: Commit**

```bash
git add src/pages/DashboardPage.vue
git commit -m "feat(workspace): filter the chats list by the selected view"
```
