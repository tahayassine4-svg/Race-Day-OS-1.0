import Foundation

/// A single exercise's outstanding rep debt, fed into the planner.
struct PaybackDebt: Equatable, Sendable {
    let key: String
    let name: String
    let glyph: String
    let repsOwed: Int
}

/// Reps allocated to one exercise within a payback day (or a rounds payoff).
struct PaybackAllocation: Equatable, Identifiable, Sendable {
    let key: String
    let name: String
    let glyph: String
    let reps: Int

    var id: String { key }
}

/// One day of a payback plan: per-exercise reps to pay back that day.
struct PaybackDay: Equatable, Identifiable, Sendable {
    let id: Int
    let allocations: [PaybackAllocation]

    var totalReps: Int { allocations.reduce(0) { $0 + $1.reps } }
}

/// A full payback plan — one day (pay-in-one-go) or several (finance plan).
struct PaybackPlan: Equatable, Sendable {
    let days: [PaybackDay]

    var totalReps: Int { days.reduce(0) { $0 + $1.totalReps } }
    var isEmpty: Bool { days.allSatisfy { $0.totalReps == 0 } }
}

/// How much of the outstanding debt to fold into today's rounds.
enum PayoffLevel: Equatable, Sendable {
    case none
    case small   // ~25%, rounded up per exercise
    case medium  // ~50%, rounded up per exercise
    case full    // everything owed
    case custom(Int) // an exact total, distributed proportionally across exercises
}

protocol PaybackPlannerProtocol: Sendable {
    func oneGoPlan(debts: [PaybackDebt]) -> PaybackPlan
    func financePlan(debts: [PaybackDebt], over days: Int) -> PaybackPlan
    func payoffAllocations(level: PayoffLevel, debts: [PaybackDebt]) -> [PaybackAllocation]
}

/// Pure, exercise-aware debt repayment planner.
///
/// Debt is ALWAYS repaid in reps, never money. Two strategies:
/// - `oneGoPlan`: clear the whole debt today, per exercise.
/// - `financePlan(over:)`: spread each exercise's debt across D days, with the
///   remainder assigned to the earliest days (same convention as `RoundPlanner`).
struct PaybackPlanner: PaybackPlannerProtocol {

    // MARK: One go

    func oneGoPlan(debts: [PaybackDebt]) -> PaybackPlan {
        let allocations = owedAllocations(from: debts)
        guard !allocations.isEmpty else { return PaybackPlan(days: []) }
        return PaybackPlan(days: [PaybackDay(id: 1, allocations: allocations)])
    }

    // MARK: Finance plan

    func financePlan(debts: [PaybackDebt], over days: Int) -> PaybackPlan {
        let owed = debts.filter { $0.repsOwed > 0 }
        guard !owed.isEmpty else { return PaybackPlan(days: []) }
        let dayCount = max(1, days)

        // Per exercise, split its debt across the days (remainder to earliest days).
        let splitByExercise: [(PaybackDebt, [Int])] = owed.map { debt in
            (debt, split(debt.repsOwed, over: dayCount))
        }

        let planDays = (0..<dayCount).map { dayIndex in
            let allocations = splitByExercise.compactMap { debt, parts -> PaybackAllocation? in
                let reps = parts[dayIndex]
                guard reps > 0 else { return nil }
                return PaybackAllocation(key: debt.key, name: debt.name, glyph: debt.glyph, reps: reps)
            }
            return PaybackDay(id: dayIndex + 1, allocations: allocations)
        }
        // Drop trailing empty days (can happen when days > total debt for some splits).
        let trimmed = planDays.filter { $0.totalReps > 0 }
        return PaybackPlan(days: trimmed)
    }

    // MARK: Rounds payoff

    func payoffAllocations(level: PayoffLevel, debts: [PaybackDebt]) -> [PaybackAllocation] {
        let owed = debts.filter { $0.repsOwed > 0 }
        guard !owed.isEmpty else { return [] }

        switch level {
        case .none:
            return []
        case .full:
            return owedAllocations(from: owed)
        case .small:
            return fractionalAllocations(of: owed, fraction: 0.25)
        case .medium:
            return fractionalAllocations(of: owed, fraction: 0.5)
        case .custom(let total):
            return proportionalAllocations(of: owed, total: total)
        }
    }

    // MARK: Helpers

    /// Splits `amount` across `parts`, assigning the remainder to the earliest parts.
    private func split(_ amount: Int, over parts: Int) -> [Int] {
        let count = max(1, parts)
        let reps = max(0, amount)
        let base = reps / count
        let remainder = reps % count
        return (0..<count).map { base + ($0 < remainder ? 1 : 0) }
    }

    private func owedAllocations(from debts: [PaybackDebt]) -> [PaybackAllocation] {
        debts
            .filter { $0.repsOwed > 0 }
            .map { PaybackAllocation(key: $0.key, name: $0.name, glyph: $0.glyph, reps: $0.repsOwed) }
    }

    private func fractionalAllocations(of debts: [PaybackDebt], fraction: Double) -> [PaybackAllocation] {
        debts.compactMap { debt in
            let reps = min(debt.repsOwed, Int((Double(debt.repsOwed) * fraction).rounded(.up)))
            guard reps > 0 else { return nil }
            return PaybackAllocation(key: debt.key, name: debt.name, glyph: debt.glyph, reps: reps)
        }
    }

    /// Distributes `total` reps across exercises proportionally to their debt,
    /// capped at each exercise's owed amount, remainder to the largest debts.
    private func proportionalAllocations(of debts: [PaybackDebt], total: Int) -> [PaybackAllocation] {
        let totalOwed = debts.reduce(0) { $0 + $1.repsOwed }
        let want = max(0, min(total, totalOwed))
        guard want > 0 else { return [] }

        // Largest-remainder method, capped per exercise.
        var assigned = debts.map { debt -> Int in
            let exact = Double(want) * Double(debt.repsOwed) / Double(totalOwed)
            return min(debt.repsOwed, Int(exact)) // floor
        }
        var leftover = want - assigned.reduce(0, +)

        // Hand out the leftover to exercises that still have headroom, largest debt first.
        let order = debts.indices.sorted { debts[$0].repsOwed > debts[$1].repsOwed }
        var i = 0
        while leftover > 0 {
            let idx = order[i % order.count]
            if assigned[idx] < debts[idx].repsOwed {
                assigned[idx] += 1
                leftover -= 1
            }
            i += 1
            if i > order.count * (want + 1) { break } // safety
        }

        return zip(debts, assigned).compactMap { debt, reps in
            guard reps > 0 else { return nil }
            return PaybackAllocation(key: debt.key, name: debt.name, glyph: debt.glyph, reps: reps)
        }
    }
}
