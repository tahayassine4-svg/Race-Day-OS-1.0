import Foundation
import SwiftData

/// Single app-settings record (enforced as a singleton via fetch-or-create).
@Model
final class AppSettings {
    var repValue: Int = 1                  // $ per rep
    var autoProgressionEnabled: Bool = true
    var progressionIntervalDays: Int = 14
    var progressionAmount: Int = 5         // +5..10 per interval
    var pullupCap: Int = 10                // auto-progression cap for pull-ups
    var roundsPreference: Int = 3
    var lastProgressionDate: Date? = nil

    // Packet 09 — debt day-close. `lastSettledDate` is the watermark through which
    // past days have been settled into rep-debt; `debtCapMultiplier` is the 2-day
    // ceiling (debt per exercise can't exceed this × that day's target).
    var lastSettledDate: Date? = nil
    var debtCapMultiplier: Int = 2

    init(lastProgressionDate: Date? = nil) {
        self.lastProgressionDate = lastProgressionDate
    }
}
