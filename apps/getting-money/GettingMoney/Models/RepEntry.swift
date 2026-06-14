import Foundation
import SwiftData

/// A logged set of reps for one exercise on one day. References the exercise by
/// its stable `exerciseKey` string (avoids multiple-relationship inverse ambiguity).
@Model
final class RepEntry {
    var timestamp: Date = Date.distantPast
    var exerciseKey: String = ""
    var count: Int = 0
    /// If this entry was logged by ticking off a round, the round's number.
    /// Lets a round's reps be removed again when it's un-ticked (Packet 11).
    var sourceRoundNumber: Int? = nil
    var day: WorkoutDay? = nil

    init(timestamp: Date = Date.distantPast, exerciseKey: String = "",
         count: Int = 0, sourceRoundNumber: Int? = nil, day: WorkoutDay? = nil) {
        self.timestamp = timestamp
        self.exerciseKey = exerciseKey
        self.count = count
        self.sourceRoundNumber = sourceRoundNumber
        self.day = day
    }
}
