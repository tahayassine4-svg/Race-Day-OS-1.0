import Foundation
import SwiftData

@MainActor
protocol WorkoutRepositoryProtocol: AnyObject, Sendable {
    func day(for date: Date) throws -> WorkoutDay
    func addRepEntry(exerciseKey: String, count: Int, at timestamp: Date) throws -> RepEntry
    func entries(on date: Date) throws -> [RepEntry]
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

    func addRepEntry(exerciseKey: String, count: Int, at timestamp: Date = Date()) throws -> RepEntry {
        let workoutDay = try day(for: timestamp)
        let entry = RepEntry(timestamp: timestamp, exerciseKey: exerciseKey, count: count, day: workoutDay)
        context.insert(entry)
        try context.save()
        return entry
    }

    func entries(on date: Date = Date()) throws -> [RepEntry] {
        let workoutDay = try day(for: date)
        return (workoutDay.repEntries ?? []).sorted { $0.timestamp < $1.timestamp }
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
