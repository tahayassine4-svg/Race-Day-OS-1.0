import Testing
import Foundation
@testable import GettingMoney

@Suite("Packet 09 — debt day-close")
@MainActor
struct DayCloseTests {
    private let cal = GMCalendar.calendar

    private func day(_ offset: Int, from today: Date) -> Date {
        cal.date(byAdding: .day, value: offset, to: today)!
    }

    private func debt(_ store: LocalStore, _ key: String) throws -> Int {
        try store.exerciseRepository.debtBalances().first { $0.exercise?.key == key }?.repsOwed ?? 0
    }

    /// Store whose seeded targets are effective well before the test window, so
    /// past days actually have targets (push 100 / pull 10 / squat 150).
    private func backdatedStore(today: Date) throws -> LocalStore {
        try LocalStore(inMemory: true, seedDate: day(-20, from: today))
    }

    @Test("A single missed past day creates debt equal to the missed reps")
    func singleMissedDay() throws {
        let today = cal.startOfDay(for: Date())
        let store = try backdatedStore(today: today)
        try store.exerciseRepository.markDayClosed(through: day(-1, from: today))

        let settled = try DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run(today: today)

        #expect(settled == 1)
        #expect(try debt(store, "pushups") == 100)
        #expect(try debt(store, "pullups") == 10)
        #expect(try debt(store, "squats") == 150)
    }

    @Test("A long absence is capped at the 2-day ceiling per exercise")
    func multiDayAbsenceCapped() throws {
        let today = cal.startOfDay(for: Date())
        let store = try backdatedStore(today: today)
        try store.exerciseRepository.markDayClosed(through: day(-5, from: today))

        let settled = try DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run(today: today)

        #expect(settled == 5)
        // 5 fully-missed days would be 5× target uncapped; the ceiling clamps to 2×.
        #expect(try debt(store, "pushups") == 200)
        #expect(try debt(store, "pullups") == 20)
        #expect(try debt(store, "squats") == 300)
    }

    @Test("A later surplus day repays earlier debt (chronological settlement)")
    func surplusRepaysEarlierDebt() throws {
        let today = cal.startOfDay(for: Date())
        let store = try backdatedStore(today: today)
        try store.exerciseRepository.markDayClosed(through: day(-2, from: today))
        // Two days ago: missed push-ups → debt. Yesterday: doubled the target → surplus.
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 200, at: day(-1, from: today))

        try DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run(today: today)

        // day-2 made 100 push debt; day-1's +100 surplus paid it back to zero.
        #expect(try debt(store, "pushups") == 0)
        // Squats had no surplus → two missed days, capped at 2× target.
        #expect(try debt(store, "squats") == 300)
    }

    @Test("Today is never settled — only completed past days are")
    func todayStaysLive() throws {
        let today = cal.startOfDay(for: Date())
        let store = try backdatedStore(today: today)
        try store.exerciseRepository.markDayClosed(through: day(-1, from: today))

        let settled = try DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run(today: today)

        // Only yesterday settled (1 day = 1× target). If today were wrongly counted,
        // push debt would be 200.
        #expect(settled == 1)
        #expect(try debt(store, "pushups") == 100)
    }

    @Test("First launch sets the watermark and creates no debt")
    func firstLaunchCreatesNoDebt() throws {
        let today = cal.startOfDay(for: Date())
        let store = try LocalStore(inMemory: true) // lastSettledDate defaults to nil

        let settled = try DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run(today: today)

        #expect(settled == 0)
        #expect(try debt(store, "pushups") == 0)
        #expect(try store.exerciseRepository.appSettings().lastSettledDate == today)
    }

    @Test("Re-running on the same day settles nothing (idempotent)")
    func idempotentSameDay() throws {
        let today = cal.startOfDay(for: Date())
        let store = try backdatedStore(today: today)
        try store.exerciseRepository.markDayClosed(through: day(-1, from: today))
        let service = DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )

        #expect(try service.run(today: today) == 1)
        #expect(try debt(store, "pushups") == 100)
        #expect(try service.run(today: today) == 0) // already settled through today
        #expect(try debt(store, "pushups") == 100)
    }

    @Test("New AppSettings fields survive a real on-disk reopen with clean defaults")
    func newFieldsSurviveReopen() throws {
        let url = URL.temporaryDirectory.appending(path: "gm-dayclose-\(UUID().uuidString).store")
        defer {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }

        do {
            let store = try LocalStore(url: url)
            try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 7, updatedAt: Date())
            try store.exerciseRepository.markDayClosed(through: Date())
        }

        let reopened = try LocalStore(url: url)
        let settings = try reopened.exerciseRepository.appSettings()
        #expect(settings.debtCapMultiplier == 2)   // additive field defaults cleanly
        #expect(settings.lastSettledDate != nil)    // persisted across reopen
        #expect(try debt(reopened, "pushups") == 7) // pre-existing data survives
    }
}
