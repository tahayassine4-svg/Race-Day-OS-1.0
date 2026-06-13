import Foundation

@Observable
@MainActor
final class DebtViewModel {
    struct Row: Identifiable {
        let id: String
        let name: String
        let glyph: String
        let repsOwed: Int
    }

    struct PlanDay: Identifiable {
        let id: Int
        let title: String
        let summary: String
    }

    private(set) var totalDebt = 0
    private(set) var rows: [Row] = []
    private(set) var planDays: [PlanDay] = []
    private(set) var status: GMStatus = .paidOff
    private(set) var errorMessage: String?

    private let exerciseRepository: any ExerciseRepositoryProtocol

    init(exerciseRepository: any ExerciseRepositoryProtocol) {
        self.exerciseRepository = exerciseRepository
    }

    func load() {
        do {
            rows = try exerciseRepository.allOrdered()
                .filter(\.isEnabled)
                .compactMap { exercise in
                    let owed = exercise.debt?.repsOwed ?? 0
                    guard owed > 0 else { return nil }
                    return Row(id: exercise.key, name: exercise.name, glyph: exercise.glyph, repsOwed: owed)
                }
            totalDebt = rows.reduce(0) { $0 + $1.repsOwed }
            status = totalDebt > 0 ? .activeDebt : .paidOff
            planDays = makePlanDays(days: 3)
            errorMessage = nil
        } catch {
            rows = []
            planDays = []
            totalDebt = 0
            status = .paidOff
            errorMessage = "Debt could not load."
        }
    }

    private func makePlanDays(days: Int) -> [PlanDay] {
        guard totalDebt > 0 else { return [] }
        return (0..<days).map { dayIndex in
            PlanDay(
                id: dayIndex + 1,
                title: dayIndex == 0 ? "Today" : dayIndex == 1 ? "Tomorrow" : "Day \(dayIndex + 1)",
                summary: rows.map { "+\(split($0.repsOwed, over: days, dayIndex: dayIndex)) \(shortName($0.id))" }
                    .joined(separator: " · ")
            )
        }
    }

    private func split(_ amount: Int, over days: Int, dayIndex: Int) -> Int {
        guard days > 0 else { return 0 }
        return amount / days + (dayIndex < amount % days ? 1 : 0)
    }

    private func shortName(_ key: String) -> String {
        switch key {
        case "pushups": "push"
        case "pullups": "pull"
        case "squats": "squat"
        case "dips": "dip"
        default: key
        }
    }
}
