import SwiftUI

struct RoundsView: View {
  let viewModel: RoundsViewModel

  var body: some View {
    ZStack {
      ScreenBackground()
      ScrollView {
        VStack(alignment: .leading, spacing: GMSpacing.lg) {
          header
          roundCountStepper
          logicCard
          if viewModel.hasDebt { payoffCard }
          totalPreview
          ForEach(viewModel.rounds) { round in
            RoundCircleCard(round: round, viewModel: viewModel)
          }
          if let errorMessage = viewModel.errorMessage {
            Text(errorMessage).font(.gmMeta).foregroundStyle(GMColor.debt)
          }
        }
        .gmScreenPadding()
        .padding(.top, GMSpacing.xs)
        .padding(.bottom, 112)
      }
    }
    .safeAreaInset(edge: .bottom) { startCTA }
    .task { viewModel.load() }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: GMSpacing.xs) {
      Text("MISSION TODAY")
        .font(.system(size: 12, weight: .heavy, design: .monospaced)).tracking(1.4)
        .foregroundStyle(GMColor.muted)
      HStack(alignment: .top) {
        HStack(alignment: .top, spacing: GMSpacing.md) {
          Image("pixel_icon_swords")
            .pixelArt()
            .frame(width: 44, height: 39)
          Text("\(viewModel.selectedRoundCount) ROUNDS\nTO HIT ZERO.")
            .font(.gmTitle).foregroundStyle(GMColor.ink)
        }
        Spacer()
        Text("\(viewModel.completedCount) / \(viewModel.rounds.count) done")
          .font(.system(size: 13, weight: .bold)).monospacedDigit()
          .foregroundStyle(viewModel.allRoundsComplete ? GMColor.success : GMColor.muted)
          .padding(.horizontal, 10).padding(.vertical, 6)
          .background(
            Rectangle().fill(
              (viewModel.allRoundsComplete ? GMColor.success : GMColor.muted).opacity(0.14))
          )
          .overlay(Rectangle().stroke(GMColor.hairline, lineWidth: 1))
      }
    }
  }

  private var roundCountStepper: some View {
    HStack(spacing: GMSpacing.md) {
      VStack(alignment: .leading, spacing: 2) {
        Text("How many rounds?")
          .font(.system(size: 15, weight: .bold)).foregroundStyle(GMColor.ink)
        Text(
          viewModel.canChangeRoundCount
            ? "1–\(viewModel.maxRoundCount) circles" : "locked — undo a round to change"
        )
        .font(.gmMeta).foregroundStyle(GMColor.muted)
      }
      Spacer()
      PixelStepButton(
        kind: .minus,
        label: "Remove a round",
        enabled: viewModel.canChangeRoundCount
          && viewModel.selectedRoundCount > viewModel.minRoundCount
      ) { viewModel.decrementRoundCount() }
      Text("\(viewModel.selectedRoundCount)")
        .font(.system(size: 22, weight: .heavy)).monospacedDigit()
        .foregroundStyle(GMColor.ink).frame(minWidth: 34)
      PixelStepButton(
        kind: .plus,
        label: "Add a round",
        enabled: viewModel.canChangeRoundCount
          && viewModel.selectedRoundCount < viewModel.maxRoundCount
      ) { viewModel.incrementRoundCount() }
    }
    .padding(.horizontal, 16).padding(.vertical, 14)
    .background(Rectangle().fill(GMColor.surface))
    .overlay(Rectangle().strokeBorder(GMColor.hairline, lineWidth: 1.5))
  }

  private var logicCard: some View {
    GMCard {
      HStack(spacing: GMSpacing.md) {
        GMPixelIcon(kind: .target, size: 38, color: GMColor.accent)
        Text(
          "Targets split across your rounds. Tick a round off as you finish it — its reps drop into your balance."
        )
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(GMColor.muted)
      }
    }
  }

  private var payoffCard: some View {
    GMCard {
      VStack(alignment: .leading, spacing: GMSpacing.sm) {
        VStack(alignment: .leading, spacing: 3) {
          Text("Fold in debt payoff").font(.system(size: 17, weight: .heavy, design: .monospaced))
            .foregroundStyle(
              GMColor.ink)
          Text("+\(viewModel.totalDebt.gmGrouped) reps owed · repaid in reps")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(GMColor.debt)
        }
        HStack(spacing: 6) {
          ForEach(RoundsViewModel.Payoff.allCases) { option in
            Button {
              viewModel.choosePayoff(option)
            } label: {
              Text(option.label)
                .font(.system(size: 13, weight: .heavy, design: .monospaced))
                .foregroundStyle(option == viewModel.payoff ? GMColor.debt : GMColor.muted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                  Rectangle()
                    .fill(GMColor.debt.opacity(option == viewModel.payoff ? 0.16 : 0)))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canChangeRoundCount)
            .accessibilityLabel("\(option.label) debt payoff")
            .accessibilityAddTraits(option == viewModel.payoff ? .isSelected : [])
          }
        }
        .padding(5)
        .background(Rectangle().fill(GMColor.elevated))
        .overlay(Rectangle().stroke(GMColor.hairline, lineWidth: 1))
      }
    }
  }

  private var totalPreview: some View {
    GMCard {
      HStack {
        Text("Planned today").font(.system(size: 15, weight: .semibold)).foregroundStyle(
          GMColor.ink)
        Spacer()
        Text(plannedSummary)
          .font(.system(size: 14, weight: .bold)).monospacedDigit().foregroundStyle(GMColor.muted)
      }
      if viewModel.roundsLoggedMoney > 0 {
        HStack(spacing: 4) {
          PixelCoinView(size: 12)
          Text("+\(viewModel.roundsLoggedMoney.gmCoins) added from completed rounds")
            .font(.gmMeta).foregroundStyle(GMColor.accent)
        }
      }
      if viewModel.payoffReps > 0 {
        Text("+\(viewModel.payoffReps.gmGrouped) reps go to debt payoff — not bonus money.")
          .font(.gmMeta).foregroundStyle(GMColor.debt)
      }
    }
  }

  private var plannedSummary: String {
    let base = "\(viewModel.plannedTotal.gmGrouped) / \(viewModel.dailyTarget.gmGrouped) reps"
    return viewModel.payoffReps > 0 ? base + " · +\(viewModel.payoffReps.gmGrouped) payoff" : base
  }

  private var startCTA: some View {
    Button {
      viewModel.completeNextRound()
    } label: {
      HStack(spacing: 8) {
        GMPixelIcon(kind: .check, size: 20, color: GMColor.onAccent)
        Text(ctaTitle).font(.system(size: 17, weight: .bold))
      }
      .foregroundStyle(GMColor.onAccent)
      .frame(maxWidth: .infinity).frame(height: 56)
      .background(Rectangle().fill(GMColor.accent))
      .overlay(Rectangle().stroke(GMColor.hotline, lineWidth: 2))
    }
    .disabled(viewModel.allRoundsComplete || viewModel.rounds.isEmpty)
    .opacity(viewModel.allRoundsComplete ? 0.6 : 1)
    .gmScreenPadding()
    .padding(.top, GMSpacing.md)
    .padding(.bottom, GMSpacing.sm)
    .background(GMColor.background.opacity(0.94))
  }

  private var ctaTitle: String {
    if viewModel.allRoundsComplete { return "All rounds done" }
    if let next = viewModel.nextIncompleteRound { return "Complete round \(next)" }
    return "Complete round"
  }
}
