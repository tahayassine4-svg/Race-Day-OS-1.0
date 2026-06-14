import Testing
import Foundation
@testable import GettingMoney

/// Proves the cross-screen live-refresh acceptance path: logging reps on the Log
/// tab and then revisiting another tab (which `AppRootView.onChange(of:selection)`
/// drives by calling `viewModel.load()`) reflects the new state.
@Suite("Packet 07/08 — cross-screen live refresh")
@MainActor
struct CrossScreenRefreshTests {
    @Test("Logging reps then revisiting Dashboard updates balance and flips empty → populated")
    func dashboardReflectsNewReps() throws {
        let store = try LocalStore(inMemory: true)
        let dashboard = DashboardViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        dashboard.load()
        #expect(dashboard.hasActivity == false)
        #expect(dashboard.bankBalance == 0)

        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 25, at: Date())

        dashboard.load() // what onChange(of: selection) → reload(.dashboard) performs
        #expect(dashboard.hasActivity == true)
        #expect(dashboard.bankBalance == 25)
        #expect(dashboard.streakDays == 1)
    }

    @Test("Revisiting Debt after debt changes recomputes the payback plan")
    func debtReflectsChange() throws {
        let store = try LocalStore(inMemory: true)
        let debt = DebtViewModel(exerciseRepository: store.exerciseRepository)
        debt.load()
        #expect(debt.totalDebt == 0)
        #expect(debt.planDays.isEmpty)

        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 18, updatedAt: Date())

        debt.load() // tab revisit
        #expect(debt.totalDebt == 18)
        debt.selectMode(.oneGo)
        #expect(debt.planDays.first?.repsTotal == 18)
    }

    @Test("Revisiting Rounds after debt changes lets the payoff fold the owed reps")
    func roundsReflectsDebt() throws {
        let store = try LocalStore(inMemory: true)
        let rounds = RoundsViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        rounds.load()
        #expect(rounds.hasDebt == false)

        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 18, updatedAt: Date())

        rounds.load() // tab revisit
        #expect(rounds.hasDebt == true)
        rounds.choosePayoff(.full)
        #expect(rounds.payoffReps == 18)
    }

    @Test("Requested payoff survives the tab-switch reload over an already-saved plain plan")
    func requestedPayoffSurvivesReload() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 24, updatedAt: Date())
        let rounds = RoundsViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        rounds.load()
        rounds.save() // a plain plan (no payoff) is now saved for today

        // Debt screen "Add payoff to today's rounds": request, then the reload
        // that AppRootView.onChange(of: selection) performs on tab switch.
        rounds.requestPayoff(.full)
        rounds.load()

        #expect(rounds.payoff == .full)
        #expect(rounds.payoffReps == 24)
    }
}
