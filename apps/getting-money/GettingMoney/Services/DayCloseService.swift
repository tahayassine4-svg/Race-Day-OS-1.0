import Foundation

/// Settles every completed past day into persisted rep-debt — the production
/// trigger the `DebtEngine` never had (Packet 09). Runs on launch and on
/// foreground. "Today" always stays live and is never settled until it becomes a
/// past day. Days are settled chronologically so a strong day's surplus repays
/// earlier debt. Debt is capped per exercise at `debtCapMultiplier × that day's
/// target` (the 2-day ceiling) so a long absence stays recoverable, never a wall.
@MainActor
struct DayCloseService {
    /// Settling further back than this is pointless: the per-exercise cap is reached
    /// within a couple of fully-missed days, so older days can't change the end
    /// state. Bounds the work done after a very long absence.
    static let maxLookbackDays = 60

    private let exerciseRepository: any ExerciseRepositoryProtocol
    private let workoutRepository: any WorkoutRepositoryProtocol
    private let debtEngine: any DebtEngineProtocol

    init(
        exerciseRepository: any ExerciseRepositoryProtocol,
        workoutRepository: any WorkoutRepositoryProtocol,
        debtEngine: any DebtEngineProtocol = DebtEngine()
    ) {
        self.exerciseRepository = exerciseRepository
        self.workoutRepository = workoutRepository
        self.debtEngine = debtEngine
    }

    /// Settles all completed days from the watermark up to (not including) today.
    /// Returns the number of days settled.
    @discardableResult
    func run(today: Date = Date()) throws -> Int {
        let settings = try exerciseRepository.appSettings()
        let calendar = GMCalendar.calendar
        let todayKey = GMCalendar.dayKey(for: today)

        // First launch ever: set the watermark, settle nothing.
        guard let last = settings.lastSettledDate else {
            try exerciseRepository.markDayClosed(through: todayKey)
            return 0
        }

        let lastKey = GMCalendar.dayKey(for: last)
        guard lastKey < todayKey else { return 0 } // already settled (or clock skew)

        // Bound the lookback; older days can't change the capped end state.
        let earliest = calendar.date(byAdding: .day, value: -Self.maxLookbackDays, to: todayKey) ?? lastKey
        var dayKey = max(lastKey, earliest)

        let cap = max(1, settings.debtCapMultiplier)
        let exercises = try exerciseRepository.allOrdered().filter(\.isEnabled)

        // Reconciled reps by day + exercise up front (avoids touching/creating
        // empty WorkoutDay rows for days that were never trained). Each day's
        // per-exercise total is max(manual, round), so a workout logged both ways
        // settles debt once, not twice.
        let completedByDay: [Date: [String: Int]] = Dictionary(
            grouping: try workoutRepository.allEntries()
        ) { GMCalendar.dayKey(for: $0.timestamp) }
            .mapValues { RepReconciler.completedByExercise($0) }

        var daysSettled = 0
        while dayKey < todayKey {
            let dayCompleted = completedByDay[dayKey] ?? [:]
            let inputs = exercises.map { exercise in
                DebtExerciseInput(
                    key: exercise.key,
                    targetReps: exerciseRepository.currentTarget(for: exercise, on: dayKey),
                    completedReps: dayCompleted[exercise.key] ?? 0,
                    existingDebt: exercise.debt?.repsOwed ?? 0
                )
            }
            let summary = debtEngine.settleDay(inputs: inputs)
            try exerciseRepository.applyDebtSettlements(summary.settlements, capMultiplier: cap, updatedAt: dayKey)
            daysSettled += 1

            guard let next = calendar.date(byAdding: .day, value: 1, to: dayKey) else { break }
            dayKey = next
        }

        try exerciseRepository.markDayClosed(through: todayKey)
        return daysSettled
    }

    /// Recomputes persisted rep-debt from scratch over the reconciled history.
    /// Run once after the rep-reconciliation fix so debt previously settled against
    /// double-counted (Log + Rounds) totals is corrected. Only derived debt is
    /// touched — rep entries are never modified. Safe for fresh installs and for
    /// days before the user started: `currentTarget` is 0 then, so no phantom debt.
    @discardableResult
    func resettle(today: Date = Date()) throws -> Int {
        for exercise in try exerciseRepository.allOrdered() {
            try exerciseRepository.setDebt(key: exercise.key, repsOwed: 0, updatedAt: today)
        }
        let calendar = GMCalendar.calendar
        let todayKey = GMCalendar.dayKey(for: today)
        let earliest = calendar.date(byAdding: .day, value: -Self.maxLookbackDays, to: todayKey) ?? todayKey
        // Rewind the watermark so `run` replays every completed day from `earliest`.
        try exerciseRepository.markDayClosed(through: earliest)
        return try run(today: today)
    }
}
