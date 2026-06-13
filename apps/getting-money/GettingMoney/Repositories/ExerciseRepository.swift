import Foundation
import SwiftData

/// Read/write access to the exercise catalog and its targets. Views never touch
/// `ModelContext` directly — they go through a repository (knowledge/ios-architecture.md).
@MainActor
protocol ExerciseRepositoryProtocol: AnyObject, Sendable {
    func allOrdered() throws -> [Exercise]
    func setEnabled(key: String, _ enabled: Bool) throws
    func currentTarget(for exercise: Exercise, on date: Date) -> Int
}

@MainActor
final class ExerciseRepository: ExerciseRepositoryProtocol {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func allOrdered() throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
        )
        return try context.fetch(descriptor)
    }

    func setEnabled(key: String, _ enabled: Bool) throws {
        guard let exercise = try allOrdered().first(where: { $0.key == key }) else { return }
        exercise.isEnabled = enabled
        try context.save()
    }

    /// The reps value of the most recent target on or before `date` (0 if none).
    func currentTarget(for exercise: Exercise, on date: Date = Date()) -> Int {
        let key = GMCalendar.dayKey(for: date)
        let applicable = (exercise.targets ?? [])
            .filter { $0.effectiveDate <= key }
            .sorted { $0.effectiveDate > $1.effectiveDate }
        return applicable.first?.reps ?? 0
    }
}
