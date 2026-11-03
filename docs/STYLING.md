# OpenMeet Styling Guide

## Harbor Actions

- All colors come from the Harbor palette tokens (`--harbor-*` in `src/assets/index.css`, Tailwind `harbor-*` colors and `shadow-harbor-*` shadows). The palette is neutral slate and white; `harbor-accent` (teal) is the only accent. Do not add raw hex classes for palette colors; dark scopes redefine the tokens.
- Gray hover surfaces (`#F0F2F5`, `#E9EDEF`) require dark text and icons (`#111B21` or `#3B4A54`). Never use white foreground on these surfaces.
- Primary teal actions use `#0B7A75` with white foreground and hover to `#08635F`.
- Apply `harbor-ghost-action` to ghost controls using gray hover states. It enforces dark foreground.
- Shared components: `RoundButton` / `RoundButtonGroup` (white disc with soft shadow; tones `accent`, `soft`, `plain`, `danger`), `Avatar`, `ListRow` / `ListHeading` (avatar, title, time on the right, gray second line, separator after the avatar, hover actions on pointer devices), `SearchPill`, and `PaneHeader`. Menus get their style from the `ui/` dropdown and context menu primitives; use `variant="danger"` for destructive items. Notifications (toasts, the incoming call bar) are white cards with `shadow-harbor-float`.
- Apply `harbor-primary-action` to teal primary actions. It enforces white foreground and dark-teal hover.
- Do not introduce amber, brown, or orange interactive states. Destructive/error states may use existing coral tokens only where meaning requires them.

## Touch and Focus

- Hover behavior applies only to fine-pointer hover devices. Do not rely on `:hover` for touch feedback.
- Disable browser tap highlight globally. A touched icon changes appearance only when it has explicit selected or active state.
- Active icon controls use `#F0F2F5` with `#111B21` foreground; each control owns its own state.
- Inputs retain `#D8E7E3` borders on focus. Do not add dark-green border corners, focus rings, or offsets to text inputs.

## Motion and Layers

- Use `motion-v` for new surfaced UI. Entry/exit motion should be short, purposeful, and respect reduced-motion settings.
- Toasts enter from a small downward offset with opacity/scale, exit the same way, and auto-dismiss after three seconds unless the user needs persistent recovery action.
- Dialogs use rounded Harbor surfaces (`1.75rem` radius), soft teal shadows, and a `#102F35` translucent blurred backdrop. Mobile dialogs keep `1rem` side margin when viewport permits.
- Avoid decoration-only motion. Animate opening/closing surfaces, selection changes, and layout expansion only.

## Workspace Layout

- App workspaces use `100dvh` and `overflow-hidden` at page level. Scroll only inside content panes.
- A pane with long content keeps its section title and controls outside its scrolling child. Headers for Friends, Messages, and similar sections must remain visible.
- Section titles at the same hierarchy use identical typography, casing, color, and spacing.

## Interaction

- When controls reveal competing inputs in one region, opening one closes the other.
- Fixed-height workspaces must scroll within panes, never grow beyond viewport height.
