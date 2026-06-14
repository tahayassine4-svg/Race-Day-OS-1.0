import SwiftUI

// MARK: - Snapshot model
//
// The widget never touches SwiftData. The app writes a small Codable snapshot of
// *today's* targets into a shared App Group container; the widget reads it back.
// This deliberately avoids moving the live SwiftData store into the App Group
// (that would be a migration risk for the shipped TestFlight build).

/// One exercise row as the widget sees it. `key` mirrors `Exercise.key`.
struct WidgetExercise: Codable, Identifiable, Equatable {
    let key: String
    let name: String
    let glyph: String   // SF Symbol
    let target: Int
    let completed: Int

    var id: String { key }
    var remaining: Int { max(0, target - completed) }
    var isMet: Bool { target > 0 && completed >= target }
    var fraction: Double {
        guard target > 0 else { return 0 }
        return min(1, Double(completed) / Double(target))
    }
}

/// Everything the widget needs to render today's targets. Only `.isEnabled`
/// exercises are included, so the optional Dips row appears automatically once
/// it is turned on — no widget change required.
struct WidgetSnapshot: Codable, Equatable {
    let dayKey: Date
    let exercises: [WidgetExercise]

    var totalCompleted: Int { exercises.reduce(0) { $0 + $1.completed } }
    var totalTarget: Int { exercises.reduce(0) { $0 + $1.target } }
    var fraction: Double {
        guard totalTarget > 0 else { return 0 }
        return min(1, Double(totalCompleted) / Double(totalTarget))
    }

    /// Shown in the gallery / before the app has written real data.
    static var placeholder: WidgetSnapshot {
        WidgetSnapshot(
            dayKey: Date(),
            exercises: [
                WidgetExercise(key: "pushups", name: "Push-ups", glyph: "figure.strengthtraining.traditional", target: 100, completed: 40),
                WidgetExercise(key: "pullups", name: "Pull-ups", glyph: "figure.play", target: 10, completed: 4),
                WidgetExercise(key: "squats", name: "Squats", glyph: "figure.cross.training", target: 150, completed: 60)
            ]
        )
    }
}

// MARK: - App Group bridge

/// Read/write the snapshot through the shared App Group. The suite name MUST be
/// identical in the app entitlement, the widget entitlement, and here.
enum WidgetShared {
    static let appGroup = "group.com.yassine.gettingmoney"
    static let snapshotKey = "dailyTargetsSnapshot.v1"

    static func save(_ snapshot: WidgetSnapshot) {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
    }

    static func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: snapshotKey),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else { return nil }
        return snapshot
    }
}

// MARK: - Palette (inline so the widget needs no DesignSystem dependency)

enum GMWidgetColor {
    static let background = Color(red: 0.039, green: 0.051, blue: 0.043)  // #0A0D0B
    static let surface    = Color(red: 0.106, green: 0.125, blue: 0.110)  // #1B201C
    static let ink        = Color(red: 0.953, green: 0.969, blue: 0.945)  // #F3F7F1
    static let muted      = Color(red: 0.541, green: 0.576, blue: 0.549)  // #8A938C
    static let accent     = Color(red: 0.682, green: 0.902, blue: 0.239)  // #AEE63D
    static let track      = Color(red: 0.165, green: 0.188, blue: 0.173)  // #2A302C
}

// MARK: - Content view
//
// Pure SwiftUI with no widget-only modifiers, so it can also be rendered inside
// the app for screenshot verification. The widget wraps this in a
// `.containerBackground(for: .widget)`.

struct DailyTargetsContent: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            ForEach(snapshot.exercises) { exercise in
                row(exercise)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("TODAY")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(GMWidgetColor.muted)
            Spacer()
            Text("\(Int((snapshot.fraction * 100).rounded()))%")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(snapshot.fraction >= 1 ? GMWidgetColor.accent : GMWidgetColor.ink)
        }
    }

    private func row(_ exercise: WidgetExercise) -> some View {
        HStack(spacing: 10) {
            Image(systemName: exercise.glyph)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(exercise.isMet ? GMWidgetColor.accent : GMWidgetColor.muted)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(exercise.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(GMWidgetColor.ink)
                        .lineLimit(1)
                    Spacer()
                    Text("\(exercise.completed)/\(exercise.target)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(exercise.isMet ? GMWidgetColor.accent : GMWidgetColor.ink)
                        .monospacedDigit()
                }
                progressBar(exercise.fraction, met: exercise.isMet)
            }
        }
    }

    private func progressBar(_ fraction: Double, met: Bool) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(GMWidgetColor.track)
                Capsule()
                    .fill(GMWidgetColor.accent)
                    .frame(width: max(0, geo.size.width * fraction))
            }
        }
        .frame(height: 5)
    }
}

#Preview {
    DailyTargetsContent(snapshot: .placeholder)
        .background(GMWidgetColor.background)
}
