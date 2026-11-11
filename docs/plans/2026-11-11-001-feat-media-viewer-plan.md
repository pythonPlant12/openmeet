# Full-Screen Media Viewer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the boxed chat media preview with a full-screen viewer: media on a blurred backdrop with no card, swipe left/right between items, pinch or wheel to zoom, and the file name with a download button on top.

**Architecture:** Pure zoom math lives in `lib/zoom.ts` and is unit-tested. A `usePinchZoom` composable turns pointer and wheel events into a transform. A `useHorizontalSwipe` composable detects page swipes, and the chats header plan (`2026-11-11-002`) reuses it. `FilePreview.vue` keeps its props and events, so `ChatThread.vue` and `SharedMediaPanel.vue` do not change. Only its template and gestures change.

**Tech Stack:** Vue 3 `<script setup>`, TypeScript, motion-v (`AnimatePresence`, `motion`), reka-ui Dialog through `HarborDialogContent`, Tailwind with Harbor tokens, Vitest + @vue/test-utils (jsdom).

**Spec:** the Requirements section below, taken from the request on 2026-11-11.

## Requirements

From the user:

1. Opened media fills the screen. No white padding, borders, or card.
2. Pinch out/in zooms on touch. The mouse wheel zooms on desktop.
3. No dialog window. The media itself pops up over a blurred backdrop, with the same effect as opening a profile or group picture (`AccountPage.vue:454-466`: `overlay-class="bg-harbor-ink/50 backdrop-blur-lg"`, transparent content, `hide-close`).
4. Swipe left/right moves between items.
5. The file name sits on top, over the blur. A download icon sits to the right of the name.

Calls made in this plan (the user can override them):

- A close (X) button sits at the top right. Escape and a tap on the empty backdrop also close.
- Zoom range is 1x to 4x. Double-tap or double-click toggles between 1x and 2.5x at the tapped point.
- While zoomed, a drag pans the image and does not change items. Changing items resets the zoom.
- Only images zoom. Videos keep their native controls and PDFs keep their scrollable frame. Both are shown full screen without zoom.
- Remove the footer thumbnail strip. The header shows "2 of 7" under the name when there are several items.
- Desktop keeps the previous and next arrow buttons and adds ArrowLeft/ArrowRight keys.

## Global Constraints

- Colors come only from Harbor tokens (`harbor-*` classes). No raw hex utility classes (AGENTS.md Styling Guide).
- Hover styles are pointer-only. Touch gets no tap highlight.
- The `FilePreview.vue` public API stays the same: props `attachments`, `activeIndex`, `attachmentUrls`, `elevated?`; events `close`, `update:activeIndex`.
- Respect `prefers-reduced-motion`: no slide or scale animations, instant changes.
- Client gates: `pnpm type-check`, `pnpm lint`, `pnpm test:unit --run`, `pnpm build` pass.
- Commits are Conventional Commits with a scope, inside `openmeet-client/`, with no AI attribution lines.

## Review Focus

1. Swiping while zoomed in must pan and not change items. Test in Task 2 (`does not report a swipe while zoomed`).
2. Video controls (scrubbing, play) must keep working. Drags that start on a `<video>` are not swipes. Test in Task 2 (`ignores pointers that start on interactive media`).
3. A single item has no arrows and swiping does nothing. Index 0 does not wrap to the end. Test in Task 3 (`does not move past the first or last item`).
4. When the URL is not loaded yet (`attachmentUrls[url]` missing), show a loader and not a broken image. Test in Task 3 (`shows a loader until the url is available`).
5. Moving to another item resets the zoom to 1x. Test in Task 3 (`resets zoom when the item changes`).

---

## File Structure

- Create `openmeet-client/src/lib/zoom.ts`: pure zoom and pan math.
- Create `openmeet-client/src/lib/__tests__/zoom.test.ts`
- Create `openmeet-client/src/composables/useHorizontalSwipe.ts`: pointer swipe detection with a `disabled` getter.
- Create `openmeet-client/src/composables/usePinchZoom.ts`: pointer, pinch, wheel and double-tap handling around `lib/zoom.ts`.
- Create `openmeet-client/src/composables/__tests__/useHorizontalSwipe.test.ts`
- Create `openmeet-client/src/composables/__tests__/usePinchZoom.test.ts`
- Modify `openmeet-client/src/components/dashboard-page/chat/FilePreview.vue`: new full-screen template that uses both composables.
- Create `openmeet-client/src/components/dashboard-page/chat/__tests__/FilePreview.test.ts`

### Task 1: Zoom math

**Files:**
- Create: `openmeet-client/src/lib/zoom.ts`
- Test: `openmeet-client/src/lib/__tests__/zoom.test.ts`

**Interfaces:**
- Produces:
  - `export interface ZoomState { scale: number; x: number; y: number }`: the translate is in CSS px, applied as `translate(x, y) scale(scale)` with `transform-origin: center`.
  - `export const MIN_ZOOM = 1; export const MAX_ZOOM = 4; export const DOUBLE_TAP_ZOOM = 2.5;`
  - `export const IDENTITY_ZOOM: ZoomState`: `{ scale: 1, x: 0, y: 0 }`
  - `export function zoomAt(state: ZoomState, nextScale: number, point: { x: number; y: number }, size: { width: number; height: number }): ZoomState`: zooms so that `point` (relative to the element center) stays under the finger or cursor. It clamps the scale to `[MIN_ZOOM, MAX_ZOOM]`, then clamps the pan.
  - `export function clampPan(state: ZoomState, size: { width: number; height: number }): ZoomState`: limits `|x| <= width*(scale-1)/2` and `|y| <= height*(scale-1)/2`. At scale 1 the result is `IDENTITY_ZOOM`.

- [ ] **Step 1: Write the failing tests**

```ts
import { describe, expect, it } from 'vitest';
import { IDENTITY_ZOOM, MAX_ZOOM, clampPan, zoomAt } from '@/lib/zoom';

const size = { width: 400, height: 300 };

describe('zoom', () => {
  it('keeps the point under the cursor in place', () => {
    const next = zoomAt(IDENTITY_ZOOM, 2, { x: 100, y: 50 }, size);
    expect(next).toEqual({ scale: 2, x: -100, y: -50 });
  });
  it('clamps the scale between 1 and 4', () => {
    expect(zoomAt(IDENTITY_ZOOM, 9, { x: 0, y: 0 }, size).scale).toBe(MAX_ZOOM);
    expect(zoomAt({ scale: 2, x: 40, y: 0 }, 0.2, { x: 0, y: 0 }, size)).toEqual(IDENTITY_ZOOM);
  });
  it('keeps the zoomed image covering its box', () => {
    expect(clampPan({ scale: 2, x: 999, y: -999 }, size)).toEqual({ scale: 2, x: 200, y: -150 });
  });
});
```

- [ ] **Step 2: Run to verify failure**

Run: `cd openmeet-client && pnpm test:unit --run src/lib/__tests__/zoom.test.ts`
Expected: FAIL. Cannot resolve `@/lib/zoom`.

- [ ] **Step 3: Implement `zoomAt` and `clampPan` in `src/lib/zoom.ts`**

Use `x' = point.x - (point.x - x) * (next / scale)` (and the same for `y`), then `clampPan`.

- [ ] **Step 4: Run to verify pass**

Run: `pnpm test:unit --run src/lib/__tests__/zoom.test.ts`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add src/lib/zoom.ts src/lib/__tests__/zoom.test.ts
git commit -m "feat(chat): add zoom and pan math for the media viewer"
```

### Task 2: Swipe and pinch-zoom composables

**Files:**
- Create: `openmeet-client/src/composables/useHorizontalSwipe.ts`
- Create: `openmeet-client/src/composables/usePinchZoom.ts`
- Test: `openmeet-client/src/composables/__tests__/useHorizontalSwipe.test.ts`, `openmeet-client/src/composables/__tests__/usePinchZoom.test.ts`

**Interfaces:**
- Consumes: Task 1 `ZoomState`, `IDENTITY_ZOOM`, `DOUBLE_TAP_ZOOM`, `zoomAt`, `clampPan`.
- Produces:
  - `export function useHorizontalSwipe(target: Ref<HTMLElement | null>, options: { onSwipe: (direction: 'next' | 'previous') => void; disabled?: () => boolean; threshold?: number }): void`. The default threshold is `48` px (the value `FilePreview.vue` uses today). The swipe counts only when `|dx| > threshold` and `|dx| > 1.5 * |dy|`. A leftward drag means `'next'`. Pointers that start inside `input, textarea, video, iframe, [data-no-swipe]` are ignored. Listeners are attached on mount and removed on unmount.
  - `export function usePinchZoom(target: Ref<HTMLElement | null>, options?: { disabled?: () => boolean }): { zoom: Readonly<Ref<ZoomState>>; isZoomed: ComputedRef<boolean>; reset: () => void }`. Two pointers pinch. One pointer pans when `scale > 1`. `wheel` zooms by `Math.exp(-deltaY * 0.002)` around the cursor and calls `preventDefault`. A double tap (two `pointerup` within 300 ms and 24 px) toggles between `IDENTITY_ZOOM` and `DOUBLE_TAP_ZOOM` at the point.

- [ ] **Step 1: Write the failing tests**

`useHorizontalSwipe.test.ts`: mount a tiny component that uses the composable on a div. Dispatch `pointerdown` at x=200 and `pointerup` at x=100 and assert `onSwipe('next')`. Assert that 30 px of movement calls nothing. Assert that `disabled: () => true` calls nothing. Assert that a pointer starting on a child `<video>` calls nothing (`ignores pointers that start on interactive media`).

`usePinchZoom.test.ts`: stub `getBoundingClientRect` to `{ left: 0, top: 0, width: 400, height: 300 }`. Assert that a `wheel` with `deltaY: -500` at the center gives `zoom.scale > 1` and `isZoomed === true`. Assert that two quick taps at the same point toggle to `scale === 2.5` and back to `1`. Assert that `reset()` returns `IDENTITY_ZOOM`. In a combined test, a component using both composables (swipe `disabled: () => isZoomed.value`) gets a wheel zoom and then a 100 px drag, and `onSwipe` is not called (`does not report a swipe while zoomed`).

- [ ] **Step 2: Run to verify failure**

Run: `pnpm test:unit --run src/composables/__tests__/useHorizontalSwipe.test.ts src/composables/__tests__/usePinchZoom.test.ts`
Expected: FAIL. Modules not found.

- [ ] **Step 3: Implement both composables with the signatures above**

Track active pointers in a `Map<number, {x, y}>`. Set `touch-action: none` on the target in `onMounted` so the WKWebView does not scroll or zoom the page. The viewport already sets `user-scalable=no` in `index.html`.

- [ ] **Step 4: Run to verify pass**

Run: same command as Step 2.
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/composables/useHorizontalSwipe.ts src/composables/usePinchZoom.ts src/composables/__tests__
git commit -m "feat(chat): add swipe and pinch-zoom composables"
```

### Task 3: Full-screen `FilePreview.vue`

**Files:**
- Modify: `openmeet-client/src/components/dashboard-page/chat/FilePreview.vue`. The whole template and the gesture code (`handlePointerDown`/`handlePointerUp`) are replaced.
- Test: `openmeet-client/src/components/dashboard-page/chat/__tests__/FilePreview.test.ts`

**Interfaces:**
- Consumes: Task 2 `useHorizontalSwipe`, `usePinchZoom`.
- Produces: no new API. Props and events stay as listed in Global Constraints.

Layout (Harbor tokens only):
- `HarborDialogContent` with `hide-close`, `overlay-class="bg-harbor-ink/70 backdrop-blur-lg"` (plus `!z-[1060]` when `elevated`), and content classes `fixed inset-0 h-[100dvh] w-screen max-w-none translate-x-0 translate-y-0 rounded-none border-0 bg-transparent p-0 shadow-none`.
- Header: absolute at the top, with `pt-[max(0.75rem,env(safe-area-inset-top))]`, white text with a soft text shadow. From left to right: the file name (truncate, `font-semibold`) with "N of M" below it when `attachments.length > 1`, then the download `<a>` with `aria-label="Download attachment"` right after the name, then a spacer, then the close button with `aria-label="Close preview"`.
- Stage: fills the screen. Clicking the stage itself (not the media) emits `close`. The image uses `max-h-full max-w-full object-contain` with `:style="{ transform: \`translate(${x}px, ${y}px) scale(${scale})\` }"`.
- Items change inside `AnimatePresence` with a horizontal slide: `x: ±24%`, opacity, 240 ms, or none when motion is reduced. Opening scales from 0.96 with opacity, the same pop as the avatar preview.
- Previous/next arrow buttons: shown only on `(hover: hover) and (pointer: fine)`, only when there is a previous/next item. Use `RoundButton tone="soft"` from `@/components/ui/round-button`.
- When `activeUrl` is missing: show `LoadingRipple` from `@/components/ui/loading` centered.

- [ ] **Step 1: Write the failing tests** (`FilePreview.test.ts`, mounted with `attachTo: document.body`, since the dialog teleports)

```ts
it('shows the file name with the download link beside it', ...)          // header text 'photo.jpg', link download='photo.jpg'
it('shows a loader until the url is available', ...)                       // no <img>, loader present; after setProps url → <img>
it('emits the next index on a left swipe and none past the end', ...)     // index 0 of 2 → 1; at index 1 a left swipe emits nothing
it('does not move past the first or last item', ...)                      // single item: no arrow buttons, swipes emit nothing
it('resets zoom when the item changes', ...)                              // wheel zoom, setProps activeIndex 1 → img transform contains 'scale(1)'
it('closes on Escape and on a backdrop click', ...)                       // emits 'close'
it('moves with the arrow keys', ...)                                      // ArrowRight → update:activeIndex 1
```

- [ ] **Step 2: Run to verify failure**

Run: `pnpm test:unit --run src/components/dashboard-page/chat/__tests__/FilePreview.test.ts`
Expected: FAIL (old template: no loader, header layout differs, no key handling).

- [ ] **Step 3: Implement the template and wiring described above**

Call `reset()` in a `watch(() => props.activeIndex, ...)`. Pass `disabled: () => isZoomed.value || props.attachments.length < 2` to `useHorizontalSwipe`. Pass `disabled: () => !isImage.value` to `usePinchZoom`.

- [ ] **Step 4: Run to verify pass, then the full suite**

Run: `pnpm test:unit --run && pnpm type-check && pnpm lint`
Expected: all pass, including the existing `SharedMediaPanel.test.ts` and `ChatPane.test.ts`.

- [ ] **Step 5: Verify in the running app**

With `make dev` running, open a chat with two or more images on desktop (`http://localhost:5174`) and in the iOS simulator (`pnpm dev:ios-simulator` in `openmeet-native`). Check: no card or padding; blur behind; name and download icon on top; swipe or arrows move between items; pinch, wheel and double-tap zoom; drag pans while zoomed; video plays with controls.

- [ ] **Step 6: Commit**

```bash
git add src/components/dashboard-page/chat/FilePreview.vue src/components/dashboard-page/chat/__tests__/FilePreview.test.ts
git commit -m "feat(chat): open media full screen with swipe and zoom"
```
