import SwiftUI

/// Root 5-tab shell. Dashboard launches first (docs/ui-system.md).
struct AppRootView: View {
    enum Tab: Hashable { case dashboard, log, rounds, debt, settings }
    @State private var selection: Tab
    @State private var settingsViewModel: SettingsViewModel
    @State private var dashboardViewModel: DashboardViewModel
    @State private var repLoggerViewModel: RepLoggerViewModel
    @State private var debtViewModel: DebtViewModel
    @State private var roundsViewModel: RoundsViewModel
    @Environment(\.scenePhase) private var scenePhase
    let store: LocalStore

    init(store: LocalStore) {
        self.store = store
        _selection = State(initialValue: Self.initialTab())
        _settingsViewModel = State(initialValue: SettingsViewModel(repository: store.exerciseRepository, dataAdmin: store))
        _dashboardViewModel = State(initialValue: DashboardViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ))
        _repLoggerViewModel = State(initialValue: RepLoggerViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        ))
        _debtViewModel = State(initialValue: DebtViewModel(exerciseRepository: store.exerciseRepository))
        let rounds = RoundsViewModel(
            exerciseRepository: store.exerciseRepository,
            workoutRepository: store.workoutRepository
        )
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-GMPayoffFull") {
            rounds.requestPayoff(.full)
        }
#endif
        _roundsViewModel = State(initialValue: rounds)
    }

    var body: some View {
        TabView(selection: $selection) {
            DashboardView(
                viewModel: dashboardViewModel,
                onStartRounds: { selection = .rounds },
                onSetTargets: { selection = .settings }
            )
            .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }
            .tag(Tab.dashboard)

            LogView(viewModel: repLoggerViewModel)
                .tabItem { Label("Log", systemImage: "plus.circle.fill") }
                .tag(Tab.log)

            RoundsView(viewModel: roundsViewModel)
                .tabItem { Label("Rounds", systemImage: "circle.dotted") }
                .tag(Tab.rounds)

            DebtView(viewModel: debtViewModel, onAddPayoff: addPayoffToRounds)
                .tabItem { Label("Debt", systemImage: "arrow.triangle.2.circlepath") }
                .tag(Tab.debt)

            SettingsView(viewModel: settingsViewModel)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .tint(GMColor.accent)
        .onChange(of: selection) { _, tab in reload(tab) }
        .onChange(of: scenePhase) { _, phase in
            // Returning to the foreground may have crossed a midnight: settle any
            // newly-completed days into debt, then refresh what's on screen.
            guard phase == .active else { return }
            try? DayCloseService(
                exerciseRepository: store.exerciseRepository,
                workoutRepository: store.workoutRepository
            ).run()
            refreshAll()
        }
    }

    /// Reloads every data-backed tab after a foreground day-close so debt, status,
    /// and plans are consistent regardless of which tab is visible.
    private func refreshAll() {
        dashboardViewModel.load()
        repLoggerViewModel.load()
        roundsViewModel.load()
        debtViewModel.load()
    }

    /// Reload the active tab's data when it becomes visible. SwiftUI keeps tab
    /// children alive, so `.task` does not re-fire on tab switches; this keeps
    /// debt/rounds/dashboard in sync after reps are logged elsewhere.
    private func reload(_ tab: Tab) {
        switch tab {
        case .dashboard: dashboardViewModel.load()
        case .rounds: roundsViewModel.load()
        case .debt: debtViewModel.load()
        case .log, .settings: break
        }
    }

    private static func initialTab() -> Tab {
#if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-GMInitialTab"), i + 1 < args.count {
            switch args[i + 1] {
            case "rounds": return .rounds
            case "debt": return .debt
            case "settings": return .settings
            case "log": return .log
            default: return .dashboard
            }
        }
#endif
        return .dashboard
    }

    /// Debt screen → Rounds tab with the full owed amount folded into today's
    /// rounds. The payoff is *requested* so it survives the tab-switch reload
    /// that `onChange(of: selection)` triggers.
    private func addPayoffToRounds() {
        roundsViewModel.requestPayoff(.full)
        selection = .rounds
    }
}

#Preview {
    let store = try! LocalStore(inMemory: true)
    AppRootView(store: store).preferredColorScheme(.dark)
}
