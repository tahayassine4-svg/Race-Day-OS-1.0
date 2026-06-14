import SwiftUI
import SwiftData

@main
struct GettingMoneyApp: App {
    let store: LocalStore

    init() {
        do {
            store = try LocalStore()
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
        // Close out any completed days into rep-debt before the first screen loads.
        try? DayCloseService(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ).run()
    }

    var body: some Scene {
        WindowGroup {
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-GMWidgetPreview") {
                WidgetPreviewHarness(store: store)
                    .preferredColorScheme(.dark)
            } else {
                AppRootView(store: store)
                    .preferredColorScheme(.dark)
            }
#else
            AppRootView(store: store)
                // v1 is dark-first per docs/ui-system.md. Light mirror is deferred to a polish packet.
                .preferredColorScheme(.dark)
#endif
        }
        .modelContainer(store.container)
    }
}

#if DEBUG
/// Renders the widget's content view at system medium/large sizes so the widget
/// UI can be screenshot-verified inside the app (WidgetKit timelines can't be
/// captured with `simctl`). Reachable only via `-GMWidgetPreview`.
private struct WidgetPreviewHarness: View {
    let store: LocalStore

    private var snapshot: WidgetSnapshot {
        (try? WidgetSnapshotPublisher.buildSnapshot(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )) ?? .placeholder
    }

    var body: some View {
        ZStack {
            GMWidgetColor.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Widget preview").font(.caption).foregroundStyle(GMWidgetColor.muted)
                widgetCard(width: 360, height: 170)   // systemMedium-ish
                widgetCard(width: 360, height: 360)   // systemLarge-ish
            }
            .padding()
        }
    }

    private func widgetCard(width: CGFloat, height: CGFloat) -> some View {
        DailyTargetsContent(snapshot: snapshot)
            .frame(width: width, height: height)
            .background(GMWidgetColor.background)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(GMWidgetColor.track, lineWidth: 1)
            )
    }
}
#endif
