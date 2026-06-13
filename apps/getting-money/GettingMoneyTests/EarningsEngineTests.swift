import Testing
@testable import GettingMoney

@Suite("Packet 04 — earnings engine")
struct EarningsEngineTests {
    private let engine = EarningsEngine()

    @Test("Every completed rep earns money at the configured rep value")
    func baseEarnings() {
        let summary = engine.summary(completedReps: 25, targetReps: 100, repValue: 1)

        #expect(summary.earned == 25)
        #expect(summary.targetEarned == 25)
        #expect(summary.bonusEarned == 0)
    }

    @Test("Over-target reps are reported separately as bonus earnings")
    func overTargetSplit() {
        let summary = engine.summary(completedReps: 125, targetReps: 100, repValue: 1)

        #expect(summary.earned == 125)
        #expect(summary.targetEarned == 100)
        #expect(summary.bonusEarned == 25)
    }

    @Test("Rep value multiplies all earnings")
    func repValueMath() {
        let summary = engine.summary(completedReps: 12, targetReps: 10, repValue: 3)

        #expect(summary.earned == 36)
        #expect(summary.targetEarned == 30)
        #expect(summary.bonusEarned == 6)
    }
}
