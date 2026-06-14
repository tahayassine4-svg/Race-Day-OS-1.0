import Testing
import Foundation
@testable import GettingMoney

@Suite("Packet 04 — rep logging")
@MainActor
struct RepLoggingTests {
    private let cal = GMCalendar.calendar

    private func day(_ offset: Int, from today: Date) -> Date {
        cal.date(byAdding: .day, value: offset, to: today)!
    }

    private func backdatedStore(today: Date) throws -> LocalStore {
        try LocalStore(inMemory: true, seedDate: day(-20, from: today))
    }

    private func debt(_ store: LocalStore, _ key: String) throws -> Int {
        try store.exerciseRepository.debtBalances().first { $0.exercise?.key == key }?.repsOwed ?? 0
    }

    @Test("Log 10 push-ups updates dashboard progress and persists after reopen")
    func logPersistsAndUpdatesDashboard() throws {
        let url = URL.temporaryDirectory.appending(path: "gm-log-\(UUID().uuidString).store")
        defer {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }

        do {
            let store = try LocalStore(url: url)
            let logger = RepLoggerViewModel(
                exerciseRepository: store.exerciseRepository,
                workoutRepository: store.workoutRepository
            )
            logger.load()
            logger.adjust("pushups", by: 10)
            logger.save()

            let dashboard = DashboardViewModel(
                exerciseRepository: store.exerciseRepository,
                workoutRepository: store.workoutRepository
            )
            dashboard.load()

            #expect(dashboard.rows.first { $0.id == "pushups" }?.completed == 10)
            #expect(dashboard.earnedToday == 10)
        }

        let reopened = try LocalStore(url: url)
        let entries = try reopened.workoutRepository.entries(on: Date())
        #expect(entries.filter { $0.exerciseKey == "pushups" }.reduce(0) { $0 + $1.count } == 10)
    }

    @Test("Dips are hidden when disabled and loggable when enabled")
    func dipsVisibilityFollowsSettings() throws {
        let store = try LocalStore(inMemory: true)
        let logger = RepLoggerViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )

        logger.load()
        #expect(logger.rows.contains { $0.id == "dips" } == false)

        try store.exerciseRepository.setEnabled(key: "dips", true)
        logger.load()
        #expect(logger.rows.contains { $0.id == "dips" })
    }

    @Test("Log status pill reflects real state and matches the dashboard")
    func logStatusMatchesState() throws {
        let store = try LocalStore(inMemory: true)
        // Small, fully-clearable targets so the test can hit the target exactly.
        try store.exerciseRepository.setTarget(key: "pushups", reps: 10, effectiveDate: Date(), isManualOverride: true)
        try store.exerciseRepository.setTarget(key: "pullups", reps: 0, effectiveDate: Date(), isManualOverride: true)
        try store.exerciseRepository.setTarget(key: "squats", reps: 0, effectiveDate: Date(), isManualOverride: true)

        let logger = RepLoggerViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        logger.load()
        // Under target, no debt → behind (NOT a hardcoded "on track").
        #expect(logger.status == .behind)

        // Pending draft that meets the target flips it to profit immediately.
        logger.adjust("pushups", by: 10)
        #expect(logger.status == .profit)

        // Any outstanding debt dominates → active debt, matching the Dashboard.
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 5, updatedAt: Date())
        logger.load()
        #expect(logger.status == .activeDebt)

        let dashboard = DashboardViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        dashboard.load()
        #expect(logger.status == dashboard.status)
    }

    @Test("Over-target reps increase total money and bonus is reported separately")
    func overTargetLoggingCreatesBonus() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setTarget(key: "pushups", reps: 10, effectiveDate: Date(), isManualOverride: true)

        let logger = RepLoggerViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        logger.load()
        logger.adjust("pushups", by: 12)
        logger.save()

        let dashboard = DashboardViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        dashboard.load()

        #expect(dashboard.bankBalance == 12)
        #expect(dashboard.bonusEarnedToday == 2)
    }

    @Test("Past-day corrections replace logged totals and clear matching debt")
    func pastDayCorrectionClearsDebt() throws {
        let today = cal.startOfDay(for: Date())
        let yesterday = day(-1, from: today)
        let store = try backdatedStore(today: today)
        try store.exerciseRepository.markDayClosed(through: yesterday)

        try DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run(today: today)

        #expect(try debt(store, "pushups") == 100)
        #expect(try debt(store, "pullups") == 10)
        #expect(try debt(store, "squats") == 150)

        let logger = RepLoggerViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        logger.load(today: yesterday)
        #expect(logger.isToday == false)
        #expect(logger.hasPendingChanges == false)

        logger.adjust("pushups", by: 100)
        logger.adjust("pullups", by: 10)
        logger.adjust("squats", by: 150)
        #expect(logger.hasPendingChanges)
        logger.save()

        let entries = try store.workoutRepository.entries(on: yesterday)
        let totals = Dictionary(grouping: entries, by: \.exerciseKey)
            .mapValues { $0.reduce(0) { $0 + $1.count } }
        #expect(totals["pushups"] == 100)
        #expect(totals["pullups"] == 10)
        #expect(totals["squats"] == 150)
        #expect(try debt(store, "pushups") == 0)
        #expect(try debt(store, "pullups") == 0)
        #expect(try debt(store, "squats") == 0)
    }

    @Test("Past-day corrections can lower reps and add debt back")
    func pastDayCorrectionCanAddDebt() throws {
        let today = cal.startOfDay(for: Date())
        let yesterday = day(-1, from: today)
        let store = try backdatedStore(today: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 100, at: yesterday)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pullups", count: 10, at: yesterday)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "squats", count: 150, at: yesterday)
        try store.exerciseRepository.markDayClosed(through: yesterday)

        try DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run(today: today)

        #expect(try debt(store, "pushups") == 0)

        let logger = RepLoggerViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        logger.load(today: yesterday)
        logger.adjust("pushups", by: -25)
        logger.save()

        let entries = try store.workoutRepository.entries(on: yesterday)
        let pushTotal = entries
            .filter { $0.exerciseKey == "pushups" }
            .reduce(0) { $0 + $1.count }
        #expect(pushTotal == 75)
        #expect(try debt(store, "pushups") == 25)
        #expect(try debt(store, "pullups") == 0)
        #expect(try debt(store, "squats") == 0)
    }
}
