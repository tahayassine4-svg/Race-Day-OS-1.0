import Foundation
import SwiftData

/// A logged set of reps for one exercise on one day. References the exercise by
/// its stable `exerciseKey` string (avoids multiple-relationship inverse ambiguity).
@Model
final class RepEntry {
    var timestamp: Date = Date.distantPast
    var exerciseKey: String = ""
    var count: Int = 0
    var day: WorkoutDay? = nil

    init(timestamp: Date = Date.distantPast, exerciseKey: String = "",
         count: Int = 0, day: WorkoutDay? = nil) {
        self.timestamp = timestamp
        self.exerciseKey = exerciseKey
        self.count = count
        self.day = day
    }
}
