import Foundation
import SwiftData

/// Per-exercise rep debt. Reduced only by reps (never by money), per the core rule.
@Model
final class DebtBalance {
    var repsOwed: Int = 0
    var updatedAt: Date = Date.distantPast
    var exercise: Exercise? = nil

    init(repsOwed: Int = 0, updatedAt: Date = Date.distantPast, exercise: Exercise? = nil) {
        self.repsOwed = repsOwed
        self.updatedAt = updatedAt
        self.exercise = exercise
    }
}
