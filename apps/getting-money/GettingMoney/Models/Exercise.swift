import Foundation
import SwiftData

/// The exercise catalog. Identified by a stable `key` (used for fetch-or-create,
/// since CloudKit-compatible models cannot use unique constraints).
@Model
final class Exercise {
    var key: String = ""          // "pushups" | "pullups" | "squats" | "dips"
    var name: String = ""
    var glyph: String = ""        // SF Symbol name
    var isOptional: Bool = false
    var isEnabled: Bool = true
    var sortOrder: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \DailyTarget.exercise)
    var targets: [DailyTarget]? = []

    @Relationship(deleteRule: .cascade, inverse: \DebtBalance.exercise)
    var debt: DebtBalance? = nil

    init(key: String = "", name: String = "", glyph: String = "",
         isOptional: Bool = false, isEnabled: Bool = true, sortOrder: Int = 0) {
        self.key = key
        self.name = name
        self.glyph = glyph
        self.isOptional = isOptional
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
    }
}
