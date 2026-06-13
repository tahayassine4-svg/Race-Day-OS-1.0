import SwiftUI

/// Packet 01 Dashboard — premium bank hierarchy, sample data, matches design/packet-01.png.
struct DashboardView: View {
    private let model = DashboardSample.preview

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: GMSpacing.lg) {
                    header
                    balanceCard
                    dailyTargetCard
                    sectionHeader("Today's reps", action: "Log →")
                    GMCard(padding: 0) {
                        VStack(spacing: 0) {
                            ForEach(Array(model.exercises.enumerated()), id: \.element.id) { index, item in
                                if index > 0 { Divider().overlay(GMColor.hairline) }
                                ExerciseProgressRow(item: item)
                            }
                        }
                    }
                    if model.hasDebt { debtStrip }
                }
                .gmScreenPadding()
                .padding(.top, GMSpacing.xs)
                .padding(.bottom, GMSpacing.md)
            }
        }
        .safeAreaInset(edge: .bottom) { startRoundsCTA }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: GMSpacing.xs) {
            Text("CALISTHENICS BANK · TODAY")
                .font(.system(size: 12, weight: .semibold)).tracking(1.4)
                .foregroundStyle(GMColor.muted)
            HStack(alignment: .top) {
                Text("Make reps.\nStack money.")
                    .font(.gmTitle).foregroundStyle(GMColor.ink)
                Spacer()
                GMStatusPill(status: model.status)
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
                Text(model.bankBalance.gmMoney)
                    .font(.gmHero).monospacedDigit().foregroundStyle(GMColor.ink)
                    .padding(.top, GMSpacing.sm)
                HStack(spacing: 18) {
                    Label("\(model.streakDays) day streak", systemImage: "flame.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(GMColor.muted)
                    (Text("Today ").foregroundStyle(GMColor.muted)
                     + Text("+" + model.earnedToday.gmMoney).foregroundStyle(GMColor.accent))
                        .font(.system(size: 13, weight: .semibold)).monospacedDigit()
                }
                .padding(.top, GMSpacing.md)
            }
        }
    }

    private var coin: some View {
        ZStack {
            Circle().fill(GMColor.accent)
            Text("$").font(.system(size: 15, weight: .bold)).foregroundStyle(GMColor.onAccent)
        }.frame(width: 30, height: 30)
    }

    private var dailyTargetCard: some View {
        GMCard {
            VStack(alignment: .leading, spacing: GMSpacing.md) {
                HStack {
                    Text("Daily target").font(.system(size: 15, weight: .semibold)).foregroundStyle(GMColor.ink)
                    Spacer()
                    (Text(model.dailyCompleted.gmGrouped).foregroundStyle(GMColor.ink)
                     + Text(" / \(model.dailyTarget.gmGrouped) reps").foregroundStyle(GMColor.muted))
                        .font(.system(size: 14, weight: .semibold)).monospacedDigit()
                }
                GMProgressBar(fraction: model.dailyFraction)
            }
        }
    }

    private func sectionHeader(_ title: String, action: String) -> some View {
        HStack {
            Text(title.uppercased()).font(.gmSection).tracking(0.4).foregroundStyle(GMColor.muted)
            Spacer()
            Text(action).font(.system(size: 13, weight: .semibold)).foregroundStyle(GMColor.accent)
        }
    }

    private var debtStrip: some View {
        HStack {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: GMRadius.control, style: .continuous)
                        .fill(GMColor.debt.opacity(0.16))
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(GMColor.debt)
                }.frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Current rep debt").font(.system(size: 13, weight: .semibold)).foregroundStyle(GMColor.muted)
                    Text(model.repDebtValue.gmMoney + " · \(model.repDebtReps.gmGrouped) reps")
                        .font(.system(size: 18, weight: .bold)).monospacedDigit().foregroundStyle(GMColor.debt)
                }
            }
            Spacer()
            Text("Plan →").font(.system(size: 13, weight: .bold)).foregroundStyle(GMColor.debt)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: GMRadius.row, style: .continuous)
                .fill(GMColor.debt.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: GMRadius.row, style: .continuous)
                .stroke(GMColor.debt.opacity(0.28), lineWidth: 1)
        )
    }

    private var startRoundsCTA: some View {
        Button { } label: {
            HStack(spacing: 9) {
                Text("Start today's rounds").font(.system(size: 17, weight: .bold))
                Text("· 3 circles").font(.system(size: 13, weight: .semibold)).opacity(0.62)
            }
            .foregroundStyle(GMColor.onAccent)
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GMColor.accent)
            )
        }
        .gmScreenPadding()
        .padding(.top, GMSpacing.md)
        .padding(.bottom, GMSpacing.sm)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    DashboardView().preferredColorScheme(.dark)
}
