import Foundation
import WidgetKit

/// Bridges the live SwiftData layer to the widget's App Group snapshot. The app
/// is the single writer; the widget only reads. Always publishes *today* (the
/// widget is a today-at-a-glance view), regardless of which day the dashboard is
/// currently showing.
@MainActor
enum WidgetSnapshotPublisher {
    /// Pure, testable build of today's snapshot from the repositories. Only
    /// enabled exercises are included, so enabling Dips later makes it appear in
    /// the widget with no further code.
    static func buildSnapshot(
        exerciseRepository: any ExerciseRepositoryProtocol,
        workoutRepository: any WorkoutRepositoryProtocol,
        today: Date = Date()
    ) throws -> WidgetSnapshot {
        let dayKey = GMCalendar.dayKey(for: today)
        // Reconciled per-exercise reps (Log + Rounds counted once) so the widget
        // matches the Dashboard.
        let completedByKey = try workoutRepository.completedReps(on: today)

        let exercises = try exerciseRepository.allOrdered()
            .filter(\.isEnabled)
            .map { exercise -> WidgetExercise in
                let completed = completedByKey[exercise.key] ?? 0
                let target = exerciseRepository.currentTarget(for: exercise, on: today)
                return WidgetExercise(
                    key: exercise.key,
                    name: exercise.name,
                    glyph: exercise.glyph,
                    target: target,
                    completed: completed
                )
            }

        return WidgetSnapshot(dayKey: dayKey, exercises: exercises)
    }

    /// Build today's snapshot, write it to the App Group, and ask WidgetKit to
    /// refresh. Best-effort: a build/encode failure must never crash the app.
    static func publish(
        exerciseRepository: any ExerciseRepositoryProtocol,
        workoutRepository: any WorkoutRepositoryProtocol,
        today: Date = Date()
    ) {
        guard let snapshot = try? buildSnapshot(
            exerciseRepository: exerciseRepository,
            workoutRepository: workoutRepository,
            today: today
        ) else { return }
        WidgetShared.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
