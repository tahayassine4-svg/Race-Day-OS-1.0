import Foundation

@Observable
@MainActor
final class DebtViewModel {
  enum PlanMode: Equatable { case oneGo, finance }

  struct Row: Identifiable {
    let id: String
    let name: String
    let glyph: String
    let repsOwed: Int
  }

  struct PlanDay: Identifiable {
    let id: Int
    let title: String
    let summary: String
    let repsTotal: Int
  }

  private(set) var totalDebt = 0
  private(set) var rows: [Row] = []
  private(set) var planDays: [PlanDay] = []
  private(set) var status: GMStatus = .paidOff
  private(set) var errorMessage: String?

  private(set) var planMode: PlanMode = .finance
  private(set) var financeDays = 3
  let financeDayOptions = [1, 2, 3, 4, 5, 6, 7]

  private let exerciseRepository: any ExerciseRepositoryProtocol
  private let workoutRepository: any WorkoutRepositoryProtocol
  private let planner: any PaybackPlannerProtocol
  private let debtEngine: any DebtEngineProtocol

  init(
    exerciseRepository: any ExerciseRepositoryProtocol,
    workoutRepository: any WorkoutRepositoryProtocol,
    planner: any PaybackPlannerProtocol = PaybackPlanner(),
    debtEngine: any DebtEngineProtocol = DebtEngine()
  ) {
    self.exerciseRepository = exerciseRepository
    self.workoutRepository = workoutRepository
    self.planner = planner
    self.debtEngine = debtEngine
  }

  func load(today: Date = Date()) {
    do {
      // Reconciled per-exercise reps (Log + Rounds counted once).
      let completedByKey = try workoutRepository.completedReps(on: today)
      // Show debt remaining after today's payback reps (live), so the number
      // and the plan shrink as the user logs and hit "Paid off" when cleared.
      rows = try exerciseRepository.allOrdered()
        .filter(\.isEnabled)
        .compactMap { exercise in
          let persisted = exercise.debt?.repsOwed ?? 0
          guard persisted > 0 else { return nil }
          let remaining = debtEngine.liveDebt(
            key: exercise.key,
            targetReps: exerciseRepository.currentTarget(for: exercise, on: today),
            completedReps: completedByKey[exercise.key] ?? 0,
            persistedDebt: persisted
          )
          guard remaining > 0 else { return nil }
          return Row(
            id: exercise.key, name: exercise.name, glyph: exercise.glyph, repsOwed: remaining)
        }
      totalDebt = rows.reduce(0) { $0 + $1.repsOwed }
      status = totalDebt > 0 ? .activeDebt : .paidOff
      recompute()
      errorMessage = nil
    } catch {
      rows = []
      planDays = []
      totalDebt = 0
      status = .paidOff
      errorMessage = "Debt could not load."
    }
  }

  func selectMode(_ mode: PlanMode) {
    planMode = mode
    recompute()
  }

  func selectFinanceDays(_ days: Int) {
    financeDays = days
    planMode = .finance
    recompute()
  }

  private func recompute() {
    guard totalDebt > 0 else {
      planDays = []
      return
    }
    let debts = rows.map {
      PaybackDebt(key: $0.id, name: $0.name, glyph: $0.glyph, repsOwed: $0.repsOwed)
    }
    let plan =
      planMode == .oneGo
      ? planner.oneGoPlan(debts: debts)
      : planner.financePlan(debts: debts, over: financeDays)
    planDays = plan.days.map { day in
      PlanDay(
        id: day.id,
        title: dayTitle(day.id),
        summary: day.allocations.map { "+\($0.reps) \(shortName($0.key))" }.joined(
          separator: " · "),
        repsTotal: day.totalReps
      )
    }
  }

  private func dayTitle(_ id: Int) -> String {
    switch id {
    case 1: "Today"
    case 2: "Tomorrow"
    default: "Day \(id)"
    }
  }

  private func shortName(_ key: String) -> String {
    switch key {
    case "pushups": "push"
    case "pullups": "pull"
    case "squats": "squat"
    case "dips": "dip"
    default: key
    }
  }
}
