---
description: Swift 6 / SwiftUI architecture conventions — enforced on every Swift edit
globs:
  - "apps/**/*.swift"
  - "project-tracker-ios/**/*.swift"
  - "GettinMoney/**/*.swift"
alwaysApply: false
---

# Swift 6 Conventions (enforceable, review-blocking)

These are the conventions IMPLEMENTER must follow and CODE_REVIEWER must
block on. For the rationale and reference architecture (layer cake, DI
example), see `.claude/rules/ios-architecture.md` — read that once per packet;
this file is the per-edit checklist.

- **No database queries in Views.** No `@Query`/`ModelContext` in a View past
  the foundation packet — wrap in a Repository.
- **No I/O in view construction.** No network/DB calls in `init` or `body`;
  use the ViewModel or a `.task` modifier.
- **ViewModels do not instantiate their own dependencies.** Define `protocol`
  dependencies, configure at the app entry point, inject via `init`.
- **Swift 6 strict concurrency on, always.** Never disable concurrency
  warnings. ViewModels are `@MainActor` `@Observable`. Dependency protocols
  are `Sendable`.
- **async/await, not Combine.** No new Combine pipelines.
- **SwiftUI-first.** No UIKit/Storyboards unless a specific capability
  requires it, and then isolate it.
