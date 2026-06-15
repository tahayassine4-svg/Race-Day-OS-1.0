# SwiftUI / UI Code Review Checklist

Used by the Code-Reviewer for SwiftUI/view code. Mark each PASS / FAIL / N/A. Backed by `knowledge/ios-architecture.md` and `knowledge/ios-design.md`.

---

## View layer discipline
- [ ] **Views are dumb** — render state, bind actions; no business logic, no networking, no calculations in the view.
- [ ] **No persistence in views** — no `@Query` / `ModelContext` / direct fetches in the view layer (past the prototype). Data comes from a ViewModel backed by a Repository.
- [ ] **No heavy work in `body`/`init`** — no I/O or expensive computation during view construction; use `.task`/the ViewModel.
- [ ] **Binds to an @Observable ViewModel** — via `@State`/`@Bindable`; the view owns no app state it shouldn't.
- [ ] **Size** — view files stay focused (~under 200 lines); large screens split into subviews.

## Design-system fidelity
- [ ] **Tokens, not magic values** — colors/spacing/radii/type come from `docs/ui-system.md`, not scattered literals.
- [ ] **Matches the approved mockup** — layout, hierarchy, and accent usage match `design/packet-NN.png`.
- [ ] **Light + dark** both render with correct hierarchy (no pure #000/#fff).

## Ergonomics & accessibility (knowledge/ios-design.md)
- [ ] **44pt touch targets**, primary actions thumb-reachable (bottom third / tab bar / sheet).
- [ ] **Dynamic Type** — layout survives large accessibility sizes.
- [ ] **VoiceOver** — interactive elements have descriptive `accessibilityLabel`; reading order matches visual order.
- [ ] **Contrast holds** — incl. over varied/translucent (Liquid Glass) backgrounds; color is not the sole status cue.
- [ ] **Reduced Motion** — deep/spring transitions have a cross-fade fallback.

## States & motion
- [ ] **Empty / loading / error states** are designed and present, not silent.
- [ ] **Motion is motivated** — feedback/hierarchy/continuity only; press feedback + tasteful completion (haptics where apt). No motion for show.

## Code quality
- [ ] **No dead code** — no commented-out blocks, unused imports, unreachable branches.
- [ ] **No debug output** — no stray `print()`/logging left in shipping paths.
- [ ] **Swift 6 concurrency clean** — `@MainActor` where required; no concurrency warnings suppressed.
