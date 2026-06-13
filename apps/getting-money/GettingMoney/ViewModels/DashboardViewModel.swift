import Foundation

@Observable
@MainActor
final class DashboardViewModel {
    struct ExerciseRow: Identifiable {
        let id: String
        let name: String
        let glyph: String
        let completed: Int
        let target: Int
        let bonusEarned: Int

        var fraction: Double { target == 0 ? 0 : Double(completed) / Double(target) }
        var remaining: Int { max(0, target - completed) }
    }

    private(set) var bankBalance = 0
    private(set) var earnedToday = 0
    private(set) var bonusEarnedToday = 0
    private(set) var dailyCompleted = 0
    private(set) var dailyTarget = 0
    private(set) var rows: [ExerciseRow] = []
    private(set) var errorMessage: String?

    private let exerciseRepository: any ExerciseRepositoryProtocol
    private let workoutRepository: any WorkoutRepositoryProtocol
    private let earningsEngine: any EarningsEngineProtocol

    init(
        exerciseRepository: any ExerciseRepositoryProtocol,
        workoutRepository: any WorkoutRepositoryProtocol,
        earningsEngine: any EarningsEngineProtocol = EarningsEngine()
    ) {
        self.exerciseRepository = exerciseRepository
        self.workoutRepository = workoutRepository
        self.earningsEngine = earningsEngine
    }

    func load(today: Date = Date()) {
        do {
            let settings = try exerciseRepository.appSettings()
            let dayEntries = try workoutRepository.entries(on: today)
            let allEntries = try workoutRepository.allEntries()
            let grouped = Dictionary(grouping: dayEntries, by: \.exerciseKey)

            rows = try exerciseRepository.allOrdered()
                .filter(\.isEnabled)
                .map { exercise in
                    let completed = (grouped[exercise.key] ?? []).reduce(0) { $0 + $1.count }
                    let target = exerciseRepository.currentTarget(for: exercise, on: today)
                    let summary = earningsEngine.summary(completedReps: completed, targetReps: target, repValue: settings.repValue)
                    return ExerciseRow(id: exercise.key, name: exercise.name, glyph: exercise.glyph, completed: completed, target: target, bonusEarned: summary.bonusEarned)
                }

            dailyCompleted = rows.reduce(0) { $0 + $1.completed }
            dailyTarget = rows.reduce(0) { $0 + $1.target }
            earnedToday = earningsEngine.summary(completedReps: dailyCompleted, targetReps: dailyTarget, repValue: settings.repValue).earned
            bonusEarnedToday = rows.reduce(0) { $0 + $1.bonusEarned }
            bankBalance = earningsEngine.totalMoney(for: allEntries, repValue: settings.repValue)
            errorMessage = nil
        } catch {
            errorMessage = "Dashboard could not load."
        }
    }
}
