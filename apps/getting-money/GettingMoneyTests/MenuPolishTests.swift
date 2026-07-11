import Foundation
import Testing

@testable import GettingMoney

/// Packet 21 — main menu polish: the reset wiring (Targets danger zone →
/// SettingsViewModel → LocalStore) and the splash gating policy.
@Suite("Packet 21 — menu polish")
@MainActor
struct MenuPolishTests {

  // MARK: Reset all reps

  @Test("resetAllData wipes reps, debt and plans, and re-seeds defaults")
  func resetWipesEverything() throws {
    let today = Date()
    let store = try LocalStore(inMemory: true, seedDate: today)
    _ = try store.workoutRepository.addRepEntry(
      exerciseKey: "pushups", count: 40, sourceRoundNumber: nil, at: today)
    _ = try store.workoutRepository.addRepEntry(
      exerciseKey: "squats", count: 20, sourceRoundNumber: 1, at: today)
    try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 30, updatedAt: today)

    let settingsVM = SettingsViewModel(
      repository: store.exerciseRepository, dataAdmin: store)
    settingsVM.resetAllData()

    #expect(try store.workoutRepository.allEntries().isEmpty)
    #expect(try store.exerciseRepository.debtBalances().allSatisfy { $0.repsOwed == 0 })
    #expect(try store.workoutRepository.roundPlans(on: today).isEmpty)
    // Defaults re-seeded: the exercise catalog is back and usable.
    #expect(try !store.exerciseRepository.allOrdered().isEmpty)
    #expect(settingsVM.errorMessage == nil)
  }

  @Test("after reset the dashboard reads a zeroed bank")
  func resetZeroesDashboard() throws {
    let today = Date()
    let store = try LocalStore(inMemory: true, seedDate: today)
    _ = try store.workoutRepository.addRepEntry(
      exerciseKey: "pushups", count: 60, sourceRoundNumber: nil, at: today)
    try store.exerciseRepository.setDebt(key: "pullups", repsOwed: 5, updatedAt: today)

    let dashboard = DashboardViewModel(
      exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
    dashboard.load(today: today)
    #expect(dashboard.bankBalance > 0)
    #expect(dashboard.totalDebt > 0)

    let settingsVM = SettingsViewModel(
      repository: store.exerciseRepository, dataAdmin: store)
    settingsVM.resetAllData()
    dashboard.load(today: today)

    #expect(dashboard.bankBalance == 0)
    #expect(dashboard.totalDebt == 0)
    #expect(dashboard.dailyCompleted == 0)
  }

  // MARK: Splash gating

  @Test("splash shows on a plain cold launch")
  func splashShowsByDefault() {
    #expect(SplashPolicy.shouldShow(arguments: ["/path/to/app"]))
  }

  @Test(
    "splash is skipped for automated launches",
    arguments: [
      ["-GMSkipSplash"],
      ["-GMInitialScreen", "rounds"],
      ["-GMSkipSplash", "-GMSeedDebtFixture"],
    ])
  func splashSkipsAutomation(args: [String]) {
    #expect(!SplashPolicy.shouldShow(arguments: ["/path/to/app"] + args))
  }
}
