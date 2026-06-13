import Foundation

@Observable
@MainActor
final class RoundsViewModel {
    private(set) var rounds: [PlannedRound] = []
    private(set) var availableRoundCounts = [2, 3, 4, 5]
    private(set) var selectedRoundCount = 3
    private(set) var dailyTarget = 0
    private(set) var plannedTotal = 0
    private(set) var extraReps = 0
    private(set) var extraMoney = 0
    private(set) var totalDebt = 0
    private(set) var errorMessage: String?

    private var targets: [RoundTarget] = []
    private var repValue = 1
    private let exerciseRepository: any ExerciseRepositoryProtocol
    private let workoutRepository: any WorkoutRepositoryProtocol
    private let planner: any RoundPlannerProtocol

    init(
        exerciseRepository: any ExerciseRepositoryProtocol,
        workoutRepository: any WorkoutRepositoryProtocol,
        planner: any RoundPlannerProtocol = RoundPlanner()
    ) {
        self.exerciseRepository = exerciseRepository
        self.workoutRepository = workoutRepository
        self.planner = planner
    }

    func load(today: Date = Date()) {
        do {
            let settings = try exerciseRepository.appSettings()
            repValue = settings.repValue
            targets = try exerciseRepository.allOrdered()
                .filter(\.isEnabled)
                .map { exercise in
                    RoundTarget(
                        key: exercise.key,
                        name: exercise.name,
                        glyph: exercise.glyph,
                        reps: exerciseRepository.currentTarget(for: exercise, on: today)
                    )
                }
            totalDebt = try exerciseRepository.debtBalances().reduce(0) { $0 + $1.repsOwed }
            dailyTarget = targets.reduce(0) { $0 + $1.reps }

            let saved = try workoutRepository.roundPlans(on: today)
            if saved.isEmpty {
                rebuild()
            } else {
                selectedRoundCount = Set(saved.map(\.roundNumber)).count
                rounds = makeRounds(from: saved)
                recalculate()
            }
            errorMessage = nil
        } catch {
            rounds = []
            errorMessage = "Rounds could not load."
        }
    }

    func chooseRoundCount(_ count: Int) {
        selectedRoundCount = count
        rebuild()
    }

    func adjust(roundID: Int, exerciseKey: String, by delta: Int) {
        guard let roundIndex = rounds.firstIndex(where: { $0.id == roundID }),
              let exerciseIndex = rounds[roundIndex].exercises.firstIndex(where: { $0.key == exerciseKey }) else { return }
        rounds[roundIndex].exercises[exerciseIndex] = RoundTarget(
            key: rounds[roundIndex].exercises[exerciseIndex].key,
            name: rounds[roundIndex].exercises[exerciseIndex].name,
            glyph: rounds[roundIndex].exercises[exerciseIndex].glyph,
            reps: max(0, rounds[roundIndex].exercises[exerciseIndex].reps + delta)
        )
        recalculate()
    }

    func save(today: Date = Date()) {
        do {
            try workoutRepository.replaceRoundPlans(rounds, includesDebtPayoff: false, on: today)
            errorMessage = nil
        } catch {
            errorMessage = "Rounds could not be saved."
        }
    }

    private func rebuild() {
        rounds = planner.plan(targets: targets, rounds: selectedRoundCount)
        recalculate()
    }

    private func makeRounds(from saved: [RoundPlan]) -> [PlannedRound] {
        let targetByKey = Dictionary(uniqueKeysWithValues: targets.map { ($0.key, $0) })
        return Dictionary(grouping: saved, by: \.roundNumber)
            .keys
            .sorted()
            .map { number in
                let entries = saved.filter { $0.roundNumber == number }
                return PlannedRound(
                    id: number,
                    exercises: targets.map { target in
                        let savedTarget = entries.first { $0.exerciseKey == target.key }
                        let source = targetByKey[target.key] ?? target
                        return RoundTarget(key: source.key, name: source.name, glyph: source.glyph, reps: savedTarget?.plannedReps ?? 0)
                    }
                )
            }
    }

    private func recalculate() {
        plannedTotal = rounds.reduce(0) { $0 + $1.totalReps }
        extraReps = max(0, plannedTotal - dailyTarget)
        extraMoney = extraReps * repValue
    }
}
