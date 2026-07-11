import SwiftUI

/// The redesigned dashboard: greeting, a sticky wallet card that collapses on
/// scroll, a status pill, and swipeable "today's goals" cards with quick-log.
struct DashboardScreen: View {
  @Bindable var vm: DashboardViewModel
  let bankName: String
  let toast: ToastCenter
  let onOpenRounds: () -> Void
  let onOpenTargets: () -> Void

  @State private var collapse: CGFloat = 0
  private let space = "dash"

  var body: some View {
    ScrollView(showsIndicators: false) {
      ScrollOffsetReader(space: space)
      LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
        greeting
          .padding(.top, 4)

        Section {
          statusPill
            .padding(.top, 14)
          goalsHeader
          cardsScroller
          openRoundsButton
        } header: {
          WalletCard(
            bankName: bankName, balance: vm.bankBalance,
            earned: earnedTotal, debt: vm.totalDebt, collapse: collapse
          )
          .padding(.vertical, 8)
          .background(pinnedBackdrop)
        }
      }
      .padding(.horizontal, GMSpacing.screen)
      .padding(.bottom, 130)
    }
    .coordinateSpace(name: space)
    .onPreferenceChange(ScrollOffsetKey.self) { value in
      collapse = min(1, max(0, value / 150))
    }
  }

  // MARK: greeting

  private var greeting: some View {
    HStack(spacing: 12) {
      Text("$")
        .font(GMFont.display(18, .bold))
        .foregroundStyle(GMColor.accent)
        .frame(width: 42, height: 42)
        .background(
          Circle().fill(GMColor.cardGradient)
            .overlay(Circle().stroke(GMColor.accent.opacity(0.3), lineWidth: 2)))
      VStack(alignment: .leading, spacing: 1) {
        Text(greetingText)
          .font(GMFont.body(13, .semibold))
          .foregroundStyle(GMColor.ink.opacity(0.5))
        Text(bankName)
          .font(GMFont.display(17, .bold))
          .foregroundStyle(GMColor.ink)
      }
      Spacer()
      Button(action: onOpenTargets) {
        Image(systemName: "slider.horizontal.3")
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(GMColor.accent)
          .frame(width: 44, height: 44)
          .background(
            RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.04))
              .overlay(
                RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1)))
      }
      .buttonStyle(PressButtonStyle())
      .accessibilityLabel("Daily targets")
    }
  }

  // MARK: status pill

  private var statusPill: some View {
    StatusPill(
      tint: statusTint, title: statusTitle, subtitle: statusSub,
      action: { if vm.totalDebt > 0 { onOpenRounds() } }
    )
  }

  // MARK: goals

  private var goalsHeader: some View {
    HStack(alignment: .firstTextBaseline) {
      Text("Today's goals")
        .font(GMFont.display(18, .bold))
        .foregroundStyle(GMColor.ink)
      Spacer()
      Text(overallText)
        .font(GMFont.body(13, .semibold))
        .foregroundStyle(GMColor.ink.opacity(0.45))
    }
    .padding(.top, 2)
  }

  private var cardsScroller: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 14) {
        ForEach(vm.rows) { row in
          ExerciseGoalCard(
            name: row.name, glyph: row.glyph,
            done: row.completed, target: row.target, debt: row.debtOwed,
            onAdd1: { log(row.id, 1) },
            onAdd10: { log(row.id, 10) }
          )
        }
      }
      .padding(.horizontal, GMSpacing.screen)
      .padding(.vertical, 4)
    }
    .padding(.horizontal, -GMSpacing.screen)
  }

  private var openRoundsButton: some View {
    Button(action: onOpenRounds) {
      Text("Open rounds for full sets →")
        .font(GMFont.display(15, .semibold))
        .foregroundStyle(GMColor.ink)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
          RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.04))
            .overlay(
              RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1)))
    }
    .buttonStyle(PressButtonStyle())
    .padding(.top, 8)
  }

  private var pinnedBackdrop: some View {
    Rectangle().fill(.clear)
      .background(
        LinearGradient(
          colors: [GMColor.background, GMColor.background.opacity(0.85), .clear],
          startPoint: .top, endPoint: .bottom)
      )
      .padding(.horizontal, -GMSpacing.screen)
      .padding(.top, -60)
  }

  // MARK: logging

  private func log(_ key: String, _ count: Int) {
    let result = vm.logReps(key, count)
    toast.show("+\(result.earned.gmDollars)", subtitle(result))
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  private func subtitle(_ r: DashboardViewModel.LogResult) -> String {
    if r.debtPaid > 0 && r.bonus > 0 {
      return "paid \(r.debtPaid.gmDollars) debt · +\(r.bonus.gmDollars) bonus"
    }
    if r.debtPaid > 0 { return "paid \(r.debtPaid.gmDollars) rep debt" }
    if r.bonus > 0 { return "+\(r.bonus.gmDollars) bonus bank" }
    return "added to today"
  }

  // MARK: derived

  private var earnedTotal: Int { vm.bankBalance + vm.totalDebt }

  private var greetingText: String {
    switch Calendar.current.component(.hour, from: Date()) {
    case ..<12: "Good morning"
    case 12..<18: "Good afternoon"
    default: "Good evening"
    }
  }

  private var allDone: Bool { vm.dailyTarget > 0 && vm.dailyCompleted >= vm.dailyTarget }

  private var statusTint: Color {
    if vm.totalDebt > 0 { return GMColor.debt }
    return allDone ? GMColor.accent : GMColor.warning
  }
  private var statusTitle: String {
    if vm.totalDebt > 0 { return "Behind on reps" }
    return allDone ? "You're all paid up" : "In progress"
  }
  private var statusSub: String {
    if vm.totalDebt > 0 { return "\(vm.totalDebt.gmDollars) rep debt to clear" }
    return allDone ? "Bank's growing — keep it going" : "Finish your reps to stay green"
  }

  private var overallText: String {
    let done = vm.rows.reduce(0) { $0 + min($1.completed, $1.target) }
    let pct = vm.dailyTarget == 0 ? 0 : Int((Double(done) / Double(vm.dailyTarget) * 100).rounded())
    return "\(pct)% complete"
  }
}
