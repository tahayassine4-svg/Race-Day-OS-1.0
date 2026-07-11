import Foundation
import Testing

@testable import GettingMoney

/// Covers the presentation-logic added for the Training Bank redesign (Packet 20):
/// the dashboard quick-log breakdown and the Bank screen's derived economy.
@Suite("Packet 20 — Training Bank redesign")
@MainActor
struct TrainingBankRedesignTests {

  private func makeStore(today: Date) throws -> LocalStore {
    let store = try LocalStore(inMemory: true, seedDate: today)
    try store.exerciseRepository.setTarget(
      key: "pushups", reps: 100, effectiveDate: today, isManualOverride: true)
    try store.exerciseRepository.setTarget(
      key: "pullups", reps: 10, effectiveDate: today, isManualOverride: true)
    try store.exerciseRepository.setTarget(
      key: "squats", reps: 150, effectiveDate: today, isManualOverride: true)
    return store
  }

  @Test("logReps toward an unmet target is pure earnings, no debt/bonus")
  func logTowardTarget() throws {
    let today = Date()
    let store = try makeStore(today: today)
    let vm = DashboardViewModel(
      exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
    vm.load(today: today)

    let result = vm.logReps("pushups", 10, today: today)
    #expect(result == DashboardViewModel.LogResult(earned: 10, debtPaid: 0, bonus: 0))
    vm.load(today: today)
    #expect(vm.rows.first { $0.id == "pushups" }?.completed == 10)
  }

  @Test("logReps past target pays live debt first, then banks the surplus as bonus")
  func logPaysDebtThenBonus() throws {
    let today = Date()
    let store = try makeStore(today: today)
    // Already at target with 20 reps of standing debt.
    _ = try store.workoutRepository.addRepEntry(
      exerciseKey: "pushups", count: 100, sourceRoundNumber: nil, at: today)
    try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 20, updatedAt: today)

    let vm = DashboardViewModel(
      exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
    vm.load(today: today)

    // +30 extra reps: 20 clear the debt, 10 become bonus bank.
    let result = vm.logReps("pushups", 30, today: today)
    #expect(result == DashboardViewModel.LogResult(earned: 30, debtPaid: 20, bonus: 10))
  }

  @Test("Bank net balance = earned − outstanding debt for the selected period")
  func bankNetBalance() throws {
    let today = Date()
    let store = try makeStore(today: today)
    _ = try store.workoutRepository.addRepEntry(
      exerciseKey: "pushups", count: 50, sourceRoundNumber: nil, at: today)

    let vm = BankViewModel(
      exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
    vm.setFilter(.today)
    vm.load(today: today)

    #expect(vm.earnedMoney == 50)
    #expect(vm.lostMoney == 0)
    #expect(vm.netMoney == 50)
    #expect(vm.debtFreePercent == 100)
  }

  @Test("Bank surfaces 7 daily bars")
  func bankSevenBars() throws {
    let today = Date()
    let store = try makeStore(today: today)
    _ = try store.workoutRepository.addRepEntry(
      exerciseKey: "squats", count: 40, sourceRoundNumber: nil, at: today)

    let vm = BankViewModel(
      exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
    vm.load(today: today)
    #expect(vm.bars.count == 7)
    #expect(vm.bars.last?.isToday == true)
  }
}
