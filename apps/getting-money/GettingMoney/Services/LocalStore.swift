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
        if ProcessInfo.processInfo.arguments.contains("-GMSeedOneMissedDayFixture") {
            // One clean missed-yesterday scenario: launch day-close should turn
            // exactly yesterday's targets into debt (100 push, 10 pull, 150 squat).
            let calendar = GMCalendar.calendar
            let yesterday = calendar.date(byAdding: .day, value: -1, to: seedDate) ?? seedDate
            for seed in AppDataSeeder.defaults where seed.isEnabled {
                try exerciseRepository.setTarget(key: seed.key, reps: seed.target, effectiveDate: yesterday, isManualOverride: false)
            }
            try exerciseRepository.markDayClosed(through: yesterday)
        }
        if ProcessInfo.processInfo.arguments.contains("-GMSeedMissedDaysFixture") {
            // Pretend the user set targets a week ago, last opened the app 5 days
            // ago, and logged nothing since — so the launch day-close accrues debt
            // across the gap and clamps it at the 2-day ceiling.
            let calendar = GMCalendar.calendar
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: seedDate) ?? seedDate
            let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: seedDate) ?? seedDate
            for seed in AppDataSeeder.defaults where seed.isEnabled {
                try exerciseRepository.setTarget(key: seed.key, reps: seed.target, effectiveDate: weekAgo, isManualOverride: false)
            }
            try exerciseRepository.markDayClosed(through: fiveDaysAgo)
        }
        if ProcessInfo.processInfo.arguments.contains("-GMEnableDips") {
            try exerciseRepository.setEnabled(key: "dips", true) // verify the toggle stays turn-off-able
        }
        if ProcessInfo.processInfo.arguments.contains("-GMSeedRoundDoneFixture") {
            // Round 1 of the default 3-round split already ticked off (34 push, 4
            // pull, 50 squat tagged to round 1) so the completed-round UI + the
            // dashboard progress can be screenshotted.
            _ = try workoutRepository.addRepEntry(exerciseKey: "pushups", count: 34, sourceRoundNumber: 1, at: seedDate)
            _ = try workoutRepository.addRepEntry(exerciseKey: "pullups", count: 4, sourceRoundNumber: 1, at: seedDate)
            _ = try workoutRepository.addRepEntry(exerciseKey: "squats", count: 50, sourceRoundNumber: 1, at: seedDate)
        }
        if ProcessInfo.processInfo.arguments.contains("-GMSeedPaybackFixture") {
            // 50 reps of standing pushup debt, with 30 payback reps already logged
            // today (130 = 100 target + 30 payback) → Debt should read 20 live.
            try exerciseRepository.setDebt(key: "pushups", repsOwed: 50, updatedAt: seedDate)
            _ = try workoutRepository.addRepEntry(exerciseKey: "pushups", count: 130, at: seedDate)
        }
        if ProcessInfo.processInfo.arguments.contains("-GMSeedHistoryFixture") {
            let calendar = GMCalendar.calendar
            // Two weeks of climbing activity so the trend charts have data.
            let dailyPushups = [40, 55, 48, 0, 62, 70, 58, 75, 66, 82, 78, 90, 85, 100]
            for (offset, reps) in dailyPushups.enumerated() where reps > 0 {
                let date = calendar.date(byAdding: .day, value: -(dailyPushups.count - 1 - offset), to: seedDate) ?? seedDate
                _ = try workoutRepository.addRepEntry(exerciseKey: "pushups", count: reps, at: date)
                _ = try workoutRepository.addRepEntry(exerciseKey: "squats", count: reps + 20, at: date)
            }
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

extension LocalStore: LocalDataAdmin {
    /// True once the user has logged at least one rep — drives the first-launch
    /// empty state vs. the populated dashboard.
    func hasAnyActivity() throws -> Bool {
        try !workoutRepository.allEntries().isEmpty
    }

    /// Wipes all local data and re-seeds defaults, returning the app to a clean
    /// first-launch state. Local-only, no cloud — safe for beta testing.
    func resetAllLocalData() throws {
        try context.delete(model: RepEntry.self)
        try context.delete(model: RoundPlan.self)
        try context.delete(model: WorkoutDay.self)
        try context.delete(model: DebtBalance.self)
        try context.delete(model: DailyTarget.self)
        try context.delete(model: Exercise.self)
        try context.delete(model: AppSettings.self)
        try context.save()
        try AppDataSeeder.seedIfNeeded(context, today: Date())
    }

    /// A JSON snapshot of all days, logs, debts, targets and balance.
    func exportSnapshotData() throws -> Data {
        let settings = try exerciseRepository.appSettings()
        let entries = try workoutRepository.allEntries()
        let exercises = try exerciseRepository.allOrdered()
        let nameByKey = Dictionary(uniqueKeysWithValues: exercises.map { ($0.key, $0.name) })

        let snapshot = GMExportSnapshot(
            exportedAt: Date(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            repValue: settings.repValue,
            bankBalance: EarningsEngine().totalMoney(for: entries, repValue: settings.repValue),
            entries: entries
                .sorted { $0.timestamp < $1.timestamp }
                .map { .init(date: $0.timestamp, exercise: nameByKey[$0.exerciseKey] ?? $0.exerciseKey, count: $0.count) },
            debts: try exerciseRepository.debtBalances().compactMap { debt in
                guard let key = debt.exercise?.key else { return nil }
                return .init(exercise: nameByKey[key] ?? key, repsOwed: debt.repsOwed)
            },
            targets: exercises.map { .init(exercise: $0.name, reps: exerciseRepository.currentTarget(for: $0, on: Date())) }
        )
        return try snapshot.encoded()
    }
}
