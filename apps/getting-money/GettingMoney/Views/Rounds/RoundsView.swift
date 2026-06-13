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
                    debtPreview
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

    private var debtPreview: some View {
        GMCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Include debt payoff").font(.system(size: 17, weight: .bold)).foregroundStyle(GMColor.ink)
                    Text(viewModel.totalDebt > 0 ? "+\(viewModel.totalDebt.gmGrouped) reps ready for Packet 07" : "No rep debt today")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(viewModel.totalDebt > 0 ? GMColor.debt : GMColor.muted)
                }
                Spacer()
                Image(systemName: "lock.fill").foregroundStyle(GMColor.muted)
            }
        }
    }

    private var totalPreview: some View {
        GMCard {
            HStack {
                Text("Planned today").font(.system(size: 15, weight: .semibold)).foregroundStyle(GMColor.ink)
                Spacer()
                Text("\(viewModel.plannedTotal.gmGrouped) / \(viewModel.dailyTarget.gmGrouped) reps")
                    .font(.system(size: 14, weight: .bold)).monospacedDigit().foregroundStyle(GMColor.muted)
            }
            if viewModel.extraReps > 0 {
                Text("+\(viewModel.extraMoney.gmMoney) extra-money preview")
                    .font(.gmMeta).foregroundStyle(GMColor.accent)
            }
        }
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
