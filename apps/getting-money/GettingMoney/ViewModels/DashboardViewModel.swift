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
        let debtOwed: Int
        let bonusEarned: Int

        var fraction: Double { target == 0 ? 0 : Double(completed) / Double(target) }
        var remaining: Int { max(0, target - completed) }
    }

    private(set) var bankBalance = 0
    private(set) var earnedToday = 0
    private(set) var bonusEarnedToday = 0
    private(set) var totalDebt = 0
    private(set) var dailyCompleted = 0
    private(set) var dailyTarget = 0
    private(set) var status: GMStatus = .onTrack
    private(set) var rows: [ExerciseRow] = []
    private(set) var errorMessage: String?

    private let exerciseRepository: any ExerciseRepositoryProtocol
    private let workoutRepository: any WorkoutRepositoryProtocol
    private let earningsEngine: any EarningsEngineProtocol
    private let debtEngine: any DebtEngineProtocol

    init(
        exerciseRepository: any ExerciseRepositoryProtocol,
        workoutRepository: any WorkoutRepositoryProtocol,
        earningsEngine: any EarningsEngineProtocol = EarningsEngine(),
        debtEngine: any DebtEngineProtocol = DebtEngine()
    ) {
        self.exerciseRepository = exerciseRepository
        self.workoutRepository = workoutRepository
        self.earningsEngine = earningsEngine
        self.debtEngine = debtEngine
    }

    func load(today: Date = Date()) {
        do {
            let settings = try exerciseRepository.appSettings()
            let dayEntries = try workoutRepository.entries(on: today)
            let allEntries = try workoutRepository.allEntries()
            let grouped = Dictionary(grouping: dayEntries, by: \.exerciseKey)
            let debtByKey = Dictionary(uniqueKeysWithValues: try exerciseRepository
                .debtBalances()
                .compactMap { debt -> (String, Int)? in
                    guard let key = debt.exercise?.key else { return nil }
                    return (key, debt.repsOwed)
                })

            rows = try exerciseRepository.allOrdered()
                .filter(\.isEnabled)
                .map { exercise in
                    let completed = (grouped[exercise.key] ?? []).reduce(0) { $0 + $1.count }
                    let target = exerciseRepository.currentTarget(for: exercise, on: today)
                    let debtOwed = debtByKey[exercise.key] ?? 0
                    let debtSummary = debtEngine.settleDay(inputs: [
                        DebtExerciseInput(key: exercise.key, targetReps: target, completedReps: completed, existingDebt: debtOwed)
                    ])
                    let bonusReps = debtSummary.settlements.first?.bonusReps ?? 0
                    return ExerciseRow(
                        id: exercise.key,
                        name: exercise.name,
                        glyph: exercise.glyph,
                        completed: completed,
                        target: target,
                        debtOwed: debtOwed,
                        bonusEarned: bonusReps * settings.repValue
                    )
                }

            dailyCompleted = rows.reduce(0) { $0 + $1.completed }
            dailyTarget = rows.reduce(0) { $0 + $1.target }
            let dailyInputs = rows.map {
                DebtExerciseInput(key: $0.id, targetReps: $0.target, completedReps: $0.completed, existingDebt: $0.debtOwed)
            }
            let debtSummary = debtEngine.settleDay(inputs: dailyInputs)
            earnedToday = debtSummary.settlements.reduce(0) { $0 + $1.earnedMoney(repValue: settings.repValue) }
            bonusEarnedToday = rows.reduce(0) { $0 + $1.bonusEarned }
            totalDebt = rows.reduce(0) { $0 + $1.debtOwed }
            bankBalance = earningsEngine.totalMoney(for: allEntries, repValue: settings.repValue)
            status = dashboardStatus
            errorMessage = nil
        } catch {
            errorMessage = "Dashboard could not load."
        }
    }

    private var dashboardStatus: GMStatus {
        if totalDebt > 0 { return .activeDebt }
        if dailyTarget > 0 && dailyCompleted < dailyTarget { return .behind }
        return .profit
    }
}
