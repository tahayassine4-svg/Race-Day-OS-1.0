import SwiftUI

struct DashboardView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: GMSpacing.lg) {
                    header
                    balanceCard
                    dailyTargetCard
                    sectionHeader("Today's reps", action: "Log →")
                    exerciseList
                    debtStrip
                }
                .gmScreenPadding()
                .padding(.top, GMSpacing.xs)
                .padding(.bottom, GMSpacing.md)
            }
        }
        .safeAreaInset(edge: .bottom) { startRoundsCTA }
        .onAppear { viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: GMSpacing.xs) {
            Text("CALISTHENICS BANK · TODAY")
                .font(.system(size: 12, weight: .semibold)).tracking(1.4)
                .foregroundStyle(GMColor.muted)
            HStack(alignment: .top) {
                Text("Make reps.\nStack money.")
                    .font(.gmTitle).foregroundStyle(GMColor.ink)
                Spacer()
                GMStatusPill(status: viewModel.status)
            }
        }
    }

    private var balanceCard: some View {
        GMCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("TOTAL BALANCE").font(.system(size: 12, weight: .semibold)).tracking(1.2)
                        .foregroundStyle(GMColor.muted)
                    Spacer()
                    coin
                }
                Text(viewModel.bankBalance.gmMoney)
                    .font(.gmHero).monospacedDigit().foregroundStyle(GMColor.ink)
                    .padding(.top, GMSpacing.sm)
                HStack(spacing: 18) {
                    Label("12 day streak", systemImage: "flame.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(GMColor.muted)
                    (Text("Today ").foregroundStyle(GMColor.muted)
                     + Text("+" + viewModel.earnedToday.gmMoney).foregroundStyle(GMColor.accent))
                        .font(.system(size: 13, weight: .semibold)).monospacedDigit()
                }
                .padding(.top, GMSpacing.md)
            }
        }
    }

    private var dailyTargetCard: some View {
        GMCard {
            VStack(alignment: .leading, spacing: GMSpacing.md) {
                HStack {
                    Text("Daily target").font(.system(size: 15, weight: .semibold)).foregroundStyle(GMColor.ink)
                    Spacer()
                    (Text(viewModel.dailyCompleted.gmGrouped).foregroundStyle(GMColor.ink)
                     + Text(" / \(viewModel.dailyTarget.gmGrouped) reps").foregroundStyle(GMColor.muted))
                        .font(.system(size: 14, weight: .semibold)).monospacedDigit()
                }
                GMProgressBar(fraction: viewModel.dailyTarget == 0 ? 0 : Double(viewModel.dailyCompleted) / Double(viewModel.dailyTarget))
            }
        }
    }

    private var exerciseList: some View {
        GMCard(padding: 0) {
            VStack(spacing: 0) {
                ForEach(Array(viewModel.rows.enumerated()), id: \.element.id) { index, item in
                    if index > 0 { Divider().overlay(GMColor.hairline) }
                    DashboardExerciseRow(item: item)
                }
            }
        }
    }

    private var debtStrip: some View {
        HStack {
            Text(viewModel.totalDebt > 0 ? "Current rep debt" : "Bonus earned today")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(GMColor.muted)
            Spacer()
            Text(viewModel.totalDebt > 0 ? "\(viewModel.totalDebt.gmMoney) · \(viewModel.totalDebt.gmGrouped) reps" : viewModel.bonusEarnedToday.gmMoney + " bonus")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(viewModel.totalDebt > 0 ? GMColor.debt : GMColor.accent)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: GMRadius.row, style: .continuous).fill(GMColor.surface))
        .overlay(RoundedRectangle(cornerRadius: GMRadius.row, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
    }

    private func sectionHeader(_ title: String, action: String) -> some View {
        HStack {
            Text(title.uppercased()).font(.gmSection).tracking(0.4).foregroundStyle(GMColor.muted)
            Spacer()
            Text(action).font(.system(size: 13, weight: .semibold)).foregroundStyle(GMColor.accent)
        }
    }

    private var coin: some View {
        ZStack {
            Circle().fill(GMColor.accent)
            Text("$").font(.system(size: 15, weight: .bold)).foregroundStyle(GMColor.onAccent)
        }.frame(width: 30, height: 30)
    }

    private var startRoundsCTA: some View {
        Button { } label: {
            HStack(spacing: 9) {
                Text("Start today's rounds").font(.system(size: 17, weight: .bold))
                Text("· 3 circles").font(.system(size: 13, weight: .semibold)).opacity(0.62)
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

private struct DashboardExerciseRow: View {
    let item: DashboardViewModel.ExerciseRow

    var body: some View {
        HStack(spacing: GMSpacing.md + 2) {
            Image(systemName: item.glyph)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(GMColor.ink)
                .frame(width: 38, height: 38)
                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(GMColor.elevated))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name).font(.system(size: 15, weight: .semibold)).foregroundStyle(GMColor.ink)
                GMProgressBar(fraction: item.fraction, height: 7)
            }
            VStack(alignment: .trailing, spacing: 2) {
                (Text(item.completed.gmGrouped).foregroundStyle(GMColor.ink)
                 + Text("/\(item.target.gmGrouped)").foregroundStyle(GMColor.muted))
                    .font(.gmValue).monospacedDigit()
                Text("\(item.remaining) to go").font(.gmMeta).foregroundStyle(GMColor.muted)
                if item.debtOwed > 0 {
                    Label("\(item.debtOwed) debt", systemImage: "exclamationmark.circle.fill")
                        .font(.gmMeta)
                        .foregroundStyle(GMColor.debt)
                }
            }
            .frame(minWidth: 74, alignment: .trailing)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }
}
