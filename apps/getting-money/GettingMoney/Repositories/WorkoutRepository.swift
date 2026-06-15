import Foundation
import SwiftData

@MainActor
protocol WorkoutRepositoryProtocol: AnyObject, Sendable {
    func day(for date: Date) throws -> WorkoutDay
    func addRepEntry(exerciseKey: String, count: Int, sourceRoundNumber: Int?, at timestamp: Date) throws -> RepEntry
    func deleteRoundEntries(roundNumber: Int, on date: Date) throws
    func setManualTotals(on date: Date, totalsByExercise: [String: Int]) throws
    func entries(on date: Date) throws -> [RepEntry]
    func completedReps(on date: Date) throws -> [String: Int]
    func reconciledDailyReps() throws -> [Date: Int]
    func allEntries() throws -> [RepEntry]
    func saveRoundPlan(roundNumber: Int, exerciseKey: String, plannedReps: Int, completedReps: Int, includesDebtPayoff: Bool, on date: Date) throws -> RoundPlan
    func replaceRoundPlans(_ rounds: [PlannedRound], includesDebtPayoff: Bool, on date: Date) throws
    func roundPlans(on date: Date) throws -> [RoundPlan]
}

@MainActor
final class WorkoutRepository: WorkoutRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func day(for date: Date = Date()) throws -> WorkoutDay {
        let dayKey = GMCalendar.dayKey(for: date)
        let descriptor = FetchDescriptor<WorkoutDay>(
            predicate: #Predicate { $0.dayKey == dayKey }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let day = WorkoutDay(dayKey: dayKey)
        context.insert(day)
        try context.save()
        return day
    }

    func addRepEntry(exerciseKey: String, count: Int, sourceRoundNumber: Int? = nil, at timestamp: Date = Date()) throws -> RepEntry {
        let workoutDay = try day(for: timestamp)
        let entry = RepEntry(timestamp: timestamp, exerciseKey: exerciseKey, count: count, sourceRoundNumber: sourceRoundNumber, day: workoutDay)
        context.insert(entry)
        try context.save()
        return entry
    }

    /// Removes the reps logged by ticking off a given round (used when it's un-ticked).
    func deleteRoundEntries(roundNumber: Int, on date: Date = Date()) throws {
        let workoutDay = try day(for: date)
        for entry in (workoutDay.repEntries ?? []) where entry.sourceRoundNumber == roundNumber {
            context.delete(entry)
        }
        try context.save()
    }

    /// Sets the *manual* (hand-logged) total per exercise for a day, replacing any
    /// prior manual entries. Round-tagged entries are left untouched; the counted
    /// daily total is reconciled separately as `max(manual, round)` (see
    /// `RepReconciler`). This is the single write path for the Log tab — today and
    /// past-day corrections alike. The given totals are the user's asserted whole-day
    /// totals, stored verbatim (NOT minus round reps), so genuine extra reps after a
    /// round are preserved as a higher manual total.
    func setManualTotals(on date: Date = Date(), totalsByExercise: [String: Int]) throws {
        let workoutDay = try day(for: date)

        for entry in (workoutDay.repEntries ?? []) where entry.sourceRoundNumber == nil {
            context.delete(entry)
        }

        for (exerciseKey, total) in totalsByExercise where total > 0 {
            context.insert(RepEntry(
                timestamp: GMCalendar.dayKey(for: date),
                exerciseKey: exerciseKey,
                count: total,
                sourceRoundNumber: nil,
                day: workoutDay
            ))
        }

        try context.save()
    }

    func entries(on date: Date = Date()) throws -> [RepEntry] {
        let workoutDay = try day(for: date)
        return (workoutDay.repEntries ?? []).sorted { $0.timestamp < $1.timestamp }
    }

    /// Reconciled completed reps per exercise for a day — `max(manual, round)` per
    /// exercise so the same workout logged via the Log and via Rounds is never
    /// double-counted. Every "reps done today" reader goes through this.
    func completedReps(on date: Date = Date()) throws -> [String: Int] {
        RepReconciler.completedByExercise(try entries(on: date))
    }

    /// Reconciled total reps per day across all days, for history and bank balance
    /// (so money never double-counts the manual/round overlap).
    func reconciledDailyReps() throws -> [Date: Int] {
        Dictionary(grouping: try allEntries()) { GMCalendar.dayKey(for: $0.timestamp) }
            .mapValues { RepReconciler.dailyTotal($0) }
    }

    func allEntries() throws -> [RepEntry] {
        let descriptor = FetchDescriptor<RepEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        return try context.fetch(descriptor)
    }

    func saveRoundPlan(roundNumber: Int, exerciseKey: String, plannedReps: Int, completedReps: Int = 0, includesDebtPayoff: Bool = false, on date: Date = Date()) throws -> RoundPlan {
        let workoutDay = try day(for: date)
        if let existing = (workoutDay.rounds ?? []).first(where: { $0.roundNumber == roundNumber && $0.exerciseKey == exerciseKey }) {
            existing.plannedReps = max(0, plannedReps)
            existing.completedReps = max(0, completedReps)
            existing.includesDebtPayoff = includesDebtPayoff
            try context.save()
            return existing
        }

        let round = RoundPlan(
            roundNumber: roundNumber,
            exerciseKey: exerciseKey,
            plannedReps: max(0, plannedReps),
            completedReps: max(0, completedReps),
            includesDebtPayoff: includesDebtPayoff,
            day: workoutDay
        )
        context.insert(round)
        try context.save()
        return round
    }

    func replaceRoundPlans(_ rounds: [PlannedRound], includesDebtPayoff: Bool = false, on date: Date = Date()) throws {
        let workoutDay = try day(for: date)
        for round in workoutDay.rounds ?? [] {
            context.delete(round)
        }
        for round in rounds {
            for exercise in round.exercises {
                context.insert(RoundPlan(
                    roundNumber: round.id,
                    exerciseKey: exercise.key,
                    plannedReps: exercise.reps,
                    includesDebtPayoff: includesDebtPayoff,
                    day: workoutDay
                ))
            }
        }
        try context.save()
    }

    func roundPlans(on date: Date = Date()) throws -> [RoundPlan] {
        let workoutDay = try day(for: date)
        return (workoutDay.rounds ?? []).sorted {
            if $0.roundNumber == $1.roundNumber {
                return $0.exerciseKey < $1.exerciseKey
            }
            return $0.roundNumber < $1.roundNumber
        }
    }
}
