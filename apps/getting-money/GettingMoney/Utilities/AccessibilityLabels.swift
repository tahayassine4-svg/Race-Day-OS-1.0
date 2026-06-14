import Foundation

/// Centralized VoiceOver phrasing so core status/money/debt read naturally and
/// consistently (Packet 08 accessibility pass). The money is an in-app metaphor.
enum GMAccessibility {
    static func money(_ amount: Int) -> String {
        "\(amount) dollars"
    }

    static func debt(reps: Int) -> String {
        reps == 0 ? "No rep debt" : "\(reps) reps owed, repaid in reps not money"
    }

    static func exerciseProgress(name: String, completed: Int, target: Int) -> String {
        "\(name), \(completed) of \(target) reps"
    }

    static func dailyProgress(completed: Int, target: Int) -> String {
        "Daily target, \(completed) of \(target) reps"
    }

    static func status(_ status: GMStatus) -> String {
        "Status: \(status.label)"
    }

    static func streak(days: Int) -> String {
        days == 1 ? "1 day streak" : "\(days) day streak"
    }
}
