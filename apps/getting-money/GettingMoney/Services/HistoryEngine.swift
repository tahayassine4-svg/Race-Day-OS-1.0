import Foundation

/// A pure, value-type snapshot of a logged rep set — keeps `HistoryEngine`
/// independent of SwiftData models.
struct RepEntrySnapshot: Equatable, Sendable {
    let date: Date
    let count: Int
}

/// One day in the history series.
struct HistoryPoint: Identifiable, Equatable, Sendable {
    let date: Date
    let dailyReps: Int
    let dailyMoney: Int
    let cumulativeMoney: Int

    var id: Date { date }
    var isActive: Bool { dailyReps > 0 }
}

protocol HistoryEngineProtocol: Sendable {
    func dailySeries(from entries: [RepEntrySnapshot], repValue: Int, days: Int, today: Date) -> [HistoryPoint]
    func currentStreak(_ series: [HistoryPoint]) -> Int
}

/// Builds a daily history series (bank balance, daily earnings, activity/streak)
/// from raw rep entries. Bank balance is cumulative across ALL entries so the
/// balance line is correct even when older entries fall outside the window.
struct HistoryEngine: HistoryEngineProtocol {
    private let calendar = GMCalendar.calendar

    func dailySeries(from entries: [RepEntrySnapshot], repValue: Int, days: Int, today: Date = Date()) -> [HistoryPoint] {
        let dayCount = max(1, days)
        let todayKey = calendar.startOfDay(for: today)
        guard let startKey = calendar.date(byAdding: .day, value: -(dayCount - 1), to: todayKey) else { return [] }

        var dailyReps: [Date: Int] = [:]
        var baselineBeforeWindow = 0
        for entry in entries {
            let key = calendar.startOfDay(for: entry.date)
            if key < startKey {
                baselineBeforeWindow += entry.count
            } else if key <= todayKey {
                dailyReps[key, default: 0] += entry.count
            }
        }

        var cumulative = baselineBeforeWindow
        var points: [HistoryPoint] = []
        points.reserveCapacity(dayCount)
        for offset in 0..<dayCount {
            guard let day = calendar.date(byAdding: .day, value: offset, to: startKey) else { continue }
            let reps = dailyReps[day] ?? 0
            cumulative += reps
            points.append(HistoryPoint(
                date: day,
                dailyReps: reps,
                dailyMoney: reps * repValue,
                cumulativeMoney: cumulative * repValue
            ))
        }
        return points
    }

    /// Consecutive active days ending at the most recent day in the series.
    func currentStreak(_ series: [HistoryPoint]) -> Int {
        var streak = 0
        for point in series.reversed() {
            if point.isActive { streak += 1 } else { break }
        }
        return streak
    }
}
