import Foundation

struct TargetProgressionInput: Sendable {
    let exerciseKey: String
    let currentReps: Int
    let isManualOverride: Bool
    let autoProgressionEnabled: Bool
    let progressionAmount: Int
    let progressionIntervalDays: Int
    let lastProgressionDate: Date?
    let today: Date
}

struct TargetProgressionResult: Equatable, Sendable {
    let reps: Int
    let didProgress: Bool
    let intervalsApplied: Int
}

protocol TargetProgressionEngineProtocol: Sendable {
    func progressedTarget(for input: TargetProgressionInput) -> TargetProgressionResult
    func daysUntilNextProgression(lastProgressionDate: Date?, intervalDays: Int, today: Date) -> Int
}

struct TargetProgressionEngine: TargetProgressionEngineProtocol {
    func progressedTarget(for input: TargetProgressionInput) -> TargetProgressionResult {
        guard input.autoProgressionEnabled else {
            return TargetProgressionResult(reps: input.currentReps, didProgress: false, intervalsApplied: 0)
        }

        let intervalDays = max(1, input.progressionIntervalDays)
        let amount = min(max(input.progressionAmount, 5), 10)
        let lastDate = input.lastProgressionDate ?? input.today
        let elapsedDays = max(0, GMCalendar.calendar.dateComponents(
            [.day],
            from: GMCalendar.dayKey(for: lastDate),
            to: GMCalendar.dayKey(for: input.today)
        ).day ?? 0)
        let intervals = elapsedDays / intervalDays

        guard intervals > 0 else {
            return TargetProgressionResult(reps: input.currentReps, didProgress: false, intervalsApplied: 0)
        }

        let rawTarget = input.currentReps + (amount * intervals)
        return TargetProgressionResult(reps: rawTarget, didProgress: true, intervalsApplied: intervals)
    }

    func daysUntilNextProgression(lastProgressionDate: Date?, intervalDays: Int, today: Date) -> Int {
        let intervalDays = max(1, intervalDays)
        guard let lastProgressionDate else { return intervalDays }

        let elapsedDays = max(0, GMCalendar.calendar.dateComponents(
            [.day],
            from: GMCalendar.dayKey(for: lastProgressionDate),
            to: GMCalendar.dayKey(for: today)
        ).day ?? 0)
        let remaining = intervalDays - (elapsedDays % intervalDays)
        return remaining == 0 ? intervalDays : remaining
    }
}
