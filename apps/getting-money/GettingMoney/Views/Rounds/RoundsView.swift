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
            Text("ROUNDS · TODAY")
                .font(.system(size: 12, weight: .semibold)).tracking(1.4)
                .foregroundStyle(GMColor.muted)
            HStack(alignment: .top) {
                Text("\(viewModel.selectedRoundCount) rounds\nto hit zero.")
                    .font(.gmTitle).foregroundStyle(GMColor.ink)
                Spacer()
                Text("\(viewModel.completedCount) / \(viewModel.rounds.count) done")
                    .font(.system(size: 13, weight: .bold)).monospacedDigit()
                    .foregroundStyle(viewModel.allRoundsComplete ? GMColor.success : GMColor.muted)
                    .padding(.horizontal, 11).padding(.vertical, 6)
                    .background(Capsule().fill((viewModel.allRoundsComplete ? GMColor.success : GMColor.muted).opacity(0.14)))
            }
        }
    }

    private var roundCountStepper: some View {
        HStack(spacing: GMSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("How many rounds?")
                    .font(.system(size: 15, weight: .bold)).foregroundStyle(GMColor.ink)
                Text(viewModel.canChangeRoundCount ? "1–\(viewModel.maxRoundCount) circles" : "locked — undo a round to change")
                    .font(.gmMeta).foregroundStyle(GMColor.muted)
            }
            Spacer()
            stepButton("minus", enabled: viewModel.canChangeRoundCount && viewModel.selectedRoundCount > viewModel.minRoundCount) {
                viewModel.decrementRoundCount()
            }
            Text("\(viewModel.selectedRoundCount)")
                .font(.system(size: 22, weight: .heavy)).monospacedDigit()
                .foregroundStyle(GMColor.ink).frame(minWidth: 34)
            stepButton("plus", enabled: viewModel.canChangeRoundCount && viewModel.selectedRoundCount < viewModel.maxRoundCount) {
                viewModel.incrementRoundCount()
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GMColor.surface))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
    }

    private func stepButton(_ systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(enabled ? GMColor.accent : GMColor.muted)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(GMColor.accent.opacity(enabled ? 0.12 : 0.04)))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(systemName == "plus" ? "Add a round" : "Remove a round")
    }

    private var logicCard: some View {
        GMCard {
            HStack(spacing: GMSpacing.md) {
                Image(systemName: "circle.dotted")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(GMColor.accent)
                    .frame(width: 38, height: 38)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GMColor.accent.opacity(0.12)))
                Text("Targets split across your rounds. Tick a round off as you finish it — its reps drop into your balance.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(GMColor.muted)
            }
        }
    }

    private var payoffCard: some View {
        GMCard {
            VStack(alignment: .leading, spacing: GMSpacing.sm) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Fold in debt payoff").font(.system(size: 17, weight: .bold)).foregroundStyle(GMColor.ink)
                    Text("+\(viewModel.totalDebt.gmGrouped) reps owed · repaid in reps")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(GMColor.debt)
                }
                HStack(spacing: 6) {
                    ForEach(RoundsViewModel.Payoff.allCases) { option in
                        Button { viewModel.choosePayoff(option) } label: {
                            Text(option.label)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(option == viewModel.payoff ? GMColor.debt : GMColor.muted)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(GMColor.debt.opacity(option == viewModel.payoff ? 0.16 : 0)))
                        }
                        .buttonStyle(.plain)
                        .disabled(!viewModel.canChangeRoundCount)
                        .accessibilityLabel("\(option.label) debt payoff")
                        .accessibilityAddTraits(option == viewModel.payoff ? .isSelected : [])
                    }
                }
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(GMColor.elevated))
                .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
            }
        }
    }

    private var totalPreview: some View {
        GMCard {
            HStack {
                Text("Planned today").font(.system(size: 15, weight: .semibold)).foregroundStyle(GMColor.ink)
                Spacer()
                Text(plannedSummary)
                    .font(.system(size: 14, weight: .bold)).monospacedDigit().foregroundStyle(GMColor.muted)
            }
            if viewModel.roundsLoggedMoney > 0 {
                Text("+\(viewModel.roundsLoggedMoney.gmMoney) added from completed rounds")
                    .font(.gmMeta).foregroundStyle(GMColor.accent)
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
        Button { viewModel.completeNextRound() } label: {
            HStack(spacing: 8) {
                Image(systemName: viewModel.allRoundsComplete ? "checkmark.seal.fill" : "checkmark.circle.fill")
                    .font(.system(size: 17, weight: .bold))
                Text(ctaTitle).font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(GMColor.onAccent)
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GMColor.accent))
        }
        .disabled(viewModel.allRoundsComplete || viewModel.rounds.isEmpty)
        .opacity(viewModel.allRoundsComplete ? 0.6 : 1)
        .gmScreenPadding()
        .padding(.top, GMSpacing.md)
        .padding(.bottom, GMSpacing.sm)
        .background(.ultraThinMaterial)
    }

    private var ctaTitle: String {
        if viewModel.allRoundsComplete { return "All rounds done" }
        if let next = viewModel.nextIncompleteRound { return "Complete round \(next)" }
        return "Complete round"
    }
}
