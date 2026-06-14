import SwiftUI

struct DashboardView: View {
    let viewModel: DashboardViewModel
    var onStartRounds: () -> Void = {}
    var onSetTargets: () -> Void = {}
    var onLogDate: (Date) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            ScreenBackground()
            if viewModel.hasActivity {
                populated
            } else {
                EmptyDashboard(onSetTargets: onSetTargets)
            }
        }
        .onAppear { viewModel.load(today: viewModel.selectedDate) }
    }

    private var populated: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GMSpacing.lg) {
                header
                balanceCard
                chartCard
                dailyTargetCard
                sectionHeader(viewModel.dailyRepsTitle, action: "Log →") {
                    onLogDate(viewModel.selectedDate)
                }
                exerciseList
                debtStrip
            }
            .gmScreenPadding()
            .padding(.top, GMSpacing.xs)
            .padding(.bottom, GMSpacing.md)
        }
        .safeAreaInset(edge: .bottom) { startRoundsCTA }
    }

    private var chartCard: some View {
        VStack(spacing: GMSpacing.sm) {
            TrendChart(points: viewModel.history, metric: viewModel.chartMetric)
            Picker("History metric", selection: Binding(
                get: { viewModel.chartMetric },
                set: { viewModel.chartMetric = $0 }
            )) {
                ForEach(DashboardViewModel.ChartMetric.allCases) { metric in
                    Text(metric.label).tag(metric)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: GMSpacing.xs) {
            HStack(spacing: GMSpacing.sm) {
                Text(viewModel.selectedDateEyebrow)
                    .font(.system(size: 12, weight: .semibold)).tracking(1.4)
                    .foregroundStyle(GMColor.muted)
                Spacer()
                daySwitcher
            }
            HStack(alignment: .top) {
                Text("Make reps.\nStack money.")
                    .font(.gmTitle).foregroundStyle(GMColor.ink)
                Spacer()
                GMStatusPill(status: viewModel.status)
            }
        }
    }

    private var daySwitcher: some View {
        HStack(spacing: 6) {
            dayButton(systemImage: "chevron.left", enabled: viewModel.canGoToPreviousDay) {
                viewModel.showPreviousDay()
            }
            Button { viewModel.showToday() } label: {
                Text(viewModel.selectedDateTitle)
                    .font(.system(size: 12, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(viewModel.isToday ? GMColor.onAccent : GMColor.ink)
                    .frame(minWidth: 64, minHeight: 32)
                    .padding(.horizontal, GMSpacing.xs)
                    .background(
                        Capsule(style: .continuous)
                            .fill(viewModel.isToday ? GMColor.accent : GMColor.elevated)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(viewModel.isToday ? GMColor.accent.opacity(0.35) : GMColor.hairline, lineWidth: 1)
                    )
            }
            .accessibilityLabel(viewModel.isToday ? "Showing today" : "Jump to today")
            dayButton(systemImage: "chevron.right", enabled: viewModel.canGoToNextDay) {
                viewModel.showNextDay()
            }
        }
    }

    private func dayButton(systemImage: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(enabled ? GMColor.ink : GMColor.muted.opacity(0.45))
                .frame(width: 32, height: 32)
                .background(Circle().fill(GMColor.elevated))
                .overlay(Circle().stroke(GMColor.hairline, lineWidth: 1))
        }
        .disabled(!enabled)
        .accessibilityLabel(systemImage == "chevron.left" ? "Previous day" : "Next day")
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
                CountUpMoney(value: viewModel.bankBalance, reduceMotion: reduceMotion)
                    .font(.gmHero).monospacedDigit().foregroundStyle(GMColor.ink)
                    .padding(.top, GMSpacing.sm)
                    .accessibilityLabel("Total balance, \(GMAccessibility.money(viewModel.bankBalance))")
                HStack(spacing: 18) {
                    Label("\(viewModel.streakDays) day streak", systemImage: "flame.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(GMColor.muted)
                        .accessibilityLabel(GMAccessibility.streak(days: viewModel.streakDays))
                    (Text("\(viewModel.earnedDateLabel) ").foregroundStyle(GMColor.muted)
                     + Text("+" + viewModel.earnedToday.gmMoney).foregroundStyle(GMColor.accent))
                        .font(.system(size: 13, weight: .semibold)).monospacedDigit()
                        .accessibilityLabel("Earned \(viewModel.earnedDateLabel), \(GMAccessibility.money(viewModel.earnedToday))")
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
                    DashboardExerciseRow(item: item) {
                        onLogDate(viewModel.selectedDate)
                    }
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.totalDebt > 0
            ? GMAccessibility.debt(reps: viewModel.totalDebt)
            : "Bonus earned today, \(GMAccessibility.money(viewModel.bonusEarnedToday))")
    }

    private func sectionHeader(_ title: String, action: String, perform: @escaping () -> Void) -> some View {
        HStack {
            Text(title.uppercased()).font(.gmSection).tracking(0.4).foregroundStyle(GMColor.muted)
            Spacer()
            Button(action, action: perform)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(GMColor.accent)
                .buttonStyle(.plain)
        }
    }

    private var coin: some View {
        ZStack {
            Circle().fill(GMColor.accent)
            Text("$").font(.system(size: 15, weight: .bold)).foregroundStyle(GMColor.onAccent)
        }.frame(width: 30, height: 30)
    }

    private var startRoundsCTA: some View {
        Button { onStartRounds() } label: {
            HStack(spacing: 9) {
                Text("Start today's rounds").font(.system(size: 17, weight: .bold))
                Text("· \(viewModel.plannedRoundCount) circles").font(.system(size: 13, weight: .semibold)).opacity(0.62)
            }
            .foregroundStyle(GMColor.onAccent)
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GMColor.accent))
        }
        .accessibilityLabel("Start today's rounds, \(viewModel.plannedRoundCount) circles")
        .gmScreenPadding()
        .padding(.top, GMSpacing.md)
        .padding(.bottom, GMSpacing.sm)
        .background(.ultraThinMaterial)
    }
}

private struct DashboardExerciseRow: View {
    let item: DashboardViewModel.ExerciseRow
    var onEdit: () -> Void = {}

    var body: some View {
        Button(action: onEdit) {
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
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            GMAccessibility.exerciseProgress(name: item.name, completed: item.completed, target: item.target)
            + (item.debtOwed > 0 ? ", \(item.debtOwed) reps owed" : "")
        )
    }
}

/// Animated bank balance. The digits roll to the new value via a numeric content
/// transition; Reduce Motion snaps straight to the value (Packet 08 a11y pass).
private struct CountUpMoney: View {
    let value: Int
    let reduceMotion: Bool
    @State private var shown = 0

    var body: some View {
        Text(shown.gmMoney)
            .contentTransition(.numericText())
            .onAppear { update(to: value) }
            .onChange(of: value) { _, newValue in update(to: newValue) }
    }

    private func update(to newValue: Int) {
        if reduceMotion {
            shown = newValue
        } else {
            withAnimation(.easeOut(duration: 0.5)) { shown = newValue }
        }
    }
}

/// First-launch empty state — no reps logged yet, nothing owed.
private struct EmptyDashboard: View {
    var onSetTargets: () -> Void = {}

    var body: some View {
        VStack(spacing: GMSpacing.md) {
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [GMColor.accent.opacity(0.5), GMColor.accent.opacity(0.08)],
                        center: .init(x: 0.35, y: 0.3), startRadius: 4, endRadius: 60))
                    .overlay(Circle().stroke(GMColor.accent.opacity(0.3), lineWidth: 1))
                    .frame(width: 84, height: 84)
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(GMColor.accent)
            }
            .accessibilityHidden(true)
            Text("Your bank is open.")
                .font(.system(size: 24, weight: .heavy)).foregroundStyle(GMColor.ink)
            Text("No reps logged yet, and nothing owed. Hit today's targets and every rep starts paying you.")
                .font(.system(size: 14.5, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(GMColor.muted)
                .padding(.horizontal, 40)
            Button { onSetTargets() } label: {
                Text("Set today's targets")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(GMColor.onAccent)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GMColor.accent))
            }
            .padding(.top, GMSpacing.xs)
            .padding(.horizontal, 28)
            .accessibilityHint("Opens Settings to review your daily targets")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, GMSpacing.lg)
    }
}
