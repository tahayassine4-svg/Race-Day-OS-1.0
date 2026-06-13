import Testing
import Foundation
import SwiftData
@testable import GettingMoney

@Suite("Packet 02 — persistence & seeding")
@MainActor
struct PersistenceTests {

    @Test("Seeding is idempotent — running it twice never duplicates data")
    func seedingIsIdempotent() throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let ctx = container.mainContext

        try AppDataSeeder.seedIfNeeded(ctx)
        try AppDataSeeder.seedIfNeeded(ctx)   // second run must be a no-op

        let exercises = try ctx.fetch(FetchDescriptor<Exercise>())
        #expect(exercises.count == 4)

        let settings = try ctx.fetch(FetchDescriptor<AppSettings>())
        #expect(settings.count == 1)
    }

    @Test("Defaults: push/pull/squat enabled, dips optional & off")
    func defaultsAreCorrect() throws {
        let container = try Persistence.makeContainer(inMemory: true)
        try AppDataSeeder.seedIfNeeded(container.mainContext)
        let exercises = try container.mainContext.fetch(FetchDescriptor<Exercise>())

        let dips = try #require(exercises.first { $0.key == "dips" })
        #expect(dips.isOptional)
        #expect(dips.isEnabled == false)

        for key in ["pushups", "pullups", "squats"] {
            let ex = try #require(exercises.first { $0.key == key })
            #expect(ex.isEnabled)
        }
    }

    @Test("A changed setting survives container release + reopen (real on-disk store)")
    func settingSurvivesReopen() throws {
        let url = URL.temporaryDirectory.appending(path: "gm-\(UUID().uuidString).store")
        defer {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }

        // First container: seed, enable dips, then let it deinit at end of scope.
        do {
            let c1 = try Persistence.makeContainer(at: url)
            try AppDataSeeder.seedIfNeeded(c1.mainContext)
            try ExerciseRepository(context: c1.mainContext).setEnabled(key: "dips", true)
        }

        // Reopen a brand-new container at the same URL.
        let c2 = try Persistence.makeContainer(at: url)
        let dips = try #require(
            try c2.mainContext.fetch(FetchDescriptor<Exercise>()).first { $0.key == "dips" }
        )
        #expect(dips.isEnabled == true, "dips toggle should have persisted to disk")
    }

    @Test("Workout repository fetch-or-creates days and round-trips reps + rounds")
    func workoutRepositoryRoundTrips() throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let repository = WorkoutRepository(context: container.mainContext)
        let timestamp = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 6, day: 13, hour: 9)))

        _ = try repository.addRepEntry(exerciseKey: "pushups", count: 25, at: timestamp)
        _ = try repository.saveRoundPlan(roundNumber: 1, exerciseKey: "pushups", plannedReps: 25, completedReps: 25, on: timestamp)

        let entries = try repository.entries(on: timestamp)
        let rounds = try repository.roundPlans(on: timestamp)
        let days = try container.mainContext.fetch(FetchDescriptor<WorkoutDay>())

        #expect(days.count == 1)
        #expect(entries.map(\.count) == [25])
        #expect(rounds.map(\.plannedReps) == [25])
    }

    @Test("Settings view model uses repository output and persists the dips toggle")
    func settingsViewModelUsesRepository() throws {
        let store = try LocalStore(inMemory: true)
        let viewModel = SettingsViewModel(repository: store.exerciseRepository)

        viewModel.load()
        #expect(viewModel.rows.count == 4)
        #expect(viewModel.rows.first { $0.id == "dips" }?.isEnabled == false)

        viewModel.setEnabled("dips", true)
        #expect(viewModel.rows.first { $0.id == "dips" }?.isEnabled == true)
    }

    @Test("Schema and views keep SwiftData below the repository layer")
    func schemaAndViewBoundariesAreInPlace() throws {
        #expect(SchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
        #expect(SchemaV1.models.count == 7)
    }
}
