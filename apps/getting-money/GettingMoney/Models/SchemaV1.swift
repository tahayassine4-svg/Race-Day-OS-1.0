import Foundation
import SwiftData

/// Versioned schema so future changes (incl. eventual CloudKit) are migratable.
enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [Exercise.self, DailyTarget.self, WorkoutDay.self,
         RepEntry.self, DebtBalance.self, RoundPlan.self, AppSettings.self]
    }
}
