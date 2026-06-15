# UI System — Getting Money App

## Design Read

Reading this as: a premium native iOS calisthenics finance tracker for a discipline-driven personal user, with a private-banking visual language, leaning toward pure white surfaces, graphite typography, restrained amber action color, and short state-driven motion.

## Role

This file is the working UI contract for Designer, Implementer, Tester, and UI-Reviewer. Packet-specific rendered mockups in `design/packet-NN.png` are the source of truth for layout approval. The native SwiftUI implementation must match the approved images.

## Palette

Use these semantic roles in SwiftUI. The OKLCH values are the design source; native colors may be converted during implementation while preserving contrast and hierarchy.

### Light

| Role | OKLCH | Usage |
|---|---|---|
| Background | `oklch(1.000 0.000 0)` | Main app canvas |
| Surface | `oklch(0.972 0.004 48)` | Grouped panels and soft sections |
| Elevated Surface | `oklch(0.992 0.002 48)` | High-priority modules |
| Ink | `oklch(0.180 0.012 52)` | Primary text and numbers |
| Muted | `oklch(0.455 0.018 52)` | Secondary text |
| Primary | `oklch(0.607 0.163 47.7)` | Primary actions, earned-value highlights |
| Primary Pressed | `oklch(0.540 0.150 47.7)` | Pressed primary actions |
| Accent | `oklch(0.350 0.095 218)` | Secondary emphasis and selected informational states |
| Success | `oklch(0.548 0.132 145)` | Paid off, streak maintained, on track |
| Warning | `oklch(0.680 0.130 78)` | Approaching debt or incomplete target |
| Danger | `oklch(0.560 0.160 28)` | Active debt and missed target |
| Border | `oklch(0.900 0.006 52)` | Hairlines and separators |

### Dark

| Role | OKLCH | Usage |
|---|---|---|
| Background | `oklch(0.115 0.004 52)` | Main dark app canvas |
| Surface | `oklch(0.170 0.007 52)` | Grouped panels and soft sections |
| Elevated Surface | `oklch(0.215 0.010 52)` | High-priority modules |
| Ink | `oklch(0.955 0.003 52)` | Primary text and numbers |
| Muted | `oklch(0.720 0.012 52)` | Secondary text |
| Primary | `oklch(0.690 0.150 47.7)` | Primary actions, earned-value highlights |
| Primary Pressed | `oklch(0.610 0.145 47.7)` | Pressed primary actions |
| Accent | `oklch(0.715 0.080 218)` | Secondary emphasis and selected informational states |
| Success | `oklch(0.700 0.115 145)` | Paid off, streak maintained, on track |
| Warning | `oklch(0.780 0.120 78)` | Approaching debt or incomplete target |
| Danger | `oklch(0.700 0.145 28)` | Active debt and missed target |
| Border | `oklch(0.310 0.010 52)` | Hairlines and separators |

Text on saturated fills should be near-white. Debt, success, and warning states must also use labels/icons, never color alone.

## Typography

- Use native SF Pro through SwiftUI system fonts.
- Important numbers use tabular figures.
- Large balance: 44-56 pt, semibold/bold.
- Screen title: 28-34 pt, bold.
- Section title: 17-20 pt, semibold.
- Body: 15-17 pt, regular.
- Metadata: 12-13 pt, medium.

## Spacing

- Base spacing scale: 4, 8, 12, 16, 20, 24, 32.
- Screen horizontal padding: 20.
- Dense rows: 12 vertical padding.
- Major dashboard modules: 20-24 internal padding.
- Avoid nested cards. Use spacing, separators, or one elevated surface instead.

## Radius

- Small controls: 8.
- Rows and compact modules: 12.
- Major dashboard modules: 16.
- Full pills only for status labels and segmented controls.

## Navigation

Primary tabs:

- Dashboard
- Log
- Rounds
- Debt
- Settings

Dashboard is the launch screen. It must show bank balance, debt balance, streak, today's exercise progress, and a clear logging action.

## Component Contracts

- `BalanceHeader`: total bank balance, today's earned amount, current status.
- `ExerciseProgressRow`: exercise name, completed/target reps, remaining reps, progress visual, debt marker if applicable.
- `QuickRepStepper`: quick-add controls with clear haptic/visual feedback.
- `RoundCircleCard`: round number, per-exercise reps, editable actuals, total effect.
- `DebtPayoffCard`: total debt, plan mode, next repayment action.
- `StatusPill`: on track, over target, active debt, paid off.
- `TrendChart`: compact bank/debt/streak visualization.

## Motion

- Standard transitions: 150-220 ms.
- Use motion for state feedback only: balance count-up, debt reduction, round total change, tab/selection change.
- Respect Reduce Motion with instant value changes and no count-up animation.

## Design Gates

- Every UI packet must produce `design/packet-NN.html` and `design/packet-NN.png`.
- Yassine approves the rendered PNG before SwiftUI implementation starts.
- UI-Reviewer compares simulator screenshots against the approved PNG before packet pass.
