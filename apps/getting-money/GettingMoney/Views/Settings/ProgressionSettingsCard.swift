import SwiftUI

struct NextProgressionCard: View {
    let viewModel: SettingsViewModel

    var body: some View {
        GMCard {
            HStack(spacing: GMSpacing.md) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(GMColor.accent)
                    .frame(width: 40, height: 40)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GMColor.accent.opacity(0.12)))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GMColor.accent.opacity(0.25), lineWidth: 1))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Next auto-increase")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(GMColor.muted)

                    Text(viewModel.autoProgressionEnabled ? "in \(viewModel.daysUntilNextProgression) days · +\(viewModel.progressionAmount) reps" : "off · manual targets only")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(GMColor.ink)
                }

                Spacer()
            }
        }
    }
}

struct ProgressionSettingsCard: View {
    let viewModel: SettingsViewModel

    var body: some View {
        GMCard(padding: 0) {
            VStack(spacing: 0) {
                toggleRow
                Divider().overlay(GMColor.hairline)
                progressionRow("Increase", value: viewModel.progressionAmount, suffix: "reps", minus: { viewModel.adjustProgressionAmount(by: -1) }, plus: { viewModel.adjustProgressionAmount(by: 1) })
                Divider().overlay(GMColor.hairline)
                progressionRow("Frequency", value: viewModel.progressionIntervalDays, suffix: "days", minus: { viewModel.adjustProgressionIntervalDays(by: -1) }, plus: { viewModel.adjustProgressionIntervalDays(by: 1) })
                Divider().overlay(GMColor.hairline)
                progressionRow("Pull-up cap", value: viewModel.pullupCap, suffix: "auto max", minus: { viewModel.adjustPullupCap(by: -1) }, plus: { viewModel.adjustPullupCap(by: 1) })
            }
        }
    }

    private var toggleRow: some View {
        HStack(spacing: GMSpacing.md) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Auto-increase")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(GMColor.ink)

                Text("Every \(viewModel.progressionIntervalDays) days · +\(viewModel.progressionAmount) reps")
                    .font(.gmMeta)
                    .foregroundStyle(GMColor.muted)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { viewModel.autoProgressionEnabled },
                set: { viewModel.setAutoProgressionEnabled($0) }
            ))
            .labelsHidden()
            .tint(GMColor.accent)
            .accessibilityLabel("Auto-increase targets")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    private func progressionRow(_ title: String, value: Int, suffix: String, minus: @escaping () -> Void, plus: @escaping () -> Void) -> some View {
        HStack(spacing: GMSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(GMColor.ink)

                Text(suffix)
                    .font(.gmMeta)
                    .foregroundStyle(GMColor.muted)
            }

            Spacer()

            SettingsStepButton(systemName: "minus", label: "Decrease \(title)", action: minus)
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(GMColor.ink)
                .frame(minWidth: 34)
            SettingsStepButton(systemName: "plus", label: "Increase \(title)", action: plus)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }
}
