# Packet 21 Report — Main Menu Fix, Alive Animations, Splash, Reset

Branch `packet-21-menu-polish` (off `packet-20-training-bank-redesign`). UI packet.
Approved mockups: `design/packet-21-{dashboard,splash,reset}.png`.

## What shipped

1. **Dashboard upper-half glitch FIXED.** Root cause: the pinned wallet-card
   header's backdrop gradient overhung 60pt above the card and painted over the
   greeting row at rest (ghosted "Your Bank" behind the status bar). The greeting
   now lives outside the ScrollView (can never be overpainted) and the backdrop's
   opacity follows the collapse progress — invisible at rest, masking content
   only while the card is actually pinned-collapsed.
2. **Wallet card is genuinely alive.** The sheen sweep and the coin "breathing"
   are driven by wall-clock `TimelineView`s instead of `onAppear` +
   `repeatForever` — the old version snapped back at loop end and died on any
   scroll re-render. Balance changes count up via `numericText`.
3. **Staggered entrance** for status pill → goals header → cards → CTA
   (fade + 10pt rise, spring, per-appearance). CTA renamed "Start a session →".
4. **Tab cross-fade** — all tab switches route through one animated setter
   (0.22s ease-out fade + 8pt offset).
5. **Splash** (`Views/Splash/SplashView.swift`): coin drops with a spring, lime
   rings pulse once, wordmark fades up, ~1.4s, then cross-fades into the app.
   `SplashPolicy` (pure) skips it for `-GMSkipSplash` / `-GMInitialScreen`
   automated launches.
6. **Reset all reps restored** (Packet 20 gate item #2): Danger Zone on Targets →
   destructive confirmation sheet ("Yes, wipe it all" / "Keep my money") →
   existing `SettingsViewModel.resetAllData()` → reload all VMs + republish
   widget + success toast. Failure path surfaces an alert and never claims
   success (code-review blocker, fixed).
7. Every new animation is gated by `accessibilityReduceMotion`.

## Verification

- **Tests:** 114 total; the only failures are the 2 pre-existing
  `ReconciliationTests` (proven on baseline c75ce27, parked for a dedicated
  packet). 4 new tests: reset wiring (store wipe + dashboard zeroing) and
  splash gating (parameterized).
- **Visual (Simulator, iPhone 17 Pro):** dashboard at rest matches the approved
  mockup with zero ghosting; Targets danger zone + reset sheet match; splash
  captured mid-animation; live-motion proven by frame-diffing the card region
  across a screenshot burst (515–1545 px changing per 0.45s interval).
- **Code review:** FAIL → 2 blockers fixed (silent reset failure; ungated
  balance animation) → re-review **PASS**, zero blockers.

## Deferred (recorded, non-blocking)

- Wallet tilt-on-press (scope line, not an acceptance criterion).
- Entrance stagger plays under the splash on cold launch (visible on tab
  returns; intended per-appearance behavior).
- Sheen TimelineView runs 60fps incl. rest phase (battery, dashboard-only).
- Reset sheet fixed 330pt detent vs large Dynamic Type; hex literals in sheet;
  40pt Reset button (matches app convention + approved mockup).
- Scroll-collapse smoothness needs a hands-on device check (no touch injection
  available in this environment; collapse math unchanged from Packet 20).

## Next

Packet 22 — Dynamic rounds + guided exercise sessions (designs already approved:
`design/packet-22-session-{setup,active,done}.png`).
