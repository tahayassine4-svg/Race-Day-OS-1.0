import Testing
import Foundation
@testable import GettingMoney

@Suite("Packet 08 — history engine")
struct HistoryEngineTests {
    private let engine = HistoryEngine()
    private let cal = GMCalendar.calendar

    private func day(_ offset: Int, from today: Date) -> Date {
        cal.date(byAdding: .day, value: offset, to: cal.startOfDay(for: today))!
    }

    @Test("Daily series produces one point per day in the window")
    func windowLength() {
        let series = engine.dailySeries(from: [], repValue: 1, days: 14, today: Date())
        #expect(series.count == 14)
        #expect(series.allSatisfy { $0.dailyReps == 0 })
    }

    @Test("Reps bucket into their day and cumulative balance accrues")
    func bucketing() {
        let today = Date()
        let entries = [
            RepEntrySnapshot(date: day(-2, from: today), count: 10),
            RepEntrySnapshot(date: day(-2, from: today), count: 5),
            RepEntrySnapshot(date: day(0, from: today), count: 20)
        ]
        let s = engine.dailySeries(from: entries, repValue: 1, days: 3, today: today)
        #expect(s.map(\.dailyReps) == [15, 0, 20])
        #expect(s.map(\.cumulativeMoney) == [15, 15, 35])
    }

    @Test("Entries before the window seed the cumulative baseline")
    func baseline() {
        let today = Date()
        let entries = [
            RepEntrySnapshot(date: day(-30, from: today), count: 100),
            RepEntrySnapshot(date: day(0, from: today), count: 10)
        ]
        let s = engine.dailySeries(from: entries, repValue: 1, days: 3, today: today)
        #expect(s.first?.cumulativeMoney == 100)
        #expect(s.last?.cumulativeMoney == 110)
    }

    @Test("Rep value scales daily money")
    func repValueScales() {
        let today = Date()
        let s = engine.dailySeries(from: [RepEntrySnapshot(date: day(0, from: today), count: 10)], repValue: 2, days: 1, today: today)
        #expect(s.first?.dailyMoney == 20)
    }

    @Test("Streak counts consecutive active days ending today")
    func streak() {
        let today = Date()
        let entries = [
            RepEntrySnapshot(date: day(-4, from: today), count: 5),
            RepEntrySnapshot(date: day(-2, from: today), count: 5),
            RepEntrySnapshot(date: day(-1, from: today), count: 5),
            RepEntrySnapshot(date: day(0, from: today), count: 5)
        ]
        let s = engine.dailySeries(from: entries, repValue: 1, days: 5, today: today)
        #expect(engine.currentStreak(s) == 3)
    }

    @Test("No reps today breaks the streak")
    func brokenStreak() {
        let today = Date()
        let entries = [RepEntrySnapshot(date: day(-1, from: today), count: 5)]
        let s = engine.dailySeries(from: entries, repValue: 1, days: 3, today: today)
        #expect(engine.currentStreak(s) == 0)
    }
}

@Suite("Packet 08 — data utilities")
@MainActor
struct DataUtilitiesTests {
    @Test("Reset wipes activity back to first-launch empty state and re-seeds defaults")
    func resetClears() throws {
        let store = try LocalStore(inMemory: true)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 30, at: Date())
        #expect(try store.hasAnyActivity() == true)

        try store.resetAllLocalData()
        #expect(try store.hasAnyActivity() == false)
        #expect(try !store.exerciseRepository.allOrdered().isEmpty)
    }

    @Test("Export produces decodable JSON with logged entries and balance")
    func exportDecodable() throws {
        let store = try LocalStore(inMemory: true)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 12, at: Date())

        let data = try store.exportSnapshotData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let snap = try decoder.decode(GMExportSnapshot.self, from: data)

        #expect(snap.entries.count == 1)
        #expect(snap.entries.first?.count == 12)
        #expect(snap.bankBalance == 12)
        #expect(!snap.targets.isEmpty)
    }
}

@Suite("Packet 08 — dashboard history")
@MainActor
struct DashboardHistoryTests {
    @Test("Dashboard exposes a 14-day series and activity flag when reps exist")
    func dashboardHistory() throws {
        let store = try LocalStore(inMemory: true)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 20, at: Date())
        let vm = DashboardViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        vm.load()
        #expect(vm.hasActivity == true)
        #expect(vm.history.count == 14)
        #expect(vm.streakDays == 1)
    }

    @Test("Fresh store has no activity → first-launch empty state")
    func firstLaunch() throws {
        let store = try LocalStore(inMemory: true)
        let vm = DashboardViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        vm.load()
        #expect(vm.hasActivity == false)
        #expect(vm.history.count == 14)
    }

    @Test("Dashboard daily selector reloads the selected day's reps and balance")
    func dailySelectorLoadsSelectedDay() throws {
        let today = GMCalendar.dayKey()
        let yesterday = try #require(GMCalendar.calendar.date(byAdding: .day, value: -1, to: today))
        let store = try LocalStore(inMemory: true, seedDate: yesterday)

        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 15, at: yesterday)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 5, at: today)

        let vm = DashboardViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        vm.load(today: today)
        #expect(vm.selectedDate == today)
        #expect(vm.dailyCompleted == 5)
        #expect(vm.bankBalance == 20)

        vm.showPreviousDay()
        #expect(vm.selectedDate == yesterday)
        #expect(vm.dailyCompleted == 15)
        #expect(vm.rows.first { $0.id == "pushups" }?.completed == 15)
        #expect(vm.bankBalance == 15)

        vm.showNextDay()
        #expect(vm.selectedDate == today)
        #expect(vm.dailyCompleted == 5)
        #expect(vm.bankBalance == 20)
    }
}
