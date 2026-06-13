import Foundation

struct RoundTarget: Equatable, Sendable {
    let key: String
    let name: String
    let glyph: String
    let reps: Int
}

struct PlannedRound: Equatable, Identifiable, Sendable {
    let id: Int
    var exercises: [RoundTarget]

    var totalReps: Int { exercises.reduce(0) { $0 + $1.reps } }
}

protocol RoundPlannerProtocol: Sendable {
    func split(target: Int, rounds: Int) -> [Int]
    func plan(targets: [RoundTarget], rounds: Int) -> [PlannedRound]
}

struct RoundPlanner: RoundPlannerProtocol {
    func split(target: Int, rounds: Int) -> [Int] {
        let count = max(1, rounds)
        let reps = max(0, target)
        let base = reps / count
        let remainder = reps % count
        return (0..<count).map { index in base + (index < remainder ? 1 : 0) }
    }

    func plan(targets: [RoundTarget], rounds: Int) -> [PlannedRound] {
        let count = max(1, rounds)
        let splitByExercise = targets.map { target in
            (target, split(target: target.reps, rounds: count))
        }

        return (0..<count).map { roundIndex in
            PlannedRound(
                id: roundIndex + 1,
                exercises: splitByExercise.map { target, split in
                    RoundTarget(key: target.key, name: target.name, glyph: target.glyph, reps: split[roundIndex])
                }
            )
        }
    }
}
