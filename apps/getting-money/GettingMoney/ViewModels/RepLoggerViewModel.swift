import Foundation

@Observable
@MainActor
final class RepLoggerViewModel {
  struct Row: Identifiable {
    let id: String
    let name: String
    let glyph: String
    let target: Int
    let logged: Int
    var draft: Int
    let quickAdds: [Int]

    var displayed: Int { logged + draft }
    var fraction: Double { target == 0 ? 0 : Double(displayed) / Double(target) }
  }

  private(set) var rows: [Row] = []
  private(set) var dailyTarget = 0
  private(set) var loggedToday = 0
  private(set) var earnedToday = 0
  private(set) var draftTotal = 0
  private(set) var totalDebt = 0
  private(set) var errorMessage: String?
  private(set) var selectedDate: Date = GMCalendar.dayKey()
  var feedbackTick = 0
  var isToday: Bool { selectedDate == GMCalendar.dayKey() }
  var hasPendingChanges: Bool { draftTotal != 0 }
  var selectedDateTitle: String {
    if isToday { return "Today" }
    return selectedDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
  }
  var logEyebrow: String { isToday ? "LOG · TODAY" : "LOG · \(selectedDateTitle.uppercased())" }
  var earnedTitle: String {
    isToday
      ? "EARNED TODAY"
      : "EARNED \(selectedDate.formatted(.dateTime.weekday(.abbreviated)).uppercased())"
  }
  var saveTitle: String { isToday ? "Save reps" : "Save corrections" }
  var saveSubtitle: String {
    guard draftTotal != 0 else { return isToday ? "+0 today" : "no changes" }
    let prefix = draftTotal > 0 ? "+" : "-"
    return "\(prefix)\(abs(draftTotal).gmCoins) \(isToday ? "today" : "change")"
  }

  /// Same three-way rule the Dashboard uses, so the status pill never
  /// contradicts the Dashboard for the same day. Reflects pending drafts too.
  var status: GMStatus {
    if totalDebt > 0 { return .activeDebt }
    if dailyTarget > 0 && loggedToday < dailyTarget { return .behind }
    return .profit
  }

  private var repValue = 1
  private var persistedDebtByKey: [String: Int] = [:]
  private let exerciseRepository: any ExerciseRepositoryProtocol
  private let workoutRepository: any WorkoutRepositoryProtocol
  private let earningsEngine: any EarningsEngineProtocol
  private let debtEngine: any DebtEngineProtocol = DebtEngine()

  init(
    exerciseRepository: any ExerciseRepositoryProtocol,
    workoutRepository: any WorkoutRepositoryProtocol,
    earningsEngine: any EarningsEngineProtocol = EarningsEngine()
  ) {
    self.exerciseRepository = exerciseRepository
    self.workoutRepository = workoutRepository
    self.earningsEngine = earningsEngine
  }

  func load(today: Date = Date(), preservingDrafts: Bool = true) {
    do {
      let nextDate = GMCalendar.dayKey(for: today)
      let canPreserveDrafts = preservingDrafts && nextDate == selectedDate
      selectedDate = nextDate
      let settings = try exerciseRepository.appSettings()
      repValue = settings.repValue
      // Reconciled total per exercise (Log + Rounds counted once, never twice).
      let completedByKey = try workoutRepository.completedReps(on: today)
      let exercises = try exerciseRepository.allOrdered().filter(\.isEnabled)

      rows = exercises.map { exercise in
        let logged = completedByKey[exercise.key] ?? 0
        return Row(
          id: exercise.key,
          name: exercise.name,
          glyph: exercise.glyph,
          target: exerciseRepository.currentTarget(for: exercise, on: today),
          logged: logged,
          draft: canPreserveDrafts ? rows.first(where: { $0.id == exercise.key })?.draft ?? 0 : 0,
          quickAdds: exercise.key == "pullups" ? [1, 2, 5] : [5, 10, 20]
        )
      }

      dailyTarget = rows.reduce(0) { $0 + $1.target }
      loggedToday = rows.reduce(0) { $0 + $1.displayed }
      earnedToday =
        earningsEngine.summary(
          completedReps: loggedToday, targetReps: dailyTarget, repValue: settings.repValue
        ).earned
      draftTotal = rows.reduce(0) { $0 + $1.draft }
      persistedDebtByKey = Dictionary(
        uniqueKeysWithValues: exercises.map { ($0.key, $0.debt?.repsOwed ?? 0) })
      recomputeLiveDebt()
      errorMessage = nil
    } catch {
      rows = []
      errorMessage = "Reps could not load."
    }
  }

  func adjust(_ key: String, by delta: Int) {
    guard let index = rows.firstIndex(where: { $0.id == key }) else { return }
    // The Log edits the day's *total*, so you can adjust up or down — but never
    // below what's already done. (To drop below reps logged by a completed
    // round, un-tick that round in the Rounds tab.)
    let minimumDraft = -rows[index].logged
    rows[index].draft = max(minimumDraft, rows[index].draft + delta)
    recalculateDraftTotals()
    feedbackTick += 1
  }

  /// One save path for today and past days: the Log asserts the whole-day total
  /// per exercise. We store that as the manual total; the counted total is then
  /// `max(manual, round)`, so the same workout logged via Rounds is never added a
  /// second time. Past-day edits also re-settle debt from the change.
  func save() {
    do {
      let previousCompleted = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0.logged) })
      let assertedTotals = Dictionary(
        uniqueKeysWithValues: rows.map { ($0.id, max(0, $0.displayed)) })
      try workoutRepository.setManualTotals(on: selectedDate, totalsByExercise: assertedTotals)

      if selectedDate < GMCalendar.dayKey() {
        // Re-settle against the *reconciled* new totals (which may differ
        // from the asserted manual total when a round covers more).
        let newCompleted = try workoutRepository.completedReps(on: selectedDate)
        try reconcileDebtCorrection(from: previousCompleted, to: newCompleted, on: selectedDate)
      }
      load(today: selectedDate, preservingDrafts: false)
      feedbackTick += 1
    } catch {
      errorMessage = "Reps could not be saved."
    }
  }

  private func recalculateDraftTotals() {
    loggedToday = rows.reduce(0) { $0 + $1.displayed }
    dailyTarget = rows.reduce(0) { $0 + $1.target }
    draftTotal = rows.reduce(0) { $0 + $1.draft }
    earnedToday = loggedToday * repValue
    recomputeLiveDebt()
  }

  /// Live debt across all rows (persisted minus today's surplus repayment, using
  /// displayed reps incl. drafts), so the status pill matches the Dashboard.
  private func recomputeLiveDebt() {
    totalDebt = rows.reduce(0) { sum, row in
      sum
        + debtEngine.liveDebt(
          key: row.id,
          targetReps: row.target,
          completedReps: row.displayed,
          persistedDebt: persistedDebtByKey[row.id] ?? 0
        )
    }
  }

  private func reconcileDebtCorrection(
    from oldTotals: [String: Int], to newTotals: [String: Int], on date: Date
  ) throws {
    guard selectedDate < GMCalendar.dayKey() else { return }
    let settings = try exerciseRepository.appSettings()
    let capMultiplier = max(1, settings.debtCapMultiplier)

    for exercise in try exerciseRepository.allOrdered().filter(\.isEnabled) {
      let target = exerciseRepository.currentTarget(for: exercise, on: date)
      guard target > 0 else { continue }

      let oldCompleted = oldTotals[exercise.key] ?? 0
      let newCompleted = newTotals[exercise.key] ?? 0
      let oldImpact = max(0, target - oldCompleted) - max(0, oldCompleted - target)
      let newImpact = max(0, target - newCompleted) - max(0, newCompleted - target)
      let delta = newImpact - oldImpact
      guard delta != 0 else { continue }

      let currentDebt = exercise.debt?.repsOwed ?? 0
      let adjusted = min(max(0, currentDebt + delta), target * capMultiplier)
      try exerciseRepository.setDebt(key: exercise.key, repsOwed: adjusted, updatedAt: date)
    }
  }
}
