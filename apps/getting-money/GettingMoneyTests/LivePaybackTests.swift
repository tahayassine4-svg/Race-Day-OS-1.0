import Testing
import Foundation
@testable import GettingMoney

/// The core loop: extra reps logged TODAY must pay debt down immediately, before
/// the next day-close. Today's *misses* must NOT raise debt live (today stays live).
@Suite("Packet 10 — live debt payback")
@MainActor
struct LivePaybackTests {
    private func makeLogger(_ store: LocalStore) -> RepLoggerViewModel {
        RepLoggerViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
    }

    @Test("Today's surplus reps reduce shown debt immediately on the Dashboard")
    func dashboardLivePayback() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 50, updatedAt: Date())

        let logger = makeLogger(store)
        logger.load()
        logger.adjust("pushups", by: 160) // 100 target + 60 payback
        logger.save()

        let dashboard = DashboardViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        dashboard.load()

        #expect(dashboard.totalDebt == 0)            // 60 surplus repays the 50 debt
        #expect(dashboard.status != .activeDebt)
        #expect(dashboard.rows.first { $0.id == "pushups" }?.debtOwed == 0)
    }

    @Test("Log status pill uses live debt and still matches the Dashboard after a paydown")
    func logStatusUsesLiveDebt() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 50, updatedAt: Date())

        let logger = makeLogger(store)
        logger.load()
        logger.adjust("pushups", by: 160) // 100 target + 60 surplus repays the 50 debt
        logger.save()

        let dashboard = DashboardViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        dashboard.load()

        #expect(logger.status != .activeDebt)          // debt cleared live, not stuck on persisted
        #expect(logger.status == dashboard.status)      // both "Behind" (160 < 260 target)
    }

    @Test("Debt screen + payback plan shrink as today's payback reps are logged")
    func debtScreenShrinksLive() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 50, updatedAt: Date())

        let logger = makeLogger(store)
        logger.load()
        logger.adjust("pushups", by: 130) // 100 target + 30 payback
        logger.save()

        let debt = DebtViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        debt.load()

        #expect(debt.totalDebt == 20) // 30 of the 50 repaid → 20 remains
        #expect(debt.rows.first { $0.id == "pushups" }?.repsOwed == 20)
        #expect(debt.status == .activeDebt)
    }

    @Test("Clearing all debt today flips the Debt screen to Paid off")
    func clearingDebtFlipsToPaidOff() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 50, updatedAt: Date())

        let logger = makeLogger(store)
        logger.load()
        logger.adjust("pushups", by: 200) // 100 target + 100 payback (> 50 debt)
        logger.save()

        let debt = DebtViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        debt.load()

        #expect(debt.totalDebt == 0)
        #expect(debt.rows.isEmpty)
        #expect(debt.status == .paidOff)
    }

    @Test("Being under target today does NOT raise debt live (today stays live)")
    func underTargetNoLiveAccrual() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 50, updatedAt: Date())

        let logger = makeLogger(store)
        logger.load()
        logger.adjust("pushups", by: 40) // under the 100 target → no surplus
        logger.save()

        let dashboard = DashboardViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        dashboard.load()
        let debt = DebtViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        debt.load()

        #expect(dashboard.totalDebt == 50) // unchanged — today's shortfall isn't debt yet
        #expect(debt.totalDebt == 50)
    }

    @Test("Persisted debt is untouched by live payback (day-close still reconciles)")
    func persistedDebtUnchanged() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 50, updatedAt: Date())

        let logger = makeLogger(store)
        logger.load()
        logger.adjust("pushups", by: 200)
        logger.save()

        // Display is live-zero, but the stored balance only changes at day-close.
        let persisted = try store.exerciseRepository.debtBalances().first { $0.exercise?.key == "pushups" }?.repsOwed
        #expect(persisted == 50)
    }
}
