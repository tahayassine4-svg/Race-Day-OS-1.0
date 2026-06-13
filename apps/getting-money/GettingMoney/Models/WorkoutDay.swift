import Foundation
import SwiftData

/// One training day, keyed by a normalized start-of-day date for deterministic
/// day-boundary logic (streaks, day-close debt). Use `GMCalendar.dayKey(for:)`.
@Model
final class WorkoutDay {
    var dayKey: Date = Date.distantPast

    @Relationship(deleteRule: .cascade, inverse: \RepEntry.day)
    var repEntries: [RepEntry]? = []

    @Relationship(deleteRule: .cascade, inverse: \RoundPlan.day)
    var rounds: [RoundPlan]? = []

    init(dayKey: Date = Date.distantPast) {
        self.dayKey = dayKey
    }
}
