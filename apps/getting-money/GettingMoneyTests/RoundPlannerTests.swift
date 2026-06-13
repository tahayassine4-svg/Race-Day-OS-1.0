import Testing
import Foundation
@testable import GettingMoney

@Suite("Packet 06 — round planner")
struct RoundPlannerTests {
    private let planner = RoundPlanner()

    @Test("Even split preserves all reps")
    func evenSplit() {
        #expect(planner.split(target: 60, rounds: 3) == [20, 20, 20])
    }

    @Test("Uneven split sends remainder to earliest rounds")
    func unevenSplit() {
        #expect(planner.split(target: 10, rounds: 3) == [4, 3, 3])
    }

    @Test("All split reps sum to the original target")
    func sumPreserved() {
        #expect(planner.split(target: 50, rounds: 3).reduce(0, +) == 50)
    }

    @Test("Multiple exercises split into matching round cards")
    func planMultipleExercises() {
        let plan = planner.plan(targets: [
            RoundTarget(key: "pushups", name: "Push-ups", glyph: "figure.strengthtraining.traditional", reps: 100),
            RoundTarget(key: "pullups", name: "Pull-ups", glyph: "figure.play", reps: 10)
        ], rounds: 3)

        #expect(plan.map(\.id) == [1, 2, 3])
        #expect(plan[0].exercises.map(\.reps) == [34, 4])
        #expect(plan[1].exercises.map(\.reps) == [33, 3])
        #expect(plan[2].exercises.map(\.reps) == [33, 3])
    }
}

@Suite("Packet 06 — rounds view model")
@MainActor
struct RoundsViewModelTests {
    @Test("Editing a round recomputes preview totals")
    func editRecomputesTotals() throws {
        let store = try LocalStore(inMemory: true)
        let viewModel = RoundsViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )

        viewModel.load()
        #expect(viewModel.plannedTotal == 260)
        viewModel.adjust(roundID: 1, exerciseKey: "pushups", by: 5)
        #expect(viewModel.plannedTotal == 265)
        #expect(viewModel.extraMoney == 5)
    }

    @Test("Saved round plan remains after reopening the store")
    func roundPlanPersists() throws {
        let url = URL.temporaryDirectory.appending(path: "gm-rounds-\(UUID().uuidString).store")
        defer {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }

        do {
            let store = try LocalStore(url: url)
            let viewModel = RoundsViewModel(
                exerciseRepository: store.exerciseRepository,
                workoutRepository: store.workoutRepository
            )
            viewModel.load()
            viewModel.chooseRoundCount(4)
            viewModel.adjust(roundID: 1, exerciseKey: "pushups", by: 3)
            viewModel.save()
        }

        let reopened = try LocalStore(url: url)
        let saved = try reopened.workoutRepository.roundPlans(on: Date())

        #expect(Set(saved.map(\.roundNumber)) == Set([1, 2, 3, 4]))
        #expect(saved.first { $0.roundNumber == 1 && $0.exerciseKey == "pushups" }?.plannedReps == 28)
    }
}
