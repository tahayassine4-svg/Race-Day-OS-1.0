import SwiftUI

/// Root 5-tab shell. Dashboard launches first (docs/ui-system.md).
struct AppRootView: View {
    enum Tab: Hashable { case dashboard, log, rounds, debt, settings }
    @State private var selection: Tab = .dashboard
    @State private var settingsViewModel: SettingsViewModel
    @State private var dashboardViewModel: DashboardViewModel
    @State private var repLoggerViewModel: RepLoggerViewModel
    @State private var debtViewModel: DebtViewModel
    @State private var roundsViewModel: RoundsViewModel
    let store: LocalStore

    init(store: LocalStore) {
        self.store = store
        _settingsViewModel = State(initialValue: SettingsViewModel(repository: store.exerciseRepository))
        _dashboardViewModel = State(initialValue: DashboardViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ))
        _repLoggerViewModel = State(initialValue: RepLoggerViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ))
        _debtViewModel = State(initialValue: DebtViewModel(exerciseRepository: store.exerciseRepository))
        _roundsViewModel = State(initialValue: RoundsViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ))
    }

    var body: some View {
        TabView(selection: $selection) {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }
                .tag(Tab.dashboard)

            LogView(viewModel: repLoggerViewModel)
                .tabItem { Label("Log", systemImage: "plus.circle.fill") }
                .tag(Tab.log)

            RoundsView(viewModel: roundsViewModel)
                .tabItem { Label("Rounds", systemImage: "circle.dotted") }
                .tag(Tab.rounds)

            DebtView(viewModel: debtViewModel)
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
