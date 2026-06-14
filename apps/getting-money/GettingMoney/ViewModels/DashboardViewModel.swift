import Foundation

@Observable
@MainActor
final class DashboardViewModel {
    enum ChartMetric: String, CaseIterable, Identifiable {
        case balance, daily, streak
        var id: String { rawValue }
        var label: String {
            switch self {
            case .balance: "Balance"
            case .daily: "Daily"
            case .streak: "Streak"
            }
        }
    }

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

    private(set) var history: [HistoryPoint] = []
    private(set) var streakDays = 0
    private(set) var hasActivity = false
    private(set) var plannedRoundCount = 3
    var chartMetric: ChartMetric = .balance

    /// The day the dashboard is currently showing (start-of-day). Defaults to today;
    /// the chevron controls move it. `load` always keeps this in sync with its `today:`.
    private(set) var selectedDate: Date = GMCalendar.dayKey()
    var isToday: Bool { selectedDate == GMCalendar.dayKey() }
    var canGoToNextDay: Bool { selectedDate < GMCalendar.dayKey() }
    var canGoToPreviousDay: Bool { selectedDate > earliestSelectableDay }
    var selectedDateTitle: String {
        if isToday { return "Today" }
        return selectedDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
    var selectedDateEyebrow: String {
        "DAILY VIEW"
    }
    var dailyRepsTitle: String {
        isToday ? "Today's reps" : "\(selectedDate.formatted(.dateTime.weekday(.abbreviated))) reps"
    }
    var earnedDateLabel: String {
        isToday ? "Today" : selectedDate.formatted(.dateTime.weekday(.abbreviated))
    }

    private var earliestSelectableDay: Date {
        GMCalendar.calendar.date(byAdding: .day, value: -DayCloseService.maxLookbackDays, to: GMCalendar.dayKey())
            ?? GMCalendar.dayKey()
    }

    private let historyWindowDays = 14

    private let exerciseRepository: any ExerciseRepositoryProtocol
    private let workoutRepository: any WorkoutRepositoryProtocol
    private let earningsEngine: any EarningsEngineProtocol
    private let debtEngine: any DebtEngineProtocol
    private let historyEngine: any HistoryEngineProtocol

    init(
        exerciseRepository: any ExerciseRepositoryProtocol,
        workoutRepository: any WorkoutRepositoryProtocol,
        earningsEngine: any EarningsEngineProtocol = EarningsEngine(),
        debtEngine: any DebtEngineProtocol = DebtEngine(),
        historyEngine: any HistoryEngineProtocol = HistoryEngine()
    ) {
        self.exerciseRepository = exerciseRepository
        self.workoutRepository = workoutRepository
        self.earningsEngine = earningsEngine
        self.debtEngine = debtEngine
        self.historyEngine = historyEngine
    }

    func load(today: Date = Date()) {
        do {
            selectedDate = GMCalendar.dayKey(for: today)
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
            // Live payback: today's surplus reps repay debt immediately. (Today's
            // misses are NOT counted as debt yet — that happens at day-close.)
            rows = rows.map { row in
                ExerciseRow(id: row.id, name: row.name, glyph: row.glyph,
                            completed: row.completed, target: row.target,
                            debtOwed: debtEngine.liveDebt(key: row.id, targetReps: row.target,
                                                          completedReps: row.completed, persistedDebt: row.debtOwed),
                            bonusEarned: row.bonusEarned)
            }
            let snapshots = allEntries.map { RepEntrySnapshot(date: $0.timestamp, count: $0.count) }
            history = historyEngine.dailySeries(
                from: snapshots,
                repValue: settings.repValue,
                days: historyWindowDays,
                today: selectedDate
            )
            totalDebt = rows.reduce(0) { $0 + $1.debtOwed }
            bankBalance = history.last?.cumulativeMoney
                ?? earningsEngine.totalMoney(for: allEntries, repValue: settings.repValue)
            status = dashboardStatus
            // The empty state claims both "no reps logged" AND "nothing owed", so
            // outstanding debt must also count as activity — otherwise debt is
            // hidden behind a screen that falsely says nothing is owed.
            hasActivity = !snapshots.isEmpty || totalDebt > 0
            streakDays = historyEngine.currentStreak(history)
            let savedRounds = try workoutRepository.roundPlans(on: today)
            let roundNumbers = Set(savedRounds.map(\.roundNumber))
            plannedRoundCount = roundNumbers.isEmpty ? 3 : roundNumbers.count
            errorMessage = nil
        } catch {
            errorMessage = "Dashboard could not load."
        }
    }

    func showPreviousDay() {
        moveSelectedDay(by: -1)
    }

    func showNextDay() {
        moveSelectedDay(by: 1)
    }

    func showToday() {
        load(today: Date())
    }

    private func moveSelectedDay(by offset: Int) {
        guard let requested = GMCalendar.calendar.date(byAdding: .day, value: offset, to: selectedDate) else { return }
        let clamped = min(max(requested, earliestSelectableDay), GMCalendar.dayKey())
        load(today: clamped)
    }

    private var dashboardStatus: GMStatus {
        if totalDebt > 0 { return .activeDebt }
        if dailyTarget > 0 && dailyCompleted < dailyTarget { return .behind }
        return .profit
    }
}
