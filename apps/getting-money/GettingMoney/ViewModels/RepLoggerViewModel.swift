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
    private(set) var errorMessage: String?
    var feedbackTick = 0

    private var repValue = 1
    private let exerciseRepository: any ExerciseRepositoryProtocol
    private let workoutRepository: any WorkoutRepositoryProtocol
    private let earningsEngine: any EarningsEngineProtocol

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
            let settings = try exerciseRepository.appSettings()
            repValue = settings.repValue
            let entries = try workoutRepository.entries(on: today)
            let grouped = Dictionary(grouping: entries, by: \.exerciseKey)
            let exercises = try exerciseRepository.allOrdered().filter(\.isEnabled)

            rows = exercises.map { exercise in
                let logged = (grouped[exercise.key] ?? []).reduce(0) { $0 + $1.count }
                return Row(
                    id: exercise.key,
                    name: exercise.name,
                    glyph: exercise.glyph,
                    target: exerciseRepository.currentTarget(for: exercise, on: today),
                    logged: logged,
                    draft: preservingDrafts ? rows.first(where: { $0.id == exercise.key })?.draft ?? 0 : 0,
                    quickAdds: exercise.key == "pullups" ? [1, 2, 5] : [5, 10, 20]
                )
            }

            dailyTarget = rows.reduce(0) { $0 + $1.target }
            loggedToday = rows.reduce(0) { $0 + $1.displayed }
            earnedToday = earningsEngine.summary(completedReps: loggedToday, targetReps: dailyTarget, repValue: settings.repValue).earned
            draftTotal = rows.reduce(0) { $0 + $1.draft }
            errorMessage = nil
        } catch {
            rows = []
            errorMessage = "Reps could not load."
        }
    }

    func adjust(_ key: String, by delta: Int) {
        guard let index = rows.firstIndex(where: { $0.id == key }) else { return }
        rows[index].draft = max(0, rows[index].draft + delta)
        recalculateDraftTotals()
        feedbackTick += 1
    }

    func save(today: Date = Date()) {
        do {
            for row in rows where row.draft > 0 {
                _ = try workoutRepository.addRepEntry(exerciseKey: row.id, count: row.draft, at: today)
            }
            load(today: today, preservingDrafts: false)
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
    }
}
