# iOS Architecture — MVVM-C, Layers, Concurrency

> Distilled engineering reference. The **Implementer** and **Code-Reviewer** read this. It defines *how the code is shaped*, not what the app does.

## The layer cake (strict, top to bottom)

Never let a ViewModel become a God object. Five layers, each with one job:

1. **Model** — data structures, `SwiftData` `@Model` schemas, DTOs. No logic.
2. **Repository** — owns persistence. Wraps the SwiftData `ModelContext`/queries. Shields everything above from the database. *Views never see a `ModelContext`.*
3. **Service** — reusable business logic: networking, security, sync, calculations. Stateless where possible.
4. **ViewModel** — `@Observable` `@MainActor` class exposing **one screen's** state + actions. Coordinates Services/Repositories. Holds no persistence details.
5. **View** — declarative SwiftUI. Renders state, binds actions to the ViewModel. No I/O, no queries, no business rules.

```
View  →(binds)→  ViewModel  →(calls)→  Service  →(requests)→  Repository  →  SwiftData/CloudKit
```

## Hard rules (these are review-blocking)

- **No database queries in Views.** Do not use `@Query` in a view as the app grows — it couples UI to the schema and blocks migration. Wrap queries in a Repository. (`@Query` is acceptable only in a throwaway prototype, never past the foundation packet.)
- **No I/O in view construction.** SwiftUI recreates views constantly; a network/DB call in `init` or `body` causes frame drops. Move it to the ViewModel / a `.task` modifier.
- **ViewModels do not instantiate their own dependencies.** Define dependencies as `protocol`s, configure at the app entry point, inject via `init`. This is what makes them testable.
- **Swift 6, strict concurrency on.** Never disable concurrency warnings. Mark ViewModels `@MainActor`. Make dependency protocols `Sendable`.
- **async/await, not Combine.** Use `async`/`await` and `AsyncSequence`. Avoid legacy Combine pipelines in new code.
- **No UIKit / Storyboards** unless a specific capability genuinely requires it (and then isolate it). SwiftUI-first.

## Reference shape — DI + @Observable ViewModel

```swift
protocol BudgetRepositoryProtocol: Sendable {
    func loadBudgets() async throws -> [Budget]
}

@Observable
@MainActor
final class BudgetListViewModel {
    private let repository: any BudgetRepositoryProtocol
    var budgets: [Budget] = []
    var errorMessage: String?

    init(repository: any BudgetRepositoryProtocol) {   // injected, never constructed here
        self.repository = repository
    }

    func fetchBudgets() async {
        do { budgets = try await repository.loadBudgets() }
        catch { errorMessage = error.localizedDescription }
    }
}
```

The "-C" (Coordinator) is optional: introduce a coordinator/router only when navigation logic outgrows simple `NavigationStack` paths. Don't add it pre-emptively.

## Common architecture mistakes (call these out in review)

- Coupling Views directly to `@Query` / `ModelContext`.
- Fat ViewModels mixing persistence, networking, and formatting.
- Constructing dependencies inside ViewModels (untestable).
- Heavy work during view body evaluation.
- Disabling Swift 6 concurrency checks to "make it compile."

## Right-sizing (do not over-engineer)

Validate the core loop before adopting heavy patterns. Don't debate TCA vs MVVM-C before the product works. Start with the layer cake above; reach for more structure only when a real pain appears. See `knowledge/ios-launch.md` for MVP scoping.
