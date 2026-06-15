---
name: render-mockups
description: Render a Designer-built HTML/CSS screen mockup to a PNG at iPhone size using headless Chromium, so it can be shown inline and approved at the Design Gate. Use whenever a packet produces apps/<name>/design/packet-NN-<screen>.html and needs a packet-NN.png.
---

# Render Mockups — HTML screen spec to PNG

This skill is the rendering step of the **DESIGNER** phase. The Designer builds each
screen as a self-contained HTML file with embedded CSS (`apps/<name>/design/packet-NN-<screen>.html`).
This skill turns that file into a PNG at real iPhone size so it can be shown inline and
approved at the Design Gate — never ask Yassine to open an HTML file.

## Render command

Use headless Chromium/Chrome/Brave/Edge at @2x, sized to an iPhone viewport:

```
"<chromium>" --headless=new --hide-scrollbars --force-device-scale-factor=2 \
  --window-size=393,852 \
  --screenshot="apps/<name>/design/packet-NN.png" \
  "file://$PWD/apps/<name>/design/packet-NN-<screen>.html"
```

- `<chromium>` = the path to Chrome, Chromium, Brave, or Edge on this machine — locate it
  once with `mdfind` / `which` / checking `/Applications/` and reuse the path.
- 393x852 is the iPhone 15/16 logical viewport; `--force-device-scale-factor=2` gives a
  crisp @2x render matching the Simulator.
- One PNG per screen — a flow of N screens produces N separate `packet-NN-<screen>.png`
  files (or `packet-NN.png` if there's only one screen for the packet).

## Fallbacks

If no Chromium-family browser is available:
- `wkhtmltoimage --width 393 --height 852 packet-NN-<screen>.html packet-NN.png`
- Playwright (`npx playwright screenshot --viewport-size=393,852 ...`)

## After rendering

- Show the PNG inline (Read the image file so it renders in the conversation).
- Confirm it looks like the real product at iPhone size — not a desktop layout
  squeezed down (`reviews/design.md` § Layout: "don't just shrink a desktop/web layout").
- Hand back to the Designer's Design Gate checkpoint: "Design ready — review
  apps/<name>/design/packet-NN.png. Reply 'approved' before any UI code is written."

## Native-app reminder

This PNG is a **visual spec**, not the shippable artifact. The Implementer writes SwiftUI
to match it; the UI-Reviewer later compares a real Simulator screenshot against this same
PNG (`reviews/design.md` § Native-app rule).
