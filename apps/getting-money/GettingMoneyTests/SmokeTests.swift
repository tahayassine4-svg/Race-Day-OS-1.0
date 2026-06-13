import Testing
@testable import GettingMoney

@Suite("Packet 01 — foundation smoke tests")
struct SmokeTests {

    @Test("Dashboard sample data is internally consistent")
    func dashboardSample() {
        let m = DashboardSample.preview
        #expect(m.exercises.count == 3)
        #expect(m.dailyTarget > 0)
        #expect(m.dailyFraction > 0 && m.dailyFraction <= 1)
        #expect(m.hasDebt == (m.repDebtReps > 0))
    }

    @Test("Exercise progress fraction and remaining compute correctly")
    func exerciseMath() {
        let pushups = ExerciseProgressSample(
            name: "Push-ups", glyph: "x", completed: 76, target: 100, repsOwed: 0
        )
        #expect(pushups.remaining == 24)
        #expect(abs(pushups.fraction - 0.76) < 0.0001)
    }

    @Test("Status pill labels never collapse to color alone")
    func statusLabels() {
        #expect(GMStatus.activeDebt.label == "Active debt")
        #expect(!GMStatus.onTrack.label.isEmpty)
    }
}
