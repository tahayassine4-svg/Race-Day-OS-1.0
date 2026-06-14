import SwiftUI

struct RoundsView: View {
    let viewModel: RoundsViewModel

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: GMSpacing.lg) {
                    header
                    roundSelector
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
            Text("\(viewModel.selectedRoundCount) rounds\nto hit zero.")
                .font(.gmTitle).foregroundStyle(GMColor.ink)
        }
    }

    private var roundSelector: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.availableRoundCounts, id: \.self) { count in
                Button { viewModel.chooseRoundCount(count) } label: {
                    Text("\(count)")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(count == viewModel.selectedRoundCount ? GMColor.accent : GMColor.muted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(count == viewModel.selectedRoundCount ? GMColor.accent.opacity(0.16) : .clear))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GMColor.surface))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
    }

    private var logicCard: some View {
        GMCard {
            HStack(spacing: GMSpacing.md) {
                Image(systemName: "circle.dotted")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(GMColor.accent)
                    .frame(width: 38, height: 38)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GMColor.accent.opacity(0.12)))
                Text("Targets split automatically — uneven remainder goes to the earliest rounds.")
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
            if viewModel.payoffReps > 0 {
                Text("+\(viewModel.payoffReps.gmGrouped) reps go to debt payoff — not bonus money.")
                    .font(.gmMeta).foregroundStyle(GMColor.debt)
            }
            if viewModel.extraReps > 0 {
                Text("+\(viewModel.extraMoney.gmMoney) extra-money preview")
                    .font(.gmMeta).foregroundStyle(GMColor.accent)
            }
        }
    }

    private var plannedSummary: String {
        let base = "\(viewModel.plannedTotal.gmGrouped) / \(viewModel.dailyTarget.gmGrouped) reps"
        return viewModel.payoffReps > 0 ? base + " · +\(viewModel.payoffReps.gmGrouped) payoff" : base
    }

    private var startCTA: some View {
        Button { viewModel.save() } label: {
            HStack(spacing: 8) {
                Text("Start round 1").font(.system(size: 17, weight: .bold))
                Text("· of \(viewModel.selectedRoundCount)")
                    .font(.system(size: 13, weight: .semibold)).opacity(0.62)
            }
            .foregroundStyle(GMColor.onAccent)
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GMColor.accent))
        }
        .gmScreenPadding()
        .padding(.top, GMSpacing.md)
        .padding(.bottom, GMSpacing.sm)
        .background(.ultraThinMaterial)
    }
}
