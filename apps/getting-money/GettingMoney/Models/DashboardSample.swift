import Foundation

/// Plain value types for Packet 01 placeholder UI only.
/// Real persistence (SwiftData) + engines arrive in Packet 02+.
struct ExerciseProgressSample: Identifiable {
    let id = UUID()
    let name: String
    let glyph: String
    let completed: Int
    let target: Int
    let repsOwed: Int          // 0 = no debt on this exercise

    var fraction: Double { target == 0 ? 0 : Double(completed) / Double(target) }
    var remaining: Int { max(0, target - completed) }
}

struct DashboardSample {
    let bankBalance: Int
    let earnedToday: Int
    let streakDays: Int
    let dailyCompleted: Int
    let dailyTarget: Int
    let repDebtValue: Int
    let repDebtReps: Int
    let status: GMStatus
    let exercises: [ExerciseProgressSample]

    var dailyFraction: Double { dailyTarget == 0 ? 0 : Double(dailyCompleted) / Double(dailyTarget) }
    var hasDebt: Bool { repDebtReps > 0 }

    /// Matches the approved design/packet-01.png.
    static let preview = DashboardSample(
        bankBalance: 1284,
        earnedToday: 284,
        streakDays: 12,
        dailyCompleted: 284,
        dailyTarget: 320,
        repDebtValue: 36,
        repDebtReps: 36,
        status: .onTrack,
        exercises: [
            ExerciseProgressSample(name: "Push-ups", glyph: "figure.strengthtraining.traditional", completed: 76, target: 100, repsOwed: 0),
            ExerciseProgressSample(name: "Pull-ups", glyph: "figure.play", completed: 8, target: 10, repsOwed: 2),
            ExerciseProgressSample(name: "Squats", glyph: "figure.cross.training", completed: 140, target: 150, repsOwed: 0)
        ]
    )
}
