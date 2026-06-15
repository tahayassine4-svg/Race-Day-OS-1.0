# Game Design — OPT-IN Module

> **This module is NOT part of the main workflow.** Pull it in ONLY when the app is a game or has substantial gamified mechanics (points/levels/streaks/rewards as a core loop, not a cosmetic badge). The Architect decides at GATE 1 and records "game module: ON" in the app's `docs/stack.md`. For a normal utility/productivity/content app, ignore this file entirely.

## When does "gamified" trigger this module?

- **Full game** → yes (engine selection below).
- **Gamified app** (the loop itself is play: a habit app built around streak mechanics, a learning app built around collecting/leveling) → yes, for the *design* principles below; the *stack* stays the normal SwiftUI stack.
- **App with a leaderboard or a badge** → no. That's a feature, not a game. Use the normal design system.

## Game engine selection (full games only)

```
2D + Apple-only            → SpriteKit / SceneKit (compiles in Xcode, tiny footprint, battery-friendly)
2D cross-platform          → Godot 4.x (free MIT, ~120MB editor, GDScript/C#)
3D, high-end visuals       → Unreal Engine 5.x (heavy; for visually complex 3D)
3D / commercial / cross    → Unity 6 (≈70% of top-grossing mobile games; free < $200k/yr; huge asset store)
```

- **SpriteKit/SceneKit** — best for native Apple 2D/3D; no cross-platform, infrequent updates.
- **Godot** — great solo 2D; lacks first-party ad SDKs, paid 3rd-party console porting.
- **Unity** — industry standard, 15GB+ editor, licensing fees past $200k/yr.
- **Unreal** — high fidelity, 40GB+, often too heavy for solo/indie.

**Game stack (Stack 3):** Unity 6 + C#/IL2CPP + local SQLite/binary save states + RevenueCat (cross-platform IAP) + Unity Analytics. For an Apple-only 2D game prefer SpriteKit to stay inside Xcode.

## Game design delight principles (also apply to gamified SwiftUI apps)

- **Calibrated friction** (Sago Mini "delayed run"): tune control friction to the user. Deliberate friction can *increase* clarity and intentionality — not all friction is bad.
- **Strategic withholding** (Balatro: no live score preview): hiding information can build suspense and emotional payoff. The "optimal" UX isn't always the most delightful one.
- **Juice / feedback:** physics-based springs, tactile compression, particle/haptic/sound feedback on meaningful events. Reward the action, not just the outcome.
- **The core loop is the product.** Validate the 10-second loop (do → feedback → reward → again) before building meta-systems, menus, or monetization.
- **Spatial/physical transmutation** (Blackbox, CapWords): turning the real environment into the play surface is a strong, award-winning concept move when the hardware supports it.
- **Don't just shrink a desktop layout** (Balatro mobile): re-tune hit targets, spacing, and accidental-action guards for the thumb.

## Game monetization

Consumable IAP (currency, lives, continues) and/or rewarded ads (hybrid). Manage cross-platform entitlements with RevenueCat. Same StoreKit 2 verification discipline as `knowledge/ios-launch.md`.

## How this plugs into the workflow

When the module is ON:
- **Architect** records the engine + game stack and the core loop in `docs/vision.md` / `docs/stack.md`.
- **Designer** designs the core-loop screen(s) and feedback states; the anti-slop and HIG rules in `knowledge/ios-design.md` still apply.
- **Implementer/Tester** — if using a non-SwiftUI engine, the SwiftUI-specific architecture/test rules relax to the engine's idioms, but the gate discipline (design first, test, data safety for save states, visual verification) is unchanged.
