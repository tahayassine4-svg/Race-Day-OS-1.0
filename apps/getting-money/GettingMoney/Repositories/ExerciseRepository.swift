import Foundation
import SwiftData

/// Read/write access to the exercise catalog and its targets. Views never touch
/// `ModelContext` directly — they go through a repository (knowledge/ios-architecture.md).
@MainActor
protocol ExerciseRepositoryProtocol: AnyObject, Sendable {
    func allOrdered() throws -> [Exercise]
    func setEnabled(key: String, _ enabled: Bool) throws
    func appSettings() throws -> AppSettings
    func currentTarget(for exercise: Exercise, on date: Date) -> Int
    func currentTargetRecord(for exercise: Exercise, on date: Date) -> DailyTarget?
    func setTarget(key: String, reps: Int, effectiveDate: Date, isManualOverride: Bool) throws
    func debtBalances() throws -> [DebtBalance]
    func setDebt(key: String, repsOwed: Int, updatedAt: Date) throws
    func applyDebtSettlements(_ settlements: [DebtSettlement], capMultiplier: Int?, updatedAt: Date) throws
    func markDayClosed(through date: Date) throws
    func setAutoProgressionEnabled(_ enabled: Bool) throws
    func setProgressionAmount(_ amount: Int) throws
    func setProgressionIntervalDays(_ days: Int) throws
    func setPullupCap(_ cap: Int) throws
    func markProgressionRun(on date: Date) throws
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

    func appSettings() throws -> AppSettings {
        let descriptor = FetchDescriptor<AppSettings>()
        if let settings = try context.fetch(descriptor).first {
            return settings
        }

        let settings = AppSettings()
        context.insert(settings)
        try context.save()
        return settings
    }

    /// The reps value of the most recent target on or before `date` (0 if none).
    func currentTarget(for exercise: Exercise, on date: Date = Date()) -> Int {
        currentTargetRecord(for: exercise, on: date)?.reps ?? 0
    }

    func currentTargetRecord(for exercise: Exercise, on date: Date = Date()) -> DailyTarget? {
        let key = GMCalendar.dayKey(for: date)
        let applicable = (exercise.targets ?? [])
            .filter { $0.effectiveDate <= key }
            .sorted { $0.effectiveDate > $1.effectiveDate }
        return applicable.first
    }

    func setTarget(key: String, reps: Int, effectiveDate: Date = Date(), isManualOverride: Bool = true) throws {
        guard let exercise = try allOrdered().first(where: { $0.key == key }) else { return }
        let dayKey = GMCalendar.dayKey(for: effectiveDate)

        if let existing = (exercise.targets ?? []).first(where: { $0.effectiveDate == dayKey }) {
            existing.reps = max(0, reps)
            existing.isManualOverride = isManualOverride
        } else {
            context.insert(DailyTarget(
                effectiveDate: dayKey,
                reps: max(0, reps),
                isManualOverride: isManualOverride,
                exercise: exercise
            ))
        }

        try context.save()
    }

    func debtBalances() throws -> [DebtBalance] {
        try allOrdered().compactMap(\.debt)
    }

    func setDebt(key: String, repsOwed: Int, updatedAt: Date = Date()) throws {
        guard let exercise = try allOrdered().first(where: { $0.key == key }) else { return }
        let clamped = max(0, repsOwed)
        if let debt = exercise.debt {
            debt.repsOwed = clamped
            debt.updatedAt = updatedAt
        } else {
            context.insert(DebtBalance(repsOwed: clamped, updatedAt: updatedAt, exercise: exercise))
        }
        try context.save()
    }

    /// Persists each settlement's `debtAfterClose`. When `capMultiplier` is set, an
    /// exercise's debt is clamped to `capMultiplier × that day's target` (the day-close
    /// 2-day ceiling) — but only when the day had a target, so a zero-target day never
    /// wipes legitimately-owed debt.
    func applyDebtSettlements(_ settlements: [DebtSettlement], capMultiplier: Int? = nil, updatedAt: Date = Date()) throws {
        for settlement in settlements {
            var owed = settlement.debtAfterClose
            if let capMultiplier, settlement.targetReps > 0 {
                owed = min(owed, max(1, capMultiplier) * settlement.targetReps)
            }
            try setDebt(key: settlement.key, repsOwed: owed, updatedAt: updatedAt)
        }
    }

    /// Advances the day-close watermark (start-of-day of `date`).
    func markDayClosed(through date: Date) throws {
        let settings = try appSettings()
        settings.lastSettledDate = GMCalendar.dayKey(for: date)
        try context.save()
    }

    func setAutoProgressionEnabled(_ enabled: Bool) throws {
        let settings = try appSettings()
        settings.autoProgressionEnabled = enabled
        try context.save()
    }

    func setProgressionAmount(_ amount: Int) throws {
        let settings = try appSettings()
        settings.progressionAmount = min(max(amount, 5), 10)
        try context.save()
    }

    func setProgressionIntervalDays(_ days: Int) throws {
        let settings = try appSettings()
        settings.progressionIntervalDays = max(1, days)
        try context.save()
    }

    func setPullupCap(_ cap: Int) throws {
        let settings = try appSettings()
        settings.pullupCap = max(1, cap)
        try context.save()
    }

    func markProgressionRun(on date: Date = Date()) throws {
        let settings = try appSettings()
        settings.lastProgressionDate = GMCalendar.dayKey(for: date)
        try context.save()
    }
}
