# Getting Money - Professional Pixel Redesign Plan

## Goal

Unify the full app around a professional pixel-art gamified system: the Dashboard becomes the playable arena, Log becomes the session ledger, Rounds becomes the mission planner, Debt becomes the debt office, and Settings becomes the training HQ. The product remains practical and fast; the pixel layer gives it identity, feedback, and motivation.

## Deliverables

- All-tab mockup board: `pixel-redesign-board.html`
- Rendered PNG mockup board: `pixel-redesign-board.png`
- Generated asset kit reference: `generated-pixel-asset-kit.png`
- Image generation prompt record: `imagegen-prompts.md`

## Core Design Direction

The current app has pixel elements, but the reference points to a fuller world: RPG HUD, mission cards, parchment log surfaces, debt office NPC, and training HQ panels. The redesign should replace the remaining bank-card language with game-native surfaces while preserving all existing functions.

The app-level tab bar remains the only global navigation. Each tab gets its own diegetic title and icon:

- Dashboard: Arena
- Log: Session Log
- Rounds: Mission Board
- Debt: Debt Office
- Settings: Training HQ

## Screen Plans

### 1. Dashboard / Arena

Purpose: immediate tap-to-rep loop.

Key UI:

- Top HUD: streak flame, level/shield, coins, active debt chip.
- Exercise selector: push-ups, pull-ups, squats, dips as pixel segmented controls.
- Arena background: dark training room with pixel props. If final art is missing, use a low-contrast pixel-placeholder arena layer.
- Hero sprite centered, large, crisp, tappable.
- Primary action panel: `TAP TO REP`; session reward line below.
- Daily progress console: progress blocks, streak, level, XP.

Interaction:

- Tapping sprite logs reps for selected exercise.
- Exercise switch flushes pending reps.
- Reduce Motion keeps sprite static and uses block flash instead of bounce.

### 2. Log / Session Log

Purpose: precise manual entry and corrections.

Key UI:

- Clipboard/parchment surface for each exercise.
- Header shows `SESSION LOG`, date, and total `logged / target`.
- Exercise cards use a parchment paper body with metal clip accents.
- Each exercise card has icon, today progress, checkbox/state badge, minus/plus steppers, quick-add buttons.
- Footer helper NPC strip: short coaching line, still practical.
- Sticky CTA: `SAVE REPS`.

Interaction:

- Stepper controls are minimum 44 pt.
- Quick-add buttons use lime-filled pixel rectangles.
- Pending changes highlight the affected card border.

### 3. Rounds / Mission Board

Purpose: plan and execute rounds.

Key UI:

- Header: crossed-swords mission icon, `3 ROUNDS TO HIT ZERO`, done count.
- Total target panel with lime number and short explanatory copy.
- Payoff selector appears as mission modifier: None, Small, Half, Full.
- Round cards show round number, per-exercise reps, block progress, done count.
- Sticky CTA: `START ROUND 1` or `COMPLETE ROUND N`.

Interaction:

- Completing a round turns the card into a locked "done" state with an edit affordance.
- Changing round count uses square minus/plus steppers.

### 4. Debt / Debt Office

Purpose: make debt serious, legible, and repayable only by reps.

Key UI:

- Header: coin/debt seal, `DEBT OFFICE`, `Rep now, repay later`.
- Merchant/banker NPC panel explains the current payoff plan.
- Hero debt panel: gold coin icon + coral debt number.
- Plan selector: One Time, Balanced, Extended.
- Repayment contract parchment: human-readable promise, no money-to-debt affordance.
- Sticky destructive-styled action: `SIGN & CONFIRM PLAN` or existing `ADD PAYOFF TO TODAY'S ROUNDS`, depending implementation scope.

Interaction:

- Finance plan rows are selectable cards.
- Coral is reserved for owed debt and confirmation tension.
- Copy must always say debt is repaid in reps, not money.

### 5. Settings / Training HQ

Purpose: configure targets and feedback without breaking the game feel.

Key UI:

- Header: shield icon, `TRAINING HQ`.
- Daily targets list with small exercise pixel icons, minus/plus steppers, dips toggle.
- Progression section: auto-increase toggle, amount, frequency.
- Preferences: sound effects, haptic feedback toggles.
- Next auto-increase console.
- Data controls stay lower in the scroll view, styled as utility panels.

Interaction:

- Toggles use square track proportions with a lime active fill.
- Optional exercise row stays visible whether enabled or disabled.

## Component System

### Pixel Card

- Background: `#10140F`
- Border: 1 pt `#343829`, with brighter top/left and darker bottom/right to create pixel bevel.
- Corner radius: 2 to 4 pt only.
- Optional inner tile grid at 4 pt increments.

### Parchment Card

- Background: `#E8D8B8`
- Ink: `#1A1610`
- Border: `#B08A54`
- Used only in Log and signed Debt contract moments.

### Buttons

- Primary CTA: lime `#AEE63D`, black ink, 2 pt dark border, square corners.
- Secondary CTA: dark fill, hairline border, lime label.
- Destructive/commit: coral `#E85D4F`, black or off-white ink depending contrast.
- Disabled: dark fill, muted label, no glow.

### Progress Blocks

- 20 block default for compact progress.
- Filled: lime.
- Empty: dark stone with hairline.
- Debt/owed overlay: coral mini tag, never color alone.

### Pixel Icons

Grid:

- Small: 16 x 16 px source, rendered at 16 to 24 pt.
- Medium: 24 x 24 px source, rendered at 28 to 40 pt.
- Stroke: no antialiasing, one-pixel dark outline.
- Snap to integer coordinates.

Icon set:

- Dashboard: gamepad or arena sprite
- Log: clipboard
- Rounds: dotted ring or crossed swords
- Debt: coin loop or debt seal
- Settings: gear/shield
- Exercises: push-up body, pull-up bar, squat figure, dip bars
- Economy: coin, flame, shield, XP crown
- Controls: plus, minus, check, toggle, calendar

## Color Guide

| Role | Hex | Use |
|---|---|---|
| Black Canvas | `#050806` | full app background |
| Stage Black | `#0A0D0B` | arena / deep panels |
| Panel | `#10140F` | primary pixel cards |
| Raised Panel | `#171D13` | active controls |
| Hairline | `#343829` | borders and dividers |
| Ink | `#F3F7F1` | primary text |
| Muted Ink | `#9A9485` | metadata |
| Lime | `#AEE63D` | primary action/progress |
| Lime Dark | `#556B22` | pressed/secondary fills |
| Gold | `#FFD34D` | coins/level |
| Coral | `#E85D4F` | debt/loss |
| Parchment | `#E8D8B8` | log/contract cards |
| Parchment Edge | `#B08A54` | paper borders |

## Typography

Implementation should use system monospaced fonts unless a licensed pixel font is added.

- Hero title: monospaced heavy, 28 to 34 pt.
- Section title: monospaced bold, 12 to 14 pt, uppercase.
- Body: monospaced or system text 12 to 15 pt.
- Numbers: monospaced heavy, tabular figures.
- Tracking: use carefully, 0.8 to 1.5 only for section labels.

## Spacing

- Screen padding: 18 to 20 pt.
- Card padding: 14 to 16 pt.
- Dense row vertical padding: 10 to 12 pt.
- Component gap: 8 pt.
- Section gap: 16 to 20 pt.
- Bottom safe area: keep sticky CTA above tab bar, never under it.

## Accessibility

- Contrast: lime on black and ink on panel pass comfortably; muted text should stay above `#9A9485` on `#10140F`.
- Dynamic Type: titles may wrap to two lines; card rows must not clip. Prefer vertical expansion over shrinking below 11 pt.
- Touch targets: all plus/minus, tab, quick-add, and toggles stay at least 44 x 44 pt.
- Color independence: every state uses text or icon plus color, e.g. `ACTIVE DEBT`, `DONE`, `OWED`.
- Reduce Motion: sprite animation becomes a 1-frame pose change and block flash.
- VoiceOver: read decorative pixel art as hidden; expose meaningful controls and totals.

## Placeholder Resolution

The provided reference and generated asset kit define direction, but final production assets should be sliced or redrawn cleanly before shipping. Until then:

- Use CSS/SVG pixel placeholders for tab and exercise icons.
- Use the current hero sprite for Dashboard.
- Use a dark pixel placeholder for the Debt Office NPC if the banker sprite is not final.
- Do not use smooth SF Symbols in final pixel screens unless wrapped/redrawn into pixel style.

## Implementation Order

1. Update design system tokens: colors, pixel card, parchment card, pixel buttons, icon shell, block progress.
2. Replace SF Symbol usage in tab and exercise rows with pixel icon components/placeholders.
3. Implement Dashboard arena state using existing `GameDashboardView`.
4. Convert Log cards to parchment ledger components.
5. Convert Rounds to mission board components.
6. Convert Debt to debt office layout with NPC art placeholder and contract panel.
7. Convert Settings to Training HQ panels.
8. Screenshot all tabs on compact and Pro devices.
9. Fix text wrapping and safe-area/sticky CTA overlaps.

