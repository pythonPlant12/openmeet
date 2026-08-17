# OpenMeet Styling Guide

## Harbor Actions

- Light green hover surfaces (`#E6F4F1`, `#D8E7E3`, `#EDF8F5`) require dark teal text and icons (`#102F35` or `#27595D`). Never use white foreground on these surfaces.
- Primary teal actions use `#0B7A75` with white foreground and hover to `#08635F`.
- Apply `harbor-ghost-action` to ghost controls using light-green hover states. It enforces dark foreground.
- Apply `harbor-primary-action` to teal primary actions. It enforces white foreground and dark-teal hover.
- Do not introduce amber, brown, or orange interactive states. Destructive/error states may use existing coral tokens only where meaning requires them.

## Touch and Focus

- Hover behavior applies only to fine-pointer hover devices. Do not rely on `:hover` for touch feedback.
- Disable browser tap highlight globally. A touched icon changes appearance only when it has explicit selected or active state.
- Active icon controls use `#E6F4F1` with `#102F35` foreground; each control owns its own state.
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
