import Testing
import Foundation
@testable import GettingMoney

/// Packet 15 — a workout recorded via BOTH the Log tab (manual) and the Rounds tab
/// (tagged) must count once, not twice. Reconciliation happens at read time:
/// `completed = max(manualSum, roundSum)` per exercise.
@Suite("Packet 15 — rep reconciliation")
@MainActor
struct ReconciliationTests {
    private let cal = GMCalendar.calendar
    private func day(_ offset: Int, from today: Date) -> Date {
        cal.date(byAdding: .day, value: offset, to: today)!
    }
    private func debt(_ store: LocalStore, _ key: String) throws -> Int {
        try store.exerciseRepository.debtBalances().first { $0.exercise?.key == key }?.repsOwed ?? 0
    }
    /// Set the three default targets to the reporter's values for the day.
    private func setTargets(_ store: LocalStore, push: Int, pull: Int, squat: Int, on date: Date) throws {
        try store.exerciseRepository.setTarget(key: "pushups", reps: push, effectiveDate: date, isManualOverride: true)
        try store.exerciseRepository.setTarget(key: "pullups", reps: pull, effectiveDate: date, isManualOverride: true)
        try store.exerciseRepository.setTarget(key: "squats", reps: squat, effectiveDate: date, isManualOverride: true)
    }

    /// The exact bug report: targets 40/25/70, one completed 1-circle round
    /// (40/25/70) AND a manual log (40/10/11). Under the old sum this read 80/35/81;
    /// reconciled it must read the one workout actually done: 40/25/70.
    @Test("Reconstructed report store reads the single workout, not double")
    func reconstructedReportStore() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)
        try setTargets(store, push: 40, pull: 25, squat: 70, on: today)
        // Manual log.
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: nil, at: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pullups", count: 10, sourceRoundNumber: nil, at: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "squats", count: 11, sourceRoundNumber: nil, at: today)
        // Completed round 1 (the full circle).
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: 1, at: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pullups", count: 25, sourceRoundNumber: 1, at: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "squats", count: 70, sourceRoundNumber: 1, at: today)

        let dashboard = DashboardViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        dashboard.load(today: today)

        #expect(dashboard.rows.first { $0.id == "pushups" }?.completed == 40)
        #expect(dashboard.rows.first { $0.id == "pullups" }?.completed == 25)
        #expect(dashboard.rows.first { $0.id == "squats" }?.completed == 70)
        #expect(dashboard.dailyCompleted == 135)   // not 196
    }

    @Test("max combiner is order-independent (manual-first == round-first)")
    func combinerOrderIndependent() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: nil, at: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: 1, at: today)
        #expect(try store.workoutRepository.completedReps(on: today)["pushups"] == 40)
    }

    @Test("Genuine extra reps after a round are kept as a higher total")
    func surplusKept() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)
        // Round of 40, then the user asserts a total of 60 (did 20 extra).
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: 1, at: today)
        try store.workoutRepository.setManualTotals(on: today, totalsByExercise: ["pushups": 60])
        #expect(try store.workoutRepository.completedReps(on: today)["pushups"] == 60)
    }

    @Test("Un-ticking a round after a manual edit loses no reps")
    func untickAfterManualNoLoss() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)
        try store.workoutRepository.setManualTotals(on: today, totalsByExercise: ["pushups": 60])
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: 1, at: today)
        #expect(try store.workoutRepository.completedReps(on: today)["pushups"] == 60)
        // Un-tick round 1.
        try store.workoutRepository.deleteRoundEntries(roundNumber: 1, on: today)
        #expect(try store.workoutRepository.completedReps(on: today)["pushups"] == 60)
    }

    @Test("Log save sets the day total — re-saving never stacks a second copy")
    func logSaveIsIdempotent() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)
        try setTargets(store, push: 40, pull: 25, squat: 70, on: today)
        // A round is already done.
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: 1, at: today)

        let logger = RepLoggerViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        logger.load(today: today)
        #expect(logger.rows.first { $0.id == "pushups" }?.logged == 40)  // shows the round reps
        logger.save()  // no change
        #expect(try store.workoutRepository.completedReps(on: today)["pushups"] == 40)  // still 40, not 80
        logger.save()  // re-save again
        #expect(try store.workoutRepository.completedReps(on: today)["pushups"] == 40)
    }

    @Test("Day-close debt uses the reconciled total, not the doubled sum")
    func dayCloseUsesReconciled() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: day(-10, from: today))
        let yesterday = day(-1, from: today)
        try setTargets(store, push: 100, pull: 10, squat: 150, on: day(-10, from: today))
        // Yesterday: manual 60 + round 60 pushups. Sum=120 (looks like surplus),
        // reconciled=60 → real miss of 40 against the 100 target.
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 60, sourceRoundNumber: nil, at: yesterday)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 60, sourceRoundNumber: 1, at: yesterday)

        try DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run(today: today)

        #expect(try debt(store, "pushups") == 40)   // 100 target − 60 reconciled, not 0
    }

    @Test("Bank balance reflects reconciled reps, not the double count")
    func balanceReconciled() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)
        try setTargets(store, push: 40, pull: 25, squat: 70, on: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: nil, at: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: 1, at: today)

        let dashboard = DashboardViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        dashboard.load(today: today)
        #expect(dashboard.bankBalance == 40)   // repValue 1 × 40 reconciled, not 80
    }

    @Test("resettle recomputes debt from reconciled history; fresh install stays debt-free")
    func resettleHealsAndIsSafe() throws {
        let today = Date()
        // Fresh install: resettle must not fabricate debt.
        let fresh = try LocalStore(inMemory: true, seedDate: today)
        try DayCloseService(
            exerciseRepository: fresh.exerciseRepository,
            workoutRepository: fresh.workoutRepository
        ).resettle(today: today)
        #expect(try debt(fresh, "pushups") == 0)

        // A store whose debt was wrongly settled (manual+round on a missed day).
        let store = try LocalStore(inMemory: true, seedDate: day(-10, from: today))
        try setTargets(store, push: 100, pull: 10, squat: 150, on: day(-10, from: today))
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 60, sourceRoundNumber: nil, at: day(-1, from: today))
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 60, sourceRoundNumber: 1, at: day(-1, from: today))
        // Pretend an old build settled this as zero debt (phantom surplus).
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 0, updatedAt: today)
        try store.exerciseRepository.markDayClosed(through: today)

        try DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).resettle(today: today)
        #expect(try debt(store, "pushups") == 40)   // corrected
    }
}
