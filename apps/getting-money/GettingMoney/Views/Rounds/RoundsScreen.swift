import SwiftUI

/// Rounds: flip the coin to focus an exercise, split the day into rounds, fold in
/// debt payoff, and tick each round off. Round completion drives the same tested
/// circuit engine; the coin focuses the summary + quick-log.
struct RoundsScreen: View {
  @Bindable var vm: RoundsViewModel
  let toast: ToastCenter
  @State private var focus = 0

  private var faces: [CoinFlipView.Face] {
    vm.exercises.map { ex in
      let debt = vm.debtByKey[ex.key] ?? 0
      return CoinFlipView.Face(
        id: ex.key, name: ex.name, glyph: ex.glyph,
        caption: debt > 0 ? "\(ex.reps) target · \(debt) owed" : "\(ex.reps) rep target")
    }
  }
  private var focusKey: String { faces.isEmpty ? "" : faces[min(focus, faces.count - 1)].id }

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 20) {
        header
        CoinFlipView(faces: faces, index: $focus)
          .frame(height: 300)
          .frame(maxWidth: .infinity)
          .onChange(of: focus) { _, _ in
            UISelectionFeedbackGenerator().selectionChanged()
          }
        summaryChips
        roundCountSection
        if vm.hasDebt { payoffSection }
        roundsGrid
        quickAdd
      }
      .padding(.horizontal, GMSpacing.screen)
      .padding(.top, 4)
      .padding(.bottom, 130)
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text("Pick an exercise · flip the coin")
        .font(GMFont.body(14, .semibold))
        .foregroundStyle(GMColor.ink.opacity(0.5))
      Text("Today's Rounds")
        .font(GMFont.display(24, .bold))
        .foregroundStyle(GMColor.ink)
    }
  }

  private var summaryChips: some View {
    HStack(spacing: 10) {
      chip(
        "\(vm.dailyTarget) reps planned", tint: GMColor.ink.opacity(0.6),
        bg: Color.white.opacity(0.05))
      if vm.totalDebt > 0 {
        chip(
          "\(vm.totalDebt.gmDollars) rep debt", tint: GMColor.debt, bg: GMColor.debt.opacity(0.12))
      }
      if vm.extraReps > 0 {
        chip("+\(vm.extraReps) bonus reps", tint: GMColor.accent, bg: GMColor.accent.opacity(0.12))
      }
    }
    .frame(maxWidth: .infinity)
  }

  private func chip(_ text: String, tint: Color, bg: Color) -> some View {
    Text(text)
      .font(GMFont.display(13, .semibold))
      .foregroundStyle(tint)
      .padding(.horizontal, 12).padding(.vertical, 6)
      .background(RoundedRectangle(cornerRadius: 10).fill(bg))
  }

  private var roundCountSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Split into rounds")
          .font(GMFont.display(14, .bold)).foregroundStyle(GMColor.ink)
        Spacer()
        Text("\(vm.completedCount) / \(vm.rounds.count) rounds")
          .font(GMFont.body(13, .semibold)).foregroundStyle(GMColor.ink.opacity(0.45))
      }
      HStack(spacing: 8) {
        ForEach([2, 3, 4, 5, 6], id: \.self) { n in
          let active = vm.selectedRoundCount == n
          Button {
            vm.chooseRoundCount(n)
          } label: {
            Text("\(n)")
              .font(GMFont.display(15, .bold))
              .foregroundStyle(active ? GMColor.onAccent : GMColor.ink.opacity(0.6))
              .frame(maxWidth: .infinity).frame(height: 42)
              .background(
                RoundedRectangle(cornerRadius: 13).fill(
                  active ? GMColor.accent : Color.white.opacity(0.05)))
          }
          .buttonStyle(PressButtonStyle())
          .disabled(!vm.canChangeRoundCount)
          .opacity(vm.canChangeRoundCount ? 1 : 0.5)
        }
      }
    }
  }

  private var payoffSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Add debt payoff")
        .font(GMFont.display(14, .bold)).foregroundStyle(GMColor.ink)
      HStack(spacing: 8) {
        ForEach(RoundsViewModel.Payoff.allCases) { p in
          let active = vm.payoff == p
          Button {
            vm.choosePayoff(p)
          } label: {
            Text(p.label)
              .font(GMFont.display(14, .bold))
              .foregroundStyle(active ? GMColor.onAccent : GMColor.ink.opacity(0.6))
              .frame(maxWidth: .infinity).frame(height: 42)
              .background(
                RoundedRectangle(cornerRadius: 13).fill(
                  active ? GMColor.debt : Color.white.opacity(0.05)))
          }
          .buttonStyle(PressButtonStyle())
          .disabled(!vm.canChangeRoundCount)
        }
      }
    }
  }

  private var roundsGrid: some View {
    LazyVGrid(
      columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10
    ) {
      ForEach(vm.rounds) { round in
        let done = vm.isCompleted(round.id)
        Button {
          vm.toggleRoundCompleted(round.id)
        } label: {
          VStack(alignment: .leading, spacing: 10) {
            HStack {
              Text("ROUND \(round.id)")
                .font(GMFont.body(11, .bold)).tracking(1)
                .foregroundStyle(GMColor.ink.opacity(0.45))
              Spacer()
              ZStack {
                Circle().fill(done ? GMColor.accent : Color.white.opacity(0.08))
                Text(done ? "✓" : "\(round.id)")
                  .font(GMFont.display(13, .bold))
                  .foregroundStyle(done ? GMColor.onAccent : GMColor.ink.opacity(0.55))
              }.frame(width: 24, height: 24)
            }
            Text("\(round.totalReps)")
              .font(GMFont.display(34, .bold))
              .foregroundStyle(done ? GMColor.accent : GMColor.ink)
              .monospacedDigit()
            Text("reps this round")
              .font(GMFont.body(12, .medium)).foregroundStyle(GMColor.ink.opacity(0.5))
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(16)
          .background(
            RoundedRectangle(cornerRadius: 18)
              .fill(done ? GMColor.accent.opacity(0.1) : Color.white.opacity(0.04))
              .overlay(
                RoundedRectangle(cornerRadius: 18).stroke(
                  done ? GMColor.accent.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)))
        }
        .buttonStyle(PressButtonStyle(scale: 0.98))
      }
    }
  }

  private var quickAdd: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Log extra reps")
        .font(GMFont.display(14, .bold)).foregroundStyle(GMColor.ink)
      HStack(spacing: 10) {
        ForEach([1, 5, 10], id: \.self) { n in
          Button {
            let earned = vm.logExtra(focusKey, n)
            toast.show("+\(earned.gmDollars)", "added to \(focusName)")
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
          } label: {
            Text("+\(n)")
              .font(GMFont.display(17, .bold)).foregroundStyle(GMColor.accent)
              .frame(maxWidth: .infinity).frame(height: 50)
              .background(
                RoundedRectangle(cornerRadius: 14).fill(GMColor.accent.opacity(0.08))
                  .overlay(
                    RoundedRectangle(cornerRadius: 14).stroke(
                      GMColor.accent.opacity(0.3), lineWidth: 1)))
          }
          .buttonStyle(PressButtonStyle())
        }
      }
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
  }

  private var focusName: String {
    faces.isEmpty ? "today" : faces[min(focus, faces.count - 1)].name
  }
}
