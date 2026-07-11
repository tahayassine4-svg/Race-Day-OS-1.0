import Foundation

/// Drives the net-new Bank screen (economy overview). Reuses the same engines and
/// repositories as the dashboard — earned money, a 7-day series, rep-flow, and
/// debt-free progress — so its numbers always agree with the rest of the app.
@Observable
@MainActor
final class BankViewModel {
  enum Filter: String, CaseIterable, Identifiable {
    case today, week, all
    var id: String { rawValue }
    var label: String {
      switch self {
      case .today: "Today"
      case .week: "Week"
      case .all: "All time"
      }
    }
  }

  struct Bar: Identifiable {
    let id: Int
    let label: String
    let heightFraction: Double  // 0...1
    let isToday: Bool
  }

  var filter: Filter = .week
  private(set) var netMoney = 0
  private(set) var earnedMoney = 0
  private(set) var lostMoney = 0
  private(set) var bonusMoney = 0
  private(set) var bars: [Bar] = []
  private(set) var debtFreePercent = 100
  private(set) var debtRemaining = 0
  private(set) var errorMessage: String?

  var debtFreeLabel: String {
    debtRemaining == 0 ? "Debt-free!" : "\(debtRemaining.gmDollars) to go"
  }

  // period money derived from the filter
  private var todayEarned = 0
  private var weekEarned = 0
  private var allEarned = 0
  private var repValue = 1

  private let exerciseRepository: any ExerciseRepositoryProtocol
  private let workoutRepository: any WorkoutRepositoryProtocol
  private let historyEngine: any HistoryEngineProtocol
  private let debtEngine: any DebtEngineProtocol

  init(
    exerciseRepository: any ExerciseRepositoryProtocol,
    workoutRepository: any WorkoutRepositoryProtocol,
    historyEngine: any HistoryEngineProtocol = HistoryEngine(),
    debtEngine: any DebtEngineProtocol = DebtEngine()
  ) {
    self.exerciseRepository = exerciseRepository
    self.workoutRepository = workoutRepository
    self.historyEngine = historyEngine
    self.debtEngine = debtEngine
  }

  func setFilter(_ f: Filter) {
    filter = f
    recompute()
  }

  func load(today: Date = Date()) {
    do {
      let settings = try exerciseRepository.appSettings()
      repValue = settings.repValue

      let reconciledByDay = try workoutRepository.reconciledDailyReps()
      let snapshots = reconciledByDay.map { RepEntrySnapshot(date: $0.key, count: $0.value) }
      let series = historyEngine.dailySeries(
        from: snapshots, repValue: repValue, days: 7, today: today)

      // Bars: last 7 days of daily reps, normalized to the tallest.
      let maxReps = max(1, series.map(\.dailyReps).max() ?? 1)
      let symbols = ["S", "M", "T", "W", "T", "F", "S"]
      bars = series.enumerated().map { i, point in
        Bar(
          id: i,
          label: dayLetter(point.date, fallback: symbols[i % symbols.count]),
          heightFraction: Double(point.dailyReps) / Double(maxReps),
          isToday: GMCalendar.dayKey(for: point.date) == GMCalendar.dayKey(for: today))
      }

      // Period earnings.
      let completedByKey = try workoutRepository.completedReps(on: today)
      let todayReps = completedByKey.values.reduce(0, +)
      let weekReps = series.reduce(0) { $0 + $1.dailyReps }
      let allReps = reconciledByDay.values.reduce(0, +)
      todayEarned = todayReps * repValue
      weekEarned = weekReps * repValue
      allEarned = allReps * repValue

      // Bonus (surplus over target) + live debt across enabled exercises.
      var bonusReps = 0
      var totalDebt = 0
      for exercise in try exerciseRepository.allOrdered().filter(\.isEnabled) {
        let target = exerciseRepository.currentTarget(for: exercise, on: today)
        let completed = completedByKey[exercise.key] ?? 0
        bonusReps += max(0, completed - target)
        totalDebt += debtEngine.liveDebt(
          key: exercise.key, targetReps: target, completedReps: completed,
          persistedDebt: exercise.debt?.repsOwed ?? 0)
      }
      bonusMoney = bonusReps * repValue
      debtRemaining = totalDebt * repValue
      // Directional debt-free ring: today's surplus reps as progress toward zero.
      debtFreePercent =
        totalDebt == 0
        ? 100 : max(4, Int((Double(bonusReps) / Double(bonusReps + totalDebt) * 100).rounded()))

      recompute()
      errorMessage = nil
    } catch {
      errorMessage = "Bank could not load."
    }
  }

  private func recompute() {
    switch filter {
    case .today: earnedMoney = todayEarned
    case .week: earnedMoney = weekEarned
    case .all: earnedMoney = allEarned
    }
    lostMoney = debtRemaining
    netMoney = earnedMoney - lostMoney
  }

  private func dayLetter(_ date: Date, fallback: String) -> String {
    let weekday = GMCalendar.calendar.component(.weekday, from: date)  // 1=Sun
    return ["S", "M", "T", "W", "T", "F", "S"][(weekday - 1) % 7]
  }
}
