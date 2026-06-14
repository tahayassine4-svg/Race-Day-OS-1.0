import WidgetKit
import SwiftUI

@main
struct GettingMoneyWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyTargetsWidget()
    }
}

// MARK: - Timeline

struct DailyTargetsEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct DailyTargetsProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyTargetsEntry {
        DailyTargetsEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyTargetsEntry) -> Void) {
        let snapshot = (WidgetShared.load() ?? .placeholder).zeroedIfStale()
        completion(DailyTargetsEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyTargetsEntry>) -> Void) {
        // Reset a previous day's snapshot to zero so a new morning shows a fresh
        // day even if the app hasn't been opened.
        let snapshot = (WidgetShared.load() ?? .placeholder).zeroedIfStale()
        let entry = DailyTargetsEntry(date: Date(), snapshot: snapshot)

        // The app refreshes the timeline whenever reps change. As a safety net,
        // also reload at the next midnight so the widget resets for the new day
        // even if the app is never opened.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let nextMidnight = calendar.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(60 * 60)

        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

// MARK: - Widget

struct DailyTargetsWidget: Widget {
    let kind = "GettingMoneyDailyTargets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyTargetsProvider()) { entry in
            DailyTargetsContent(snapshot: entry.snapshot)
                .containerBackground(GMWidgetColor.background, for: .widget)
        }
        .configurationDisplayName("Daily Targets")
        .description("Today's push-ups, pull-ups and squats — and how many you've done. Tap to open Getting Money.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
