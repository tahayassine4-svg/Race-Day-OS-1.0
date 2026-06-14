import Testing
import Foundation
@testable import GettingMoney

@Suite("Packet 14 — widget snapshot")
@MainActor
struct WidgetSnapshotTests {
    private let cal = GMCalendar.calendar

    private func build(_ store: LocalStore, today: Date) throws -> WidgetSnapshot {
        try WidgetSnapshotPublisher.buildSnapshot(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository,
            today: today
        )
    }

    @Test("Fresh snapshot lists the three default targets, no reps yet, dips hidden")
    func defaultSnapshot() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)
        let snapshot = try build(store, today: today)

        #expect(snapshot.dayKey == GMCalendar.dayKey(for: today))
        #expect(snapshot.exercises.map(\.key) == ["pushups", "pullups", "squats"])

        let targets = Dictionary(uniqueKeysWithValues: snapshot.exercises.map { ($0.key, $0.target) })
        #expect(targets["pushups"] == 100)
        #expect(targets["pullups"] == 10)
        #expect(targets["squats"] == 150)
        #expect(snapshot.exercises.allSatisfy { $0.completed == 0 })
        #expect(snapshot.totalTarget == 260)
    }

    @Test("Logged reps appear as completed and drive the fraction")
    func loggedRepsReflected() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 40, sourceRoundNumber: nil, at: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 10, sourceRoundNumber: nil, at: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "squats", count: 150, sourceRoundNumber: nil, at: today)

        let snapshot = try build(store, today: today)
        let byKey = Dictionary(uniqueKeysWithValues: snapshot.exercises.map { ($0.key, $0) })

        #expect(byKey["pushups"]?.completed == 50)
        #expect(byKey["pushups"]?.isMet == false)
        #expect(byKey["squats"]?.completed == 150)
        #expect(byKey["squats"]?.isMet == true)
        #expect(snapshot.totalCompleted == 200)
    }

    @Test("Enabling the optional Dips exercise makes it appear in the widget snapshot")
    func dipsAppearWhenEnabled() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)

        // Before: dips is optional + disabled, so it is absent.
        #expect(try build(store, today: today).exercises.contains { $0.key == "dips" } == false)

        try store.exerciseRepository.setEnabled(key: "dips", true)
        let snapshot = try build(store, today: today)
        let dips = snapshot.exercises.first { $0.key == "dips" }
        #expect(dips != nil)
        #expect(dips?.target == 30)
        #expect(dips?.completed == 0)
    }

    @Test("Snapshot round-trips through the App Group Codable encoding")
    func codableRoundTrip() throws {
        let original = WidgetSnapshot.placeholder
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
        #expect(decoded == original)
    }

    @Test("A stale (yesterday) snapshot zeroes completed reps but keeps targets")
    func staleSnapshotResetsForNewDay() throws {
        let today = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let stale = WidgetSnapshot(
            dayKey: cal.startOfDay(for: yesterday),
            exercises: [
                WidgetExercise(key: "pushups", name: "Push-ups", glyph: "g", target: 100, completed: 100),
                WidgetExercise(key: "squats", name: "Squats", glyph: "g", target: 150, completed: 150)
            ]
        )

        let fresh = stale.zeroedIfStale(today: today)
        #expect(fresh.dayKey == cal.startOfDay(for: today))
        #expect(fresh.exercises.allSatisfy { $0.completed == 0 })
        #expect(fresh.exercises.map(\.target) == [100, 150])
    }

    @Test("Today's snapshot is left unchanged by the staleness reset")
    func todaySnapshotUnchanged() throws {
        let today = Date()
        let store = try LocalStore(inMemory: true, seedDate: today)
        _ = try store.workoutRepository.addRepEntry(exerciseKey: "pushups", count: 20, sourceRoundNumber: nil, at: today)
        let snapshot = try build(store, today: today)

        #expect(snapshot.zeroedIfStale(today: today) == snapshot)
    }
}
