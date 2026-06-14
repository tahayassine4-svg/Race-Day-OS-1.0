import Testing
import Foundation
@testable import GettingMoney

@Suite("Packet 03 — target progression")
struct TargetProgressionEngineTests {
    private let engine = TargetProgressionEngine()

    @Test("Default two-week progression increases eligible targets")
    func defaultProgression() throws {
        let last = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 6, day: 1)))
        let today = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 6, day: 15)))

        let result = engine.progressedTarget(for: TargetProgressionInput(
            exerciseKey: "pushups",
            currentReps: 50,
            isManualOverride: false,
            autoProgressionEnabled: true,
            progressionAmount: 5,
            progressionIntervalDays: 14,
            lastProgressionDate: last,
            today: today
        ))

        #expect(result.reps == 55)
        #expect(result.didProgress)
        #expect(result.intervalsApplied == 1)
    }

    @Test("Pull-ups progress unbounded like every other exercise (cap removed)")
    func pullupsProgressUnbounded() throws {
        let last = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 6, day: 1)))
        let today = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 6, day: 15)))

        let result = engine.progressedTarget(for: TargetProgressionInput(
            exerciseKey: "pullups",
            currentReps: 8,
            isManualOverride: false,
            autoProgressionEnabled: true,
            progressionAmount: 5,
            progressionIntervalDays: 14,
            lastProgressionDate: last,
            today: today
        ))

        #expect(result.reps == 13) // 8 + 5, no cap
        #expect(result.didProgress)
    }

    @Test("Auto-progression off never forces a target change")
    func autoOff() throws {
        let last = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 6, day: 1)))
        let today = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 7, day: 1)))

        let result = engine.progressedTarget(for: TargetProgressionInput(
            exerciseKey: "squats",
            currentReps: 100,
            isManualOverride: false,
            autoProgressionEnabled: false,
            progressionAmount: 10,
            progressionIntervalDays: 14,
            lastProgressionDate: last,
            today: today
        ))

        #expect(result.reps == 100)
        #expect(result.didProgress == false)
    }

    @Test("Progression amount is clamped to the configured 5...10 range")
    @MainActor
    func progressionAmountClamped() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setProgressionAmount(20)
        #expect(try store.exerciseRepository.appSettings().progressionAmount == 10)

        try store.exerciseRepository.setProgressionAmount(2)
        #expect(try store.exerciseRepository.appSettings().progressionAmount == 5)
    }

    @Test("Fresh seeding starts the two-week progression clock")
    @MainActor
    func seedingStartsProgressionClock() throws {
        let seedDate = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 6, day: 1)))
        let store = try LocalStore(inMemory: true, seedDate: seedDate)

        #expect(try store.exerciseRepository.appSettings().lastProgressionDate == GMCalendar.dayKey(for: seedDate))
    }
}

@Suite("Packet 03 — target persistence")
@MainActor
struct TargetPersistenceTests {
    @Test("Manual target edit persists")
    func targetEditPersists() throws {
        let url = URL.temporaryDirectory.appending(path: "gm-target-\(UUID().uuidString).store")
        defer {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }

        do {
            let store = try LocalStore(url: url)
            try store.exerciseRepository.setTarget(key: "pushups", reps: 50, effectiveDate: Date(), isManualOverride: true)
        }

        let reopened = try LocalStore(url: url)
        let pushups = try #require(try reopened.exerciseRepository.allOrdered().first { $0.key == "pushups" })
        #expect(reopened.exerciseRepository.currentTarget(for: pushups, on: Date()) == 50)
    }

    @Test("ViewModel applies due auto-progression (pull-ups now uncapped)")
    func viewModelAppliesDueProgression() throws {
        let store = try LocalStore(inMemory: true)
        let last = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 6, day: 1)))
        let today = try #require(GMCalendar.calendar.date(from: DateComponents(year: 2026, month: 6, day: 15)))

        try store.exerciseRepository.setTarget(key: "pullups", reps: 8, effectiveDate: today, isManualOverride: true)
        try store.exerciseRepository.markProgressionRun(on: last)
        try store.exerciseRepository.setProgressionAmount(5)

        let viewModel = SettingsViewModel(repository: store.exerciseRepository)
        viewModel.applyDueProgression(today: today)

        let pullups = try #require(try store.exerciseRepository.allOrdered().first { $0.key == "pullups" })
        #expect(store.exerciseRepository.currentTarget(for: pullups, on: today) == 13) // 8 + 5, no cap
    }
}
