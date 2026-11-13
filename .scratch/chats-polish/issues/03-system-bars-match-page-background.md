# 03: System bars match the page background

**What to build:** The areas outside the web content (the status bar area at the top, the home indicator / navigation bar area at the bottom, and any other safe-area or overscroll edge) always show the same colour as the page behind them. On every page, in light and dark themes. When a page changes its background (for example the black full-screen call stage), the bars follow it; when it leaves, they return to the page colour. Status bar icons stay readable (dark icons on light, light icons on dark).

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] iOS native app: status bar and home indicator areas match the page colour on every page, including the black call stage.
- [ ] Android native app: status bar and navigation bar match the page colour, with readable icons.
- [ ] Mobile browsers: `theme-color` and the safe-area edges follow the page colour.
- [ ] One mechanism drives it from the current page background; pages do not set colours by hand.
- [ ] Unit or component test for the colour-follows-page rule.
- [ ] Checked by hand in the iOS simulator on the workspace, a chat, and a full-screen call.
