import Foundation
import SwiftData

/// Seeds default exercises, their first daily targets, debt rows, and app settings.
/// Idempotent via fetch-or-create — running it repeatedly never duplicates data
/// (uniqueness lives here, not in the schema).
enum AppDataSeeder {

    struct Seed {
        let key, name, glyph: String
        let isOptional, isEnabled: Bool
        let target: Int
    }

    static let defaults: [Seed] = [
        Seed(key: "pushups", name: "Push-ups", glyph: "figure.strengthtraining.traditional", isOptional: false, isEnabled: true, target: 100),
        Seed(key: "pullups", name: "Pull-ups", glyph: "figure.play",                          isOptional: false, isEnabled: true, target: 10),
        Seed(key: "squats",  name: "Squats",   glyph: "figure.cross.training",                isOptional: false, isEnabled: true, target: 150),
        Seed(key: "dips",    name: "Dips",     glyph: "figure.dance",                          isOptional: true,  isEnabled: false, target: 30)
    ]

    @MainActor
    static func seedIfNeeded(_ context: ModelContext, today: Date = Date()) throws {
        // Settings singleton.
        if try context.fetch(FetchDescriptor<AppSettings>()).isEmpty {
            context.insert(AppSettings())
        }

        let existing = try context.fetch(FetchDescriptor<Exercise>())
        let existingKeys = Set(existing.map(\.key))
        let dayKey = GMCalendar.dayKey(for: today)

        for (index, seed) in defaults.enumerated() where !existingKeys.contains(seed.key) {
            let exercise = Exercise(key: seed.key, name: seed.name, glyph: seed.glyph,
                                    isOptional: seed.isOptional, isEnabled: seed.isEnabled, sortOrder: index)
            context.insert(exercise)
            context.insert(DailyTarget(effectiveDate: dayKey, reps: seed.target, exercise: exercise))
            context.insert(DebtBalance(repsOwed: 0, updatedAt: dayKey, exercise: exercise))
        }

        try context.save()
    }
}
