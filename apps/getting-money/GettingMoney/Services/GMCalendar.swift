import Foundation

/// Deterministic day-boundary helper. All day-keyed logic (WorkoutDay, streaks,
/// day-close debt) uses this so behavior doesn't drift with locale/timezone calendars.
enum GMCalendar {
    /// A fixed Gregorian calendar in the current timezone.
    static var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .current
        return c
    }

    /// Normalized start-of-day key for a date.
    static func dayKey(for date: Date = Date()) -> Date {
        calendar.startOfDay(for: date)
    }
}
