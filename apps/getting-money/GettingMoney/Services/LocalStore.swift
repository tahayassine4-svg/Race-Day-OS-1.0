import Foundation
import SwiftData

/// App-level persistence composition root. It owns SwiftData and exposes
/// repositories to the UI layer, keeping ModelContext out of Views.
@MainActor
final class LocalStore {
    let container: ModelContainer
    let exerciseRepository: ExerciseRepository
    let workoutRepository: WorkoutRepository

    private let context: ModelContext

    init(container: ModelContainer, seedDate: Date = Date()) throws {
        self.container = container
        self.context = container.mainContext
        self.exerciseRepository = ExerciseRepository(context: context)
        self.workoutRepository = WorkoutRepository(context: context)

        try AppDataSeeder.seedIfNeeded(context, today: seedDate)
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-GMSeedDebtFixture") {
            try exerciseRepository.setDebt(key: "pushups", repsOwed: 24, updatedAt: seedDate)
            try exerciseRepository.setDebt(key: "pullups", repsOwed: 2, updatedAt: seedDate)
            try exerciseRepository.setDebt(key: "squats", repsOwed: 10, updatedAt: seedDate)
        }
#endif
    }

    convenience init(inMemory: Bool = false, seedDate: Date = Date()) throws {
        let container = try Persistence.makeContainer(inMemory: inMemory)
        try self.init(container: container, seedDate: seedDate)
    }

    convenience init(url: URL, seedDate: Date = Date()) throws {
        let container = try Persistence.makeContainer(at: url)
        try self.init(container: container, seedDate: seedDate)
    }
}
