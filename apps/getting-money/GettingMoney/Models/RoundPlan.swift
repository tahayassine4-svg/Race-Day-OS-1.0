import Foundation
import SwiftData

/// A planned round/circle for a day: per-exercise split, with optional debt payoff.
@Model
final class RoundPlan {
    var roundNumber: Int = 0
    var exerciseKey: String = ""
    var plannedReps: Int = 0
    var completedReps: Int = 0
    var includesDebtPayoff: Bool = false
    var day: WorkoutDay? = nil

    init(roundNumber: Int = 0, exerciseKey: String = "", plannedReps: Int = 0,
         completedReps: Int = 0, includesDebtPayoff: Bool = false, day: WorkoutDay? = nil) {
        self.roundNumber = roundNumber
        self.exerciseKey = exerciseKey
        self.plannedReps = plannedReps
        self.completedReps = completedReps
        self.includesDebtPayoff = includesDebtPayoff
        self.day = day
    }
}
