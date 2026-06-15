import Foundation

/// The single source of truth for "how many reps were done" on a given day.
///
/// A workout can be recorded two ways — manually in the Log tab (entries with no
/// `sourceRoundNumber`) and by ticking off circles in the Rounds tab (entries
/// tagged with their round number). These are two *views of the same physical
/// reps*, not two separate efforts, so they must never be summed. The day's total
/// per exercise is the GREATER of the two:
///
///     completed = max(manualSum, roundSum)
///
/// This reconciles entirely at read time: stored entries are untouched, so the
/// fix auto-heals already-double-counted data and un-ticking a round simply lets
/// the max recompute. To record genuine *extra* reps after a round, the Log sets
/// the manual total higher than the round total (see `RepLoggerViewModel`).
enum RepReconciler {
    static func reconcile(manual: Int, round: Int) -> Int { max(max(0, manual), max(0, round)) }

    /// Reconciled completed reps per exercise key for entries already scoped to
    /// one day.
    static func completedByExercise(_ entries: [RepEntry]) -> [String: Int] {
        var manual: [String: Int] = [:]
        var round: [String: Int] = [:]
        for entry in entries {
            if entry.sourceRoundNumber == nil {
                manual[entry.exerciseKey, default: 0] += entry.count
            } else {
                round[entry.exerciseKey, default: 0] += entry.count
            }
        }
        var result: [String: Int] = [:]
        for key in Set(manual.keys).union(round.keys) {
            result[key] = reconcile(manual: manual[key] ?? 0, round: round[key] ?? 0)
        }
        return result
    }

    /// Reconciled total reps across all exercises for one day's entries.
    static func dailyTotal(_ entries: [RepEntry]) -> Int {
        completedByExercise(entries).values.reduce(0, +)
    }
}
