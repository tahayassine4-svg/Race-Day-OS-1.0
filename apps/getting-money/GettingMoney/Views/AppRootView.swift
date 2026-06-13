import SwiftUI

/// Root 5-tab shell. Dashboard launches first (docs/ui-system.md).
struct AppRootView: View {
    enum Tab: Hashable { case dashboard, log, rounds, debt, settings }
    @State private var selection: Tab = .dashboard
    @State private var settingsViewModel: SettingsViewModel
    let store: LocalStore

    init(store: LocalStore) {
        self.store = store
        _settingsViewModel = State(initialValue: SettingsViewModel(repository: store.exerciseRepository))
    }

    var body: some View {
        TabView(selection: $selection) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }
                .tag(Tab.dashboard)

            LogView()
                .tabItem { Label("Log", systemImage: "plus.circle.fill") }
                .tag(Tab.log)

            RoundsView()
                .tabItem { Label("Rounds", systemImage: "circle.dotted") }
                .tag(Tab.rounds)

            DebtView()
                .tabItem { Label("Debt", systemImage: "arrow.triangle.2.circlepath") }
                .tag(Tab.debt)

            SettingsView(viewModel: settingsViewModel)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .tint(GMColor.accent)
    }
}

#Preview {
    let store = try! LocalStore(inMemory: true)
    AppRootView(store: store).preferredColorScheme(.dark)
}
