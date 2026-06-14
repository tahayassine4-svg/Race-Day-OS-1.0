import Testing
import Foundation
@testable import GettingMoney

@Suite("Packet 11 — rounds completion")
@MainActor
struct RoundsCompletionTests {
    private func makeRounds(_ store: LocalStore) -> RoundsViewModel {
        RoundsViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
    }
    private func dashboard(_ store: LocalStore) -> DashboardViewModel {
        DashboardViewModel(exerciseRepository: store.exerciseRepository, workoutRepository: store.workoutRepository)
    }

    @Test("Ticking a round logs its reps into the daily balance")
    func tickingRoundLogsToBalance() throws {
        let store = try LocalStore(inMemory: true)
        let rounds = makeRounds(store)
        rounds.load() // 3 rounds: round 1 = 34 push + 4 pull + 50 squat = 88

        rounds.toggleRoundCompleted(1)
        #expect(rounds.isCompleted(1))

        let dash = dashboard(store)
        dash.load()
        #expect(dash.bankBalance == 88)
        #expect(dash.dailyCompleted == 88)
    }

    @Test("Un-ticking a round removes exactly its reps")
    func untickRemovesReps() throws {
        let store = try LocalStore(inMemory: true)
        let rounds = makeRounds(store)
        rounds.load()
        rounds.toggleRoundCompleted(1)
        rounds.toggleRoundCompleted(1) // undo

        #expect(rounds.isCompleted(1) == false)
        let dash = dashboard(store)
        dash.load()
        #expect(dash.bankBalance == 0)
    }

    @Test("Completion survives a reload (derived from logged reps)")
    func completionSurvivesReload() throws {
        let store = try LocalStore(inMemory: true)
        let rounds = makeRounds(store)
        rounds.load()
        rounds.toggleRoundCompleted(2)

        let reopened = makeRounds(store)
        reopened.load()
        #expect(reopened.isCompleted(2))
        #expect(reopened.completedCount == 1)
    }

    @Test("Round count goes up to 10 and clamps")
    func roundCountUpToTen() throws {
        let store = try LocalStore(inMemory: true)
        let rounds = makeRounds(store)
        rounds.load()

        rounds.chooseRoundCount(10)
        #expect(rounds.selectedRoundCount == 10)
        #expect(rounds.rounds.count == 10)

        rounds.chooseRoundCount(11) // clamped to max
        #expect(rounds.selectedRoundCount == 10)
    }

    @Test("Round count locks once a round is ticked off")
    func countLockedAfterCompletion() throws {
        let store = try LocalStore(inMemory: true)
        let rounds = makeRounds(store)
        rounds.load()
        rounds.toggleRoundCompleted(1)

        #expect(rounds.canChangeRoundCount == false)
        rounds.chooseRoundCount(5) // ignored while a round is done
        #expect(rounds.selectedRoundCount == 3)
    }

    @Test("A completed round is locked for edits until undone, then editable")
    func editAfterUndo() throws {
        let store = try LocalStore(inMemory: true)
        let rounds = makeRounds(store)
        rounds.load()
        let push1 = { rounds.rounds.first { $0.id == 1 }?.exercises.first { $0.key == "pushups" }?.reps }
        #expect(push1() == 34)

        rounds.toggleRoundCompleted(1)
        rounds.adjust(roundID: 1, exerciseKey: "pushups", by: 5) // ignored while done
        rounds.toggleRoundCompleted(1) // undo → editable
        rounds.adjust(roundID: 1, exerciseKey: "pushups", by: 5)
        #expect(push1() == 39)
    }

    @Test("Completing payoff rounds pays the debt down")
    func completingPayoffRoundsClearsDebt() throws {
        let store = try LocalStore(inMemory: true)
        try store.exerciseRepository.setDebt(key: "pushups", repsOwed: 30, updatedAt: Date())
        let rounds = makeRounds(store)
        rounds.load()
        rounds.choosePayoff(.full) // folds 30 owed push-ups across the rounds

        for id in rounds.rounds.map(\.id) { rounds.toggleRoundCompleted(id) }

        let dash = dashboard(store)
        dash.load()
        // 100 target + 30 payoff push-ups logged → 30 surplus repays the 30 debt.
        #expect(dash.totalDebt == 0)
    }

    @Test("sourceRoundNumber survives a real on-disk reopen")
    func sourceRoundNumberPersists() throws {
        let url = URL.temporaryDirectory.appending(path: "gm-rounds-\(UUID().uuidString).store")
        defer {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }
        do {
            let store = try LocalStore(url: url)
            _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 20, sourceRoundNumber: 2, at: Date())
        }
        let reopened = try LocalStore(url: url)
        let entry = try reopened.workoutRepository.entries(on: Date()).first { $0.sourceRoundNumber == 2 }
        #expect(entry?.count == 20)
    }
}
