import Foundation

struct DebtExerciseInput: Equatable, Sendable {
    let key: String
    let targetReps: Int
    let completedReps: Int
    let existingDebt: Int
}

struct DebtSettlement: Equatable, Sendable {
    let key: String
    let targetReps: Int
    let completedReps: Int
    let targetCompleted: Int
    let missedReps: Int
    let debtRepaid: Int
    let debtAfterClose: Int
    let bonusReps: Int

    func earnedMoney(repValue: Int) -> Int {
        (targetCompleted + bonusReps) * max(0, repValue)
    }
}

struct DebtSummary: Equatable, Sendable {
    let settlements: [DebtSettlement]

    var totalDebt: Int { settlements.reduce(0) { $0 + $1.debtAfterClose } }
    var totalMissed: Int { settlements.reduce(0) { $0 + $1.missedReps } }
    var totalRepaid: Int { settlements.reduce(0) { $0 + $1.debtRepaid } }
    var totalBonusReps: Int { settlements.reduce(0) { $0 + $1.bonusReps } }
}

protocol DebtEngineProtocol: Sendable {
    func settleDay(inputs: [DebtExerciseInput]) -> DebtSummary
}

extension DebtEngineProtocol {
    /// Debt remaining for one exercise after today's surplus repayment ONLY.
    /// Today's *misses* are not counted as debt yet — that accrual happens at
    /// day-close (today stays live). So this = persistedDebt − today's repaid,
    /// which is what the Dashboard/Debt/Rounds screens show during the day.
    func liveDebt(key: String, targetReps: Int, completedReps: Int, persistedDebt: Int) -> Int {
        let settlement = settleDay(inputs: [
            DebtExerciseInput(key: key, targetReps: targetReps, completedReps: completedReps, existingDebt: persistedDebt)
        ]).settlements.first
        return max(0, persistedDebt - (settlement?.debtRepaid ?? 0))
    }
}

struct DebtEngine: DebtEngineProtocol {
    func settleDay(inputs: [DebtExerciseInput]) -> DebtSummary {
        DebtSummary(settlements: inputs.map(settle))
    }

    private func settle(_ input: DebtExerciseInput) -> DebtSettlement {
        let target = max(0, input.targetReps)
        let completed = max(0, input.completedReps)
        let existingDebt = max(0, input.existingDebt)
        let targetCompleted = min(completed, target)
        let missed = max(0, target - completed)
        let surplus = max(0, completed - target)
        let repaid = min(surplus, existingDebt)
        let bonus = max(0, surplus - repaid)

        return DebtSettlement(
            key: input.key,
            targetReps: target,
            completedReps: completed,
            targetCompleted: targetCompleted,
            missedReps: missed,
            debtRepaid: repaid,
            debtAfterClose: existingDebt - repaid + missed,
            bonusReps: bonus
        )
    }
}
