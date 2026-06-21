# UI System — Getting Money

> The working UI contract for Designer, Implementer, Tester, UI-Reviewer. Grounded in `knowledge/ios-design.md` and the user's `design/reference-mockup.png`. The approved `design/packet-NN.png` is the source of truth for each packet's layout; native SwiftUI must match it.

## Design read
A premium native-iOS calisthenics **personal bank** for a discipline-driven solo user — **dark-first private-banking** language: graphite-black canvas, ONE lime-green earnings/progress accent, coral-red debt/loss, big tabular numbers, soft glass cards, short state-driven motion. Serious and calm, never a childish game.

## The concept
A personal **bodyweight bank** where reps are money and missed reps are debt repaid only in reps. The visual system makes "what did I earn / what do I owe / what do I do now" readable in under 5 seconds.

## Color — dark first (primary), light mirror provided
Dark mode is the default and the design target. Semantic roles (use these names in SwiftUI). Never pure #000/#fff. Debt/success/warning always carry an icon or label, never color alone.

### Dark (primary)
| Role | Hex | Use |
|---|---|---|
| Background | `#0A0D0B` | app canvas (near-black graphite-green) |
| Surface | `#131714` | glass cards / grouped panels |
| Elevated | `#1B201C` | high-priority module |
| Hairline | `#2A302C` | borders / separators |
| Ink (text primary) | `#F3F7F1` | numbers, primary text |
| Muted (text secondary) | `#8A938C` | labels, metadata |
| **Accent / Earnings (the ONE)** | `#AEE63D` | primary actions, earned value, progress fill |
| Accent pressed | `#93C32F` | pressed primary |
| Success (on track / paid) | `#5FD08A` | positive status |
| Warning (behind / due) | `#F2C14E` | caution status |
| **Debt / Loss** | `#FF6A5A` | debt, missed targets, losses (coral-red) |

### Light (mirror — hierarchy preserved)
| Role | Hex |
|---|---|
| Background `#F7F8F6` · Surface `#FFFFFF` · Elevated `#FFFFFF` · Hairline `#E4E8E3` · Ink `#14180F` · Muted `#5A625B` · Accent `#5E8C12` (darkened lime for contrast) · Success `#1F9D57` · Warning `#B5860E` · Debt `#D8473A` |

Lime on dark text = near-black ink on the accent fill. On translucent/glass surfaces, keep ink ≥ 4.5:1 against the blurred backdrop (test over the darkest card content).

## Typography
- Native **SF Pro** via SwiftUI system fonts. **Tabular figures** for all money/reps/streak numbers.
- Hero balance: 48–56 pt, bold. Screen title: 28–34 pt, bold. Section title: 17–20 pt, semibold. Body: 15–17 pt. Metadata: 12–13 pt, medium.

## Spacing & radius
- Spacing scale: 4 · 8 · 12 · 16 · 20 · 24 · 32. Screen horizontal padding 20. Dense rows 12 vertical.
- Radius: controls 10 · rows/compact 14 · major modules 20 · full pills for status + segmented controls only.
- **No nested cards.** Group with spacing, hairlines, or one elevated surface.

## Navigation
Tab bar (bottom, thumb-reachable): **Dashboard · Log · Rounds · Debt · Settings**. Dashboard launches first and shows: bank balance, debt balance, streak, today's per-exercise progress, and a clear primary action (Start rounds / Log).

## Component contracts
- `BalanceHeader` — total bank balance, today's earned (+$), status pill.
- `ExerciseProgressRow` — name, completed/target, remaining, lime progress fill, coral debt marker if owed.
- `QuickRepStepper` — fast add with haptic + count-up feedback.
- `RoundCircleCard` — round #, per-exercise reps, editable actuals, total effect.
- `DebtPayoffCard` — total debt (coral), plan mode, next repayment action. No money-to-debt control, ever.
- `StatusPill` — On track / Profit / Behind / Active debt / Paid off (color + label + icon).
- `TrendChart` — compact bank / debt / streak (Swift Charts).

## Motion
- Transitions 150–220 ms. Motion only for state feedback: balance count-up, debt reduction, round-total change, selection. Press feedback + light haptic on log.
- **Reduce Motion:** instant value changes, no count-up, cross-fade instead of spring.

## Anti-slop guardrails (this app)
Lime is the only accent — no second accent. Coral is reserved for debt/loss. No neon glows, no gradient text, no fake-perfect numbers in real UI, no "Elevate/Seamless" copy. Tone: direct, calm, slightly playful, premium (see `docs/spec.md` §30).

## Design gates
Every UI packet renders `design/packet-NN.html` → `design/packet-NN.png`; Yassine approves the PNG before SwiftUI; UI-Reviewer compares a Simulator screenshot to it before pass.

---

## Packet 16 — Pixel Game Dashboard extension

This packet deliberately shifts the Dashboard tab into a **pixel arcade arena** aesthetic. This is not a contradiction of the "serious bank" tone — it is the motivational skin layered on top of it. The banking data model stays; the visual language upgrades to pixel game HUD. All other tabs (Rounds, Debt, Settings, Log) retain the original banking system design.

### Pixel-specific design tokens

**Typography — pixel/game mode**
- All numerics in the HUD and progress areas: `SF Mono` or `Courier New`, heavy weight, uppercase. No dollar signs anywhere.
- Labels: system monospaced or `Courier New`, all-caps, tight letter-spacing (0.08em).
- Character-domain copy ("TAP TO REP", exercise segment labels): monospaced, UPPERCASE.

**Corner radius — pixel mode**
- Maximum 2px radius on all progress bars, segment controls, and HUD chips. Sharp is the intent.
- Character arena container: 0px radius (full bleed stage).

**Progress bar — pixel segmented**
- 20 discrete blocks (not a smooth fill). Each block: 10px wide, 16px tall, 2px gap between.
- Filled blocks: `#AEE63D` (lime accent). Unfilled blocks: `#1B201C` with `#2A302C` border.
- Label to right of blocks: monospaced, muted color, tabular figures.

**Coin icon — PixelCoinView spec**
- Small (~14–16px): SVG circle with `#FFD700` fill, 1–2px `#1A1A1A` dark border, 2×2px white highlight at top-left.
- Used everywhere balance amounts appear. Never use the 🪙 emoji in rendered UI.

**Flame icon — PixelFlameView spec**
- ~14px: SVG flame drawn with stacked rects (no emoji — headless Chromium has no color-emoji font).
- Colors: base orange `#FF6A2F`, mid `#FF8A1F`, tip `#FFD700`.

**Character sprite — PixelCharacter spec**
- 276×276pt container, centered in the arena.
- Drawn as SVG `<rect>` elements with `shape-rendering="crispEdges"`, 6px per art pixel.
- Colors: hair `#1A1A1A`, skin `#C8845A`, tank top `#1A1A1A`, shorts `#1A1A1A`, shoes `#2A2A3A`.
- `image-rendering: pixelated` on the SVG container.

**Arena depth layers**
1. Sky: `#0A0D0B` with subtle pixel dot stars (`#1B201C`).
2. Stage line: 2px `#2A302C` horizontal rule at ~75% from arena top.
3. Ground strip: 8px `#1A2020` immediately below stage line.
4. Floor: `#0D1010` below ground strip.
