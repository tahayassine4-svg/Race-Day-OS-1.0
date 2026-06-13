import Testing
import Foundation
@testable import GettingMoney

@Suite("Packet 05 — debt engine")
struct DebtEngineTests {
    private let engine = DebtEngine()

    @Test("Missed reps become per-exercise debt at day close")
    func debtCreation() {
        let summary = engine.settleDay(inputs: [
            DebtExerciseInput(key: "pushups", targetReps: 50, completedReps: 30, existingDebt: 0)
        ])

        #expect(summary.settlements.first?.missedReps == 20)
        #expect(summary.settlements.first?.debtAfterClose == 20)
        #expect(summary.totalDebt == 20)
    }

    @Test("Extra matching reps reduce existing exercise debt before bonus")
    func repaymentViaExtraReps() {
        let result = engine.settleDay(inputs: [
            DebtExerciseInput(key: "pushups", targetReps: 50, completedReps: 60, existingDebt: 25)
        ]).settlements[0]

        #expect(result.debtRepaid == 10)
        #expect(result.debtAfterClose == 15)
        #expect(result.bonusReps == 0)
    }

    @Test("Money has no debt-clearing input")
    func moneyDoesNotPayDebt() {
        let result = engine.settleDay(inputs: [
            DebtExerciseInput(key: "pullups", targetReps: 0, completedReps: 0, existingDebt: 12)
        ]).settlements[0]

        #expect(result.debtAfterClose == 12)
        #expect(result.earnedMoney(repValue: 100) == 0)
    }

    @Test("Priority order is today target, debt, then bonus money")
    func priorityOrder() {
        let result = engine.settleDay(inputs: [
            DebtExerciseInput(key: "squats", targetReps: 50, completedReps: 80, existingDebt: 20)
        ]).settlements[0]

        #expect(result.targetCompleted == 50)
        #expect(result.debtRepaid == 20)
        #expect(result.bonusReps == 10)
        #expect(result.earnedMoney(repValue: 1) == 60)
    }

    @Test("Total debt is the sum of per-exercise debt")
    func totalIsSum() {
        let summary = engine.settleDay(inputs: [
            DebtExerciseInput(key: "pushups", targetReps: 50, completedReps: 30, existingDebt: 5),
            DebtExerciseInput(key: "pullups", targetReps: 10, completedReps: 12, existingDebt: 4),
            DebtExerciseInput(key: "squats", targetReps: 40, completedReps: 40, existingDebt: 0)
        ])

        #expect(summary.totalDebt == 27)
        #expect(summary.totalRepaid == 2)
    }
}

@Suite("Packet 05 — debt persistence and dashboard")
@MainActor
struct DebtViewModelTests {
    @Test("Stored debt drives Debt screen totals and Dashboard active-debt status")
    func storedDebtDrivesViews() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 24, updatedAt: Date())
        try store.exerciseRepository.setDebt(key: "pullups", repsOwed: 2, updatedAt: Date())
        try store.exerciseRepository.setDebt(key: "squats", repsOwed: 10, updatedAt: Date())

        let debtViewModel = DebtViewModel(exerciseRepository: store.exerciseRepository)
        debtViewModel.load()

        #expect(debtViewModel.totalDebt == 36)
        #expect(debtViewModel.rows.map(\.id) == ["pushups", "pullups", "squats"])
        #expect(debtViewModel.planDays.first?.summary == "+8 push · +1 pull · +4 squat")

        let dashboard = DashboardViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
        dashboard.load()

        #expect(dashboard.totalDebt == 36)
        #expect(dashboard.status == .activeDebt)
    }

    @Test("Debt settlements persist per exercise")
    func settlementsPersist() throws {
        let store = try LocalStore(inMemory: true)
        let engine = DebtEngine()
        let settlement = engine.settleDay(inputs: [
            DebtExerciseInput(key: "pushups", targetReps: 50, completedReps: 30, existingDebt: 0)
        ])

        try store.exerciseRepository.applyDebtSettlements(settlement.settlements, updatedAt: Date())

        #expect(try store.exerciseRepository.debtBalances().first { $0.exercise?.key == "pushups" }?.repsOwed == 20)
    }
}
