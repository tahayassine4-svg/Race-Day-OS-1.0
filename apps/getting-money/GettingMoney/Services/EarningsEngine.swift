import Foundation

struct EarningsSummary: Equatable, Sendable {
    let completedReps: Int
    let targetReps: Int
    let repValue: Int
    let earned: Int
    let targetEarned: Int
    let bonusEarned: Int

    var fraction: Double {
        targetReps == 0 ? 0 : Double(completedReps) / Double(targetReps)
    }
}

protocol EarningsEngineProtocol: Sendable {
    func summary(completedReps: Int, targetReps: Int, repValue: Int) -> EarningsSummary
    func totalMoney(for entries: [RepEntry], repValue: Int) -> Int
}

struct EarningsEngine: EarningsEngineProtocol {
    func summary(completedReps: Int, targetReps: Int, repValue: Int = 1) -> EarningsSummary {
        let completed = max(0, completedReps)
        let target = max(0, targetReps)
        let value = max(0, repValue)
        let targetRepsCompleted = min(completed, target)
        let bonusReps = max(0, completed - target)

        return EarningsSummary(
            completedReps: completed,
            targetReps: target,
            repValue: value,
            earned: completed * value,
            targetEarned: targetRepsCompleted * value,
            bonusEarned: bonusReps * value
        )
    }

    func totalMoney(for entries: [RepEntry], repValue: Int = 1) -> Int {
        entries.reduce(0) { $0 + max(0, $1.count) } * max(0, repValue)
    }
}
