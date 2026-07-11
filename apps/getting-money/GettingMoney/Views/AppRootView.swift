import SwiftUI

/// Root shell for the Training Bank redesign: a custom floating tab bar over the
/// ambient backdrop, an onboarding gate, the gear-reached Targets screen, and a
/// single earnings-toast host. Data flows through the same repositories/VMs as
/// before — this is a presentation redesign, not a data change.
struct AppRootView: View {
  let store: LocalStore

  @AppStorage("gm.onboardingComplete") private var onboardingComplete = false
  @AppStorage("gm.bankName") private var bankName = "Your Bank"

  @State private var selection: AppTab = .dashboard
  @State private var toast = ToastCenter()
  @State private var dashboardVM: DashboardViewModel
  @State private var roundsVM: RoundsViewModel
  @State private var debtVM: DebtViewModel
  @State private var settingsVM: SettingsViewModel
  @State private var bankVM: BankViewModel
  @Environment(\.scenePhase) private var scenePhase

  init(store: LocalStore) {
    self.store = store
    #if DEBUG
      let args = ProcessInfo.processInfo.arguments
      if let i = args.firstIndex(of: "-GMInitialScreen"), i + 1 < args.count {
        switch args[i + 1] {
        case "rounds": _selection = State(initialValue: .rounds)
        case "bank": _selection = State(initialValue: .bank)
        case "debt": _selection = State(initialValue: .debt)
        case "targets": _selection = State(initialValue: .targets)
        default: _selection = State(initialValue: .dashboard)
        }
      }
    #endif
    _dashboardVM = State(
      initialValue: DashboardViewModel(
        exerciseRepository: store.exerciseRepository,
        workoutRepository: store.workoutRepository))
    _roundsVM = State(
      initialValue: RoundsViewModel(
        exerciseRepository: store.exerciseRepository,
        workoutRepository: store.workoutRepository))
    _debtVM = State(
      initialValue: DebtViewModel(
        exerciseRepository: store.exerciseRepository,
        workoutRepository: store.workoutRepository))
    _settingsVM = State(
      initialValue: SettingsViewModel(
        repository: store.exerciseRepository, dataAdmin: store))
    _bankVM = State(
      initialValue: BankViewModel(
        exerciseRepository: store.exerciseRepository,
        workoutRepository: store.workoutRepository))
  }

  var body: some View {
    ZStack {
      AmbientBackground(showsAura: selection == .dashboard && onboardingComplete)

      if !onboardingComplete {
        OnboardingView(bankName: $bankName) {
          onboardingComplete = true
          reloadAll()
        }
        .transition(.opacity)
      } else {
        content
          .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }

        VStack {
          Spacer()
          FloatingTabBar(items: tabItems, selection: $selection)
        }
        .ignoresSafeArea(.keyboard)

        if let toastValue = toast.current {
          VStack {
            Spacer()
            GMToastView(toast: toastValue)
              .padding(.bottom, 108)
          }
          .allowsHitTesting(false)
        }
      }
    }
    .preferredColorScheme(.dark)
    .tint(GMColor.accent)
    .task {
      load(selection)
      publishWidget()
    }
    .onChange(of: selection) { _, tab in
      load(tab)
      publishWidget()
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        try? DayCloseService(
          exerciseRepository: store.exerciseRepository,
          workoutRepository: store.workoutRepository
        ).run()
        reloadAll()
      }
      publishWidget()
    }
  }

  @ViewBuilder private var content: some View {
    switch selection {
    case .dashboard:
      DashboardScreen(
        vm: dashboardVM, bankName: bankName, toast: toast,
        onOpenRounds: { selection = .rounds },
        onOpenTargets: { selection = .targets })
    case .rounds:
      RoundsScreen(vm: roundsVM, toast: toast)
    case .bank:
      BankScreen(vm: bankVM)
    case .debt:
      DebtScreen(vm: debtVM, onPayAll: payAllDebt)
    case .targets:
      TargetsScreen(vm: settingsVM, onClose: { selection = .dashboard })
    }
  }

  private var tabItems: [FloatingTabBar.Item] {
    [
      .init(id: .dashboard, label: "Dashboard", symbol: "house.fill"),
      .init(id: .rounds, label: "Rounds", symbol: "square.stack.3d.up.fill"),
      .init(id: .bank, label: "Bank", symbol: "building.columns.fill"),
      .init(id: .debt, label: "Debt", symbol: "exclamationmark.circle.fill"),
    ]
  }

  // MARK: loading

  private func load(_ tab: AppTab) {
    switch tab {
    case .dashboard: dashboardVM.load()
    case .rounds: roundsVM.load()
    case .bank: bankVM.load()
    case .debt: debtVM.load()
    case .targets: settingsVM.load()
    }
  }

  private func reloadAll() {
    dashboardVM.load()
    roundsVM.load()
    debtVM.load()
    bankVM.load()
    settingsVM.load()
  }

  /// Debt screen "Pay it all off now" → Rounds with the full owed amount folded
  /// into today's rounds (reuses the proven payoff pathway).
  private func payAllDebt() {
    roundsVM.requestPayoff(.full)
    selection = .rounds
  }

  private func publishWidget() {
    WidgetSnapshotPublisher.publish(
      exerciseRepository: store.exerciseRepository,
      workoutRepository: store.workoutRepository)
  }
}

#Preview {
  let store = try! LocalStore(inMemory: true)
  return AppRootView(store: store)
}
