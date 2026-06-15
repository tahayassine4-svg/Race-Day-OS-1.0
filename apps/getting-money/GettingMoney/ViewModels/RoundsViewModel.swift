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
    let minRoundCount = 1
    let maxRoundCount = 10
    private(set) var selectedRoundCount = 3
    private(set) var dailyTarget = 0
    private(set) var plannedTotal = 0
    private(set) var extraReps = 0
    private(set) var extraMoney = 0
    private(set) var totalDebt = 0
    private(set) var payoff: Payoff = .none
    private(set) var payoffReps = 0
    private(set) var completedRounds: Set<Int> = []
    private(set) var roundsLoggedMoney = 0
    private(set) var errorMessage: String?

    var hasDebt: Bool { totalDebt > 0 }

    // MARK: Completion state (derived from reps tagged with their source round)
    func isCompleted(_ roundID: Int) -> Bool { completedRounds.contains(roundID) }
    var completedCount: Int { completedRounds.count }
    /// Round count can only change before any round is ticked off (changing it
    /// would renumber rounds and orphan already-logged reps).
    var canChangeRoundCount: Bool { completedRounds.isEmpty }
    var nextIncompleteRound: Int? { rounds.first { !completedRounds.contains($0.id) }?.id }
    var allRoundsComplete: Bool { !rounds.isEmpty && completedRounds.count == rounds.count }

    private var targets: [RoundTarget] = []
    private var debts: [PaybackDebt] = []
    private var requestedPayoff: Payoff?
    private var repValue = 1
    private let exerciseRepository: any ExerciseRepositoryProtocol
    private let workoutRepository: any WorkoutRepositoryProtocol
    private let planner: any RoundPlannerProtocol
    private let paybackPlanner: any PaybackPlannerProtocol
    private let debtEngine: any DebtEngineProtocol = DebtEngine()

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
            // Fold only the debt that remains after today's payback reps (live),
            // so payoff never folds reps the user already did today.
            let entries = try workoutRepository.entries(on: today)
            // Reconciled per-exercise reps (Log + Rounds counted once) so live
            // payback never double-credits the same reps.
            let completedByKey = try workoutRepository.completedReps(on: today)
            debts = try exerciseRepository.allOrdered()
                .filter(\.isEnabled)
                .compactMap { exercise in
                    let persisted = exercise.debt?.repsOwed ?? 0
                    guard persisted > 0 else { return nil }
                    let remaining = debtEngine.liveDebt(
                        key: exercise.key,
                        targetReps: exerciseRepository.currentTarget(for: exercise, on: today),
                        completedReps: completedByKey[exercise.key] ?? 0,
                        persistedDebt: persisted
                    )
                    guard remaining > 0 else { return nil }
                    return PaybackDebt(key: exercise.key, name: exercise.name, glyph: exercise.glyph, repsOwed: remaining)
                }
            totalDebt = debts.reduce(0) { $0 + $1.repsOwed }
            dailyTarget = targets.reduce(0) { $0 + $1.reps }
            if !hasDebt { payoff = .none }

            // Which rounds are ticked off = which round numbers have logged reps today.
            completedRounds = Set(entries.compactMap { $0.sourceRoundNumber })
            roundsLoggedMoney = entries
                .filter { $0.sourceRoundNumber != nil }
                .reduce(0) { $0 + $1.count } * repValue

            let saved = try workoutRepository.roundPlans(on: today)
            if saved.isEmpty {
                rebuild()
            } else {
                selectedRoundCount = Set(saved.map(\.roundNumber)).count
                payoff = saved.contains(where: \.includesDebtPayoff) ? .full : .none
                rounds = makeRounds(from: saved)
                recalculateFromSaved(saved)
            }
            // An explicit payoff request (e.g. the Debt screen's "Add payoff to
            // today's rounds") survives this reload and overrides the saved plan.
            if let requested = requestedPayoff {
                requestedPayoff = nil
                choosePayoff(requested)
            }
            errorMessage = nil
        } catch {
            rounds = []
            errorMessage = "Rounds could not load."
        }
    }

    func chooseRoundCount(_ count: Int) {
        guard canChangeRoundCount else { return }
        selectedRoundCount = min(maxRoundCount, max(minRoundCount, count))
        rebuild()
        persistPlan()
    }

    func incrementRoundCount() { chooseRoundCount(selectedRoundCount + 1) }
    func decrementRoundCount() { chooseRoundCount(selectedRoundCount - 1) }

    func choosePayoff(_ payoff: Payoff) {
        guard canChangeRoundCount else { return } // locked once rounds are ticked off
        self.payoff = hasDebt ? payoff : .none
        rebuild()
        persistPlan()
    }

    /// Records a payoff to apply on the next `load()` — lets navigation into the
    /// Rounds tab (which triggers a reload) keep an externally-chosen payoff.
    func requestPayoff(_ payoff: Payoff) {
        requestedPayoff = payoff
    }

    func adjust(roundID: Int, exerciseKey: String, by delta: Int) {
        // A ticked-off round is locked; the user reopens it with "Edit" first.
        guard !completedRounds.contains(roundID) else { return }
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
        persistPlan()
    }

    /// Tick a round on/off. Ticking logs its reps to the daily balance (tagged with
    /// the round); un-ticking removes exactly those reps. "Edit" on a card un-ticks.
    func toggleRoundCompleted(_ roundID: Int, today: Date = Date()) {
        do {
            if completedRounds.contains(roundID) {
                try workoutRepository.deleteRoundEntries(roundNumber: roundID, on: today)
            } else {
                guard let round = rounds.first(where: { $0.id == roundID }) else { return }
                try workoutRepository.replaceRoundPlans(rounds, includesDebtPayoff: payoff != .none, on: today)
                for exercise in round.exercises where exercise.reps > 0 {
                    _ = try workoutRepository.addRepEntry(
                        exerciseKey: exercise.key, count: exercise.reps,
                        sourceRoundNumber: roundID, at: today
                    )
                }
            }
            load(today: today)
        } catch {
            errorMessage = "Round could not be updated."
        }
    }

    /// Bottom CTA: tick off the next round that isn't done yet.
    func completeNextRound(today: Date = Date()) {
        guard let next = nextIncompleteRound else { return }
        toggleRoundCompleted(next, today: today)
    }

    private func persistPlan(today: Date = Date()) {
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
