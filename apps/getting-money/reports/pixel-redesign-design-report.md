# Pixel Redesign Design Report

## Status

DESIGN COMPLETE - awaiting Yassine approval before implementation.

## What Was Produced

- Complete five-tab pixel redesign board:
  - `design/pixel-redesign/pixel-redesign-board.html`
  - `design/pixel-redesign/pixel-redesign-board.png`
- Ready-to-implement design plan and style guide:
  - `design/pixel-redesign/pixel-redesign-plan.md`
- Generated pixel asset kit reference via built-in `image_gen`:
  - `design/pixel-redesign/generated-pixel-asset-kit.png`
- Prompt record:
  - `design/pixel-redesign/imagegen-prompts.md`

## Design Direction

The redesign turns every tab into part of one professional pixel-art game world:

- Dashboard: arena / tap-to-rep HUD.
- Log: parchment session ledger.
- Rounds: mission board.
- Debt: debt office with banker NPC and repayment contract.
- Settings: training HQ.

The native app tab bar remains the only global navigation. The exercise selector on Dashboard is not app navigation.

## Accessibility Notes

- High-contrast lime, ink, gold, and coral roles are defined in the style guide.
- All interactive controls should remain at least 44 x 44 pt.
- State never relies on color alone; labels such as `ACTIVE DEBT`, `DONE`, and `OWED` stay visible.
- Decorative pixel art should be hidden from VoiceOver.
- Reduce Motion should replace sprite animation with a block flash or static pose.

## Open Placeholders

- Final production slicing/redraw is still needed for pixel icons and NPC art.
- Until then, implementation should use pixel-style placeholders, not SF Symbols.
- The generated asset kit is an art-direction reference, not a direct production sprite atlas.

## Gate

Do not implement until Yassine explicitly approves the board or requests changes.

