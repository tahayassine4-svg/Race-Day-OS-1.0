import Testing
import Foundation
@testable import GettingMoney

@Suite("Packet 07 — payback planner")
struct PaybackPlannerTests {
    private let planner = PaybackPlanner()

    private func debt(_ key: String, _ reps: Int) -> PaybackDebt {
        PaybackDebt(key: key, name: key.capitalized, glyph: "figure", repsOwed: reps)
    }

    // MARK: One go

    @Test("One-go plan asks for the full per-exercise debt in a single day")
    func oneGoSingleExercise() {
        let plan = planner.oneGoPlan(debts: [debt("pushups", 30)])
        #expect(plan.days.count == 1)
        #expect(plan.days[0].allocations == [PaybackAllocation(key: "pushups", name: "Pushups", glyph: "figure", reps: 30)])
        #expect(plan.totalReps == 30)
    }

    @Test("One-go plan keeps each exercise separate (no money, reps only)")
    func oneGoMixedDebt() {
        let plan = planner.oneGoPlan(debts: [debt("pushups", 24), debt("pullups", 2), debt("squats", 10)])
        #expect(plan.days.count == 1)
        #expect(plan.days[0].allocations.map(\.reps) == [24, 2, 10])
        #expect(plan.totalReps == 36)
    }

    @Test("No debt → empty plan")
    func oneGoNoDebt() {
        #expect(planner.oneGoPlan(debts: []).isEmpty)
        #expect(planner.oneGoPlan(debts: [debt("pushups", 0)]).isEmpty)
    }

    // MARK: Finance plan

    @Test("Finance plan spreads each exercise across days, remainder to earliest days")
    func financeSpread() {
        let plan = planner.financePlan(debts: [debt("pushups", 10)], over: 3)
        #expect(plan.days.count == 3)
        #expect(plan.days.map { $0.allocations.first?.reps } == [4, 3, 3])
        #expect(plan.totalReps == 10)
    }

    @Test("Finance plan is exercise-aware — each exercise distributed independently")
    func financeExerciseAware() {
        let plan = planner.financePlan(debts: [debt("pushups", 24), debt("pullups", 2)], over: 3)
        #expect(plan.days.count == 3)
        // pushups 24 → 8/8/8 ; pullups 2 → 1/1/0
        #expect(plan.days[0].allocations.map(\.reps) == [8, 1])
        #expect(plan.days[1].allocations.map(\.reps) == [8, 1])
        #expect(plan.days[2].allocations.map(\.reps) == [8]) // pullups exhausted
        #expect(plan.totalReps == 26)
    }

    @Test("Finance plan total always equals the total debt")
    func financeConserves() {
        let debts = [debt("pushups", 24), debt("pullups", 2), debt("squats", 10)]
        for days in 1...7 {
            #expect(planner.financePlan(debts: debts, over: days).totalReps == 36)
        }
    }

    // MARK: Rounds payoff allocations

    @Test("Full payoff equals every owed rep")
    func payoffFull() {
        let allocs = planner.payoffAllocations(level: .full, debts: [debt("pushups", 24), debt("pullups", 2)])
        #expect(allocs.map(\.reps) == [24, 2])
    }

    @Test("None payoff is empty")
    func payoffNone() {
        #expect(planner.payoffAllocations(level: .none, debts: [debt("pushups", 24)]).isEmpty)
    }

    @Test("Small/medium payoff round up per exercise and never exceed owed")
    func payoffFractions() {
        let debts = [debt("pushups", 24), debt("pullups", 2), debt("squats", 10)]
        // medium ≈ 50%: 12, 1, 5
        #expect(planner.payoffAllocations(level: .medium, debts: debts).map(\.reps) == [12, 1, 5])
        // small ≈ 25%: 6, 1, 3
        #expect(planner.payoffAllocations(level: .small, debts: debts).map(\.reps) == [6, 1, 3])
    }

    @Test("Custom payoff distributes a total proportionally, capped at owed")
    func payoffCustom() {
        let debts = [debt("pushups", 24), debt("pullups", 2), debt("squats", 10)]
        let allocs = planner.payoffAllocations(level: .custom(18), debts: debts)
        #expect(allocs.reduce(0) { $0 + $1.reps } == 18)
        // each capped at owed
        for a in allocs {
            let owed = debts.first { $0.key == a.key }!.repsOwed
            #expect(a.reps <= owed)
        }
    }

    @Test("Custom payoff larger than total debt clamps to total debt")
    func payoffCustomClamped() {
        let debts = [debt("pushups", 24), debt("pullups", 2)]
        let allocs = planner.payoffAllocations(level: .custom(999), debts: debts)
        #expect(allocs.reduce(0) { $0 + $1.reps } == 26)
    }
}

@Suite("Packet 07 — debt view model")
@MainActor
struct DebtPlanViewModelTests {
    @Test("One-go shows a single day; finance spreads over the chosen days, total conserved")
    func modeSwitch() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 30, updatedAt: Date())
        let vm = DebtViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        vm.load()

        vm.selectMode(.oneGo)
        #expect(vm.planDays.count == 1)
        #expect(vm.planDays.first?.repsTotal == 30)

        vm.selectFinanceDays(3)
        #expect(vm.planDays.count == 3)
        #expect(vm.planDays.reduce(0) { $0 + $1.repsTotal } == 30)
    }

    @Test("Paying back debt reduces the remaining plan after reload")
    func repaymentReduces() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 30, updatedAt: Date())
        let vm = DebtViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        vm.load()
        #expect(vm.totalDebt == 30)

        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 10, updatedAt: Date())
        vm.load()
        #expect(vm.totalDebt == 10)
        vm.selectMode(.oneGo)
        #expect(vm.planDays.first?.repsTotal == 10)
    }

    @Test("No debt → no plan and paid-off status")
    func noDebt() throws {
        let store = try LocalStore(inMemory: true)
        let vm = DebtViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
        vm.load()
        #expect(vm.totalDebt == 0)
        #expect(vm.planDays.isEmpty)
    }
}

@Suite("Packet 07 — rounds payoff")
@MainActor
struct RoundsPayoffTests {
    private func makeVM(_ store: LocalStore) -> RoundsViewModel {
        RoundsViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
    }

    @Test("Full payoff folds owed reps into the rounds without counting as bonus money")
    func fullPayoffFolds() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 24, updatedAt: Date())
        let vm = makeVM(store)
        vm.load()
        let baseTotal = vm.plannedTotal

        vm.choosePayoff(.full)
        #expect(vm.payoffReps == 24)
        #expect(vm.plannedTotal == baseTotal + 24)
        #expect(vm.extraReps == 0)
        // payoff is allocated to the matching exercise only
        let pushupPayoff = vm.rounds.reduce(0) { acc, round in
            acc + round.exercises.first { $0.key == "pushups" }!.payoffReps
        }
        #expect(pushupPayoff == 24)
    }

    @Test("Changing round count keeps payoff folded and conserves the planned total")
    func payoffAcrossRoundCounts() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 24, updatedAt: Date())
        let vm = makeVM(store)
        vm.load()
        vm.choosePayoff(.full)
        vm.chooseRoundCount(3)
        let total3 = vm.plannedTotal
        let payoff3 = vm.payoffReps

        vm.chooseRoundCount(5)
        #expect(vm.rounds.count == 5)
        #expect(vm.plannedTotal == total3)
        #expect(vm.payoffReps == payoff3)
    }

    @Test("No debt means payoff stays None")
    func noDebtNoPayoff() throws {
        let store = try LocalStore(inMemory: true)
        let vm = makeVM(store)
        vm.load()
        vm.choosePayoff(.full)
        #expect(vm.payoff == .none)
        #expect(vm.payoffReps == 0)
    }
}
