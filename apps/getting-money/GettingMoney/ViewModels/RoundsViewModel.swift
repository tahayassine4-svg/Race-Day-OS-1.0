import Foundation

@Observable
@MainActor
final class RoundsViewModel {
    enum Payoff: String, CaseIterable, Identifiable {
        case none, small, half, full
        var id: String { rawValue }
        var label: String {
            switch self {
            case .none: "None"
            case .small: "Small"
            case .half: "Half"
            case .full: "Full"
            }
        }
        var level: PayoffLevel {
            switch self {
            case .none: .none
            case .small: .small
            case .half: .medium
            case .full: .full
            }
        }
    }

    private(set) var rounds: [PlannedRound] = []
    private(set) var availableRoundCounts = [2, 3, 4, 5]
    private(set) var selectedRoundCount = 3
    private(set) var dailyTarget = 0
    private(set) var plannedTotal = 0
    private(set) var extraReps = 0
    private(set) var extraMoney = 0
    private(set) var totalDebt = 0
    private(set) var payoff: Payoff = .none
    private(set) var payoffReps = 0
    private(set) var errorMessage: String?

    var hasDebt: Bool { totalDebt > 0 }

    private var targets: [RoundTarget] = []
    private var debts: [PaybackDebt] = []
    private var repValue = 1
    private let exerciseRepository: any ExerciseRepositoryProtocol
    private let workoutRepository: any WorkoutRepositoryProtocol
    private let planner: any RoundPlannerProtocol
    private let paybackPlanner: any PaybackPlannerProtocol

    init(
        exerciseRepository: any ExerciseRepositoryProtocol,
        workoutRepository: any WorkoutRepositoryProtocol,
        planner: any RoundPlannerProtocol = RoundPlanner(),
        paybackPlanner: any PaybackPlannerProtocol = PaybackPlanner()
    ) {
        self.exerciseRepository = exerciseRepository
        self.workoutRepository = workoutRepository
        self.planner = planner
        self.paybackPlanner = paybackPlanner
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
            let balances = try exerciseRepository.debtBalances()
            totalDebt = balances.reduce(0) { $0 + $1.repsOwed }
            debts = try exerciseRepository.allOrdered()
                .filter(\.isEnabled)
                .compactMap { exercise in
                    let owed = exercise.debt?.repsOwed ?? 0
                    guard owed > 0 else { return nil }
                    return PaybackDebt(key: exercise.key, name: exercise.name, glyph: exercise.glyph, repsOwed: owed)
                }
            dailyTarget = targets.reduce(0) { $0 + $1.reps }
            if !hasDebt { payoff = .none }

            let saved = try workoutRepository.roundPlans(on: today)
            if saved.isEmpty {
                rebuild()
            } else {
                selectedRoundCount = Set(saved.map(\.roundNumber)).count
                payoff = saved.contains(where: \.includesDebtPayoff) ? .full : .none
                rounds = makeRounds(from: saved)
                recalculateFromSaved(saved)
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

    func choosePayoff(_ payoff: Payoff) {
        self.payoff = hasDebt ? payoff : .none
        rebuild()
    }

    func adjust(roundID: Int, exerciseKey: String, by delta: Int) {
        guard let roundIndex = rounds.firstIndex(where: { $0.id == roundID }),
              let exerciseIndex = rounds[roundIndex].exercises.firstIndex(where: { $0.key == exerciseKey }) else { return }
        let current = rounds[roundIndex].exercises[exerciseIndex]
        rounds[roundIndex].exercises[exerciseIndex] = RoundTarget(
            key: current.key,
            name: current.name,
            glyph: current.glyph,
            reps: max(current.payoffReps, current.reps + delta),
            payoffReps: current.payoffReps
        )
        recalculate()
    }

    func save(today: Date = Date()) {
        do {
            try workoutRepository.replaceRoundPlans(rounds, includesDebtPayoff: payoff != .none, on: today)
            errorMessage = nil
        } catch {
            errorMessage = "Rounds could not be saved."
        }
    }

    // MARK: Building

    private func rebuild() {
        let allocations = payoff == .none ? [] : paybackPlanner.payoffAllocations(level: payoff.level, debts: debts)
        let payoffByKey = Dictionary(uniqueKeysWithValues: allocations.map { ($0.key, $0.reps) })
        payoffReps = allocations.reduce(0) { $0 + $1.reps }

        let basePlan = planner.plan(targets: targets, rounds: selectedRoundCount)
        let payoffTargets = targets.map { t in
            RoundTarget(key: t.key, name: t.name, glyph: t.glyph, reps: payoffByKey[t.key] ?? 0)
        }
        let payoffPlan = planner.plan(targets: payoffTargets, rounds: selectedRoundCount)

        rounds = zip(basePlan, payoffPlan).map { base, pay in
            PlannedRound(
                id: base.id,
                exercises: zip(base.exercises, pay.exercises).map { baseEx, payEx in
                    RoundTarget(
                        key: baseEx.key,
                        name: baseEx.name,
                        glyph: baseEx.glyph,
                        reps: baseEx.reps + payEx.reps,
                        payoffReps: payEx.reps
                    )
                }
            )
        }
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
        payoffReps = rounds.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.payoffReps } }
        extraReps = max(0, plannedTotal - dailyTarget - payoffReps)
        extraMoney = extraReps * repValue
    }

    private func recalculateFromSaved(_ saved: [RoundPlan]) {
        plannedTotal = rounds.reduce(0) { $0 + $1.totalReps }
        payoffReps = payoff == .none ? 0 : max(0, plannedTotal - dailyTarget)
        extraReps = max(0, plannedTotal - dailyTarget - payoffReps)
        extraMoney = extraReps * repValue
    }
}
