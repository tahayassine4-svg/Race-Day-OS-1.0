import SwiftUI

@Observable
@MainActor
final class GameSessionViewModel {
  // MARK: - Dependencies
  private let workoutRepo: any WorkoutRepositoryProtocol
  private let exerciseRepo: any ExerciseRepositoryProtocol
  private let debtEngine: DebtEngine

  // MARK: - State
  var exercises: [Exercise] = []
  var selectedExercise: Exercise?
  var sessionRepsByExercise: [String: Int] = [:]
  var completedToday: [String: Int] = [:]
  var targetsToday: [String: Int] = [:]
  var earnedCoins: Int = 0
  var debtCoins: Int = 0
  var streakDays: Int = 0

  // MARK: - Private
  private var lastSavedReps: [String: Int] = [:]
  private var debounceTask: Task<Void, Never>?
  private var tapTimestamps: [Date] = []

  init(
    workoutRepo: any WorkoutRepositoryProtocol,
    exerciseRepo: any ExerciseRepositoryProtocol,
    debtEngine: DebtEngine = DebtEngine()
  ) {
    self.workoutRepo = workoutRepo
    self.exerciseRepo = exerciseRepo
    self.debtEngine = debtEngine
  }

  // MARK: - Load

  func load() {
    let all = (try? exerciseRepo.allOrdered()) ?? []
    exercises = all.filter { $0.isEnabled }
    if selectedExercise == nil || !exercises.contains(where: { $0.key == selectedExercise?.key }) {
      selectedExercise = exercises.first
    }
    refreshStats()
  }

  // MARK: - Tap → rep

  @discardableResult
  func tapRep() -> Double {
    guard let ex = selectedExercise else { return 8 }
    sessionRepsByExercise[ex.key, default: 0] += 1

    let now = Date()
    tapTimestamps.append(now)
    tapTimestamps = tapTimestamps.filter { now.timeIntervalSince($0) < 3 }
    let fps = rateToFPS(Double(tapTimestamps.count) / 3.0)

    debounceTask?.cancel()
    debounceTask = Task { @MainActor [weak self] in
      try? await Task.sleep(for: .seconds(1.5))
      guard !Task.isCancelled else { return }
      self?.saveSession()
    }
    return fps
  }

  // MARK: - Switch exercise (flushes pending reps first)

  func switchExercise(_ exercise: Exercise) {
    debounceTask?.cancel()
    saveSession()
    selectedExercise = exercise
  }

  // MARK: - Flush on screen disappear

  func flushSession() {
    debounceTask?.cancel()
    saveSession()
  }

  // MARK: - Private

  private func rateToFPS(_ tapsPerSec: Double) -> Double {
    if tapsPerSec > 3 { return 18 }
    if tapsPerSec > 1 { return 12 }
    return 8
  }

  private func saveSession() {
    let now = Date()
    for (key, total) in sessionRepsByExercise {
      let alreadySaved = lastSavedReps[key, default: 0]
      let delta = total - alreadySaved
      guard delta > 0 else { continue }
      try? workoutRepo.addRepEntry(exerciseKey: key, count: delta, sourceRoundNumber: nil, at: now)
      lastSavedReps[key] = total
    }
    refreshStats()
  }

  private func refreshStats() {
    let today = GMCalendar.dayKey(for: Date())
    let allCompleted = (try? workoutRepo.completedReps(on: today)) ?? [:]
    completedToday = allCompleted

    let dailyTotals = (try? workoutRepo.reconciledDailyReps()) ?? [:]
    streakDays = computeStreak(dailyTotals: dailyTotals, today: today)

    var targets: [String: Int] = [:]
    var totalDebt = 0
    for ex in exercises {
      let target = exerciseRepo.currentTarget(for: ex, on: today)
      targets[ex.key] = target
      let completed = allCompleted[ex.key] ?? 0
      let persisted = ex.debt?.repsOwed ?? 0
      let live = debtEngine.liveDebt(
        key: ex.key,
        targetReps: target,
        completedReps: completed,
        persistedDebt: persisted
      )
      totalDebt += live
    }
    targetsToday = targets
    debtCoins = totalDebt
    earnedCoins = allCompleted.values.reduce(0, +)
  }

  private func computeStreak(dailyTotals: [Date: Int], today: Date) -> Int {
    var streak = 0
    var check = today
    for _ in 0..<366 {
      let key = GMCalendar.dayKey(for: check)
      if (dailyTotals[key] ?? 0) > 0 {
        streak += 1
      } else if streak == 0 && Calendar.current.isDateInToday(check) {
        // Today not yet complete — check yesterday before breaking
      } else {
        break
      }
      check = Calendar.current.date(byAdding: .day, value: -1, to: check) ?? check
    }
    return streak
  }
}
