import SwiftUI
import SwiftData

@main
struct GettingMoneyApp: App {
    let store: LocalStore

    init() {
        do {
            store = try LocalStore()
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
        // Close out any completed days into rep-debt before the first screen loads.
        try? DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(store: store)
                // v1 is dark-first per docs/ui-system.md. Light mirror is deferred to a polish packet.
                .preferredColorScheme(.dark)
        }
        .modelContainer(store.container)
    }
}
