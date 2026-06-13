import Foundation
import SwiftData

/// A dated daily-target record. The "current" target for an exercise is the
/// record with the latest `effectiveDate` on or before today. Keeping history
/// lets Packet 03's progression read and append without losing prior values.
@Model
final class DailyTarget {
    var effectiveDate: Date = Date.distantPast
    var reps: Int = 0
    var isManualOverride: Bool = false
    var exercise: Exercise? = nil

    init(effectiveDate: Date = Date.distantPast, reps: Int = 0,
         isManualOverride: Bool = false, exercise: Exercise? = nil) {
        self.effectiveDate = effectiveDate
        self.reps = reps
        self.isManualOverride = isManualOverride
        self.exercise = exercise
    }
}
