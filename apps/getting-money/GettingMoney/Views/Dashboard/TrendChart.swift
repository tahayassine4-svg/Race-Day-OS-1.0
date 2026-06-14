import SwiftUI
import Charts

/// History chart for the dashboard (Packet 08). Switches between cumulative bank
/// balance, daily earnings, and streak activity over the last two weeks.
struct TrendChart: View {
    let points: [HistoryPoint]
    let metric: DashboardViewModel.ChartMetric

    private var change: Int {
        switch metric {
        case .balance:
            guard let first = points.first, let last = points.last else { return 0 }
            return last.cumulativeMoney - first.cumulativeMoney
        case .daily:
            return points.reduce(0) { $0 + $1.dailyMoney }
        case .streak:
            return points.reduce(0) { $0 + $1.dailyReps }
        }
    }

    var body: some View {
        GMCard(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .bold)).tracking(0.4)
                        .foregroundStyle(GMColor.muted)
                    Spacer()
                    Text(changeLabel)
                        .font(.system(size: 12.5, weight: .bold)).monospacedDigit()
                        .foregroundStyle(GMColor.accent)
                }
                .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 6)

                chart
                    .frame(height: 132)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 12)
                    .accessibilityLabel(accessibilitySummary)
            }
        }
    }

    @ViewBuilder private var chart: some View {
        Chart(points) { point in
            switch metric {
            case .balance:
                AreaMark(
                    x: .value("Day", point.date),
                    y: .value("Balance", point.cumulativeMoney)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(LinearGradient(
                    colors: [GMColor.accent.opacity(0.35), GMColor.accent.opacity(0.02)],
                    startPoint: .top, endPoint: .bottom))
                LineMark(
                    x: .value("Day", point.date),
                    y: .value("Balance", point.cumulativeMoney)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .foregroundStyle(GMColor.accent)
            case .daily:
                BarMark(
                    x: .value("Day", point.date, unit: .day),
                    y: .value("Earned", point.dailyMoney)
                )
                .cornerRadius(3)
                .foregroundStyle(GMColor.accent)
            case .streak:
                BarMark(
                    x: .value("Day", point.date, unit: .day),
                    y: .value("Reps", point.dailyReps)
                )
                .cornerRadius(3)
                .foregroundStyle(point.isActive ? GMColor.accent : GMColor.debt.opacity(0.55))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 2)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(GMColor.muted)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine().foregroundStyle(GMColor.hairline)
                AxisValueLabel().foregroundStyle(GMColor.muted)
            }
        }
    }

    private var title: String {
        switch metric {
        case .balance: "BANK BALANCE · 14 DAYS"
        case .daily: "DAILY EARNINGS · 14 DAYS"
        case .streak: "STREAK · LAST 14 DAYS"
        }
    }

    private var changeLabel: String {
        switch metric {
        case .balance: "▲ +" + change.gmMoney
        case .daily: "+" + change.gmMoney + " earned"
        case .streak: "\(change.gmGrouped) reps"
        }
    }

    private var accessibilitySummary: String {
        switch metric {
        case .balance: "Bank balance over 14 days, up \(change) dollars."
        case .daily: "Daily earnings over 14 days, \(change) dollars total."
        case .streak: "Streak chart, \(points.filter(\.isActive).count) active days of \(points.count)."
        }
    }
}
