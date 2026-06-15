# Design System - Getting Money App

## Product Register

product

## Design Intent

Getting Money App should feel like opening a private finance dashboard for physical discipline. The visual system is restrained, confident, and app-native: strong numeric hierarchy, clean surfaces, precise progress states, and a warm amber brand accent that suggests earned value without becoming gimmicky.

Physical scene: an iPhone on a desk before a short workout, daylight, focused mood, one job to do: clear the balance.

## Color Strategy

Strategy: restrained product UI with one warm primary accent used for action, earned value, and selected state. Debt and risk states use semantic color, not brand color.

Use OKLCH tokens:

```css
--gm-bg: oklch(1.000 0.000 0);
--gm-surface: oklch(0.972 0.004 48);
--gm-surface-elevated: oklch(0.992 0.002 48);
--gm-ink: oklch(0.180 0.012 52);
--gm-muted: oklch(0.455 0.018 52);
--gm-primary: oklch(0.607 0.163 47.7);
--gm-primary-pressed: oklch(0.540 0.150 47.7);
--gm-accent: oklch(0.350 0.095 218);
--gm-success: oklch(0.548 0.132 145);
--gm-warning: oklch(0.680 0.130 78);
--gm-danger: oklch(0.560 0.160 28);
--gm-border: oklch(0.900 0.006 52);
```

Text on saturated fills should be white or near-white. Body text uses `--gm-ink`; secondary text uses `--gm-muted`.

## Typography

- Use the native Apple system font stack, effectively SF Pro.
- Large dashboard values use heavy numeric hierarchy, not decorative display fonts.
- Labels are compact, direct, and sentence case.
- Avoid oversized marketing-style headings inside app surfaces.

Recommended scale:

- Large balance: 44-56 pt, semibold or bold.
- Screen title: 28-34 pt, bold.
- Section title: 17-20 pt, semibold.
- Body: 15-17 pt, regular.
- Metadata: 12-13 pt, medium.

## Navigation

Primary tabs:

- Dashboard
- Log
- Rounds
- Debt
- Settings

The first screen is always Dashboard. On launch, the user should see today's balance, debt, streak, and primary logging action without onboarding friction.

## Core Screens

### Dashboard

Purpose: immediate financial workout status.

Primary hierarchy:

1. Total bank balance.
2. Current debt balance.
3. Today's progress across core exercises.
4. Streak and status.
5. Suggested next action.

UI structure:

- Top status area with total bank balance and today's earned amount.
- Debt module with clear payoff state: zero debt, active debt, or over-target.
- Exercise progress rows for push-ups, pull-ups, squats, and optional dips.
- A compact history chart for bank/debt trend.
- Primary action: Log reps.

### Log Reps

Purpose: log reps in under 10 seconds.

UI structure:

- Exercise selector with native segmented or compact list treatment.
- Stepper and quick-add controls.
- Recent entries.
- Immediate feedback after logging: earned amount, target progress, debt impact if relevant.

### Rounds

Purpose: show today's workout split into circles/rounds.

UI structure:

- Round count control.
- Generated per-round targets for each exercise.
- Editable round rows.
- Difference indicator showing whether edits still cover the target.
- Optional debt allocation overlay.

### Debt

Purpose: make rep debt understandable and payable.

UI structure:

- Total debt balance.
- Per-exercise debt balances.
- Plan selector: pay in one go or finance plan.
- Dynamic payoff schedule based on current debt and rounds.
- Progress toward zero.

### Settings

Purpose: keep core behavior configurable without clutter.

UI structure:

- Exercise enablement.
- Daily targets.
- Two-week progression amount.
- Pull-up cap.
- Money-per-rep display setting.
- Local data reset/export controls for beta testing.

## Components

- `BalanceHeader`: primary bank/debt summary.
- `ExerciseProgressRow`: exercise target, completed reps, remaining reps, debt status.
- `QuickRepStepper`: plus/minus and quick-add action.
- `RoundCircleCard`: per-round target and editable actual reps.
- `DebtPayoffCard`: debt plan status and next action.
- `StatusPill`: on track, over target, debt, paid off.
- `TrendChart`: compact history visualization.

All components need default, pressed, disabled, empty, and error states where applicable.

## Motion

Motion is functional and short:

- 150-220 ms transitions.
- Balance number can count up after logging reps.
- Debt module can subtly compress/update when debt is reduced.
- Round edits should animate row value changes.
- Respect Reduce Motion by disabling numeric count animations and using instant updates.

## UI Rules

- No nested cards.
- No glassmorphism.
- No gradient text.
- No cartoon illustrations.
- No real-money payment affordances.
- No color-only status communication.
- Use native iOS controls where they serve clarity.
- Every debt state must include a next action.
