import SwiftUI

struct TargetSettingsList: View {
    let viewModel: SettingsViewModel

    var body: some View {
        GMCard(padding: 0) {
            VStack(spacing: 0) {
                ForEach(Array(viewModel.rows.enumerated()), id: \.element.id) { index, row in
                    if index > 0 { Divider().overlay(GMColor.hairline) }
                    TargetSettingsRow(row: row, viewModel: viewModel)
                }
            }
        }
    }
}

private struct TargetSettingsRow: View {
    let row: SettingsViewModel.Row
    let viewModel: SettingsViewModel

    var body: some View {
        HStack(spacing: GMSpacing.md + 2) {
            Image(systemName: row.glyph)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(row.isEnabled ? GMColor.ink : GMColor.muted)
                .frame(width: 38, height: 38)
                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(GMColor.elevated))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
                Text(row.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(GMColor.ink)

                Text(subtitle)
                    .font(.gmMeta)
                    .foregroundStyle(GMColor.muted)
            }

            Spacer()

            // The target stepper shows whenever the exercise is on; optional
            // exercises always keep a toggle so they can be turned back OFF.
            HStack(spacing: GMSpacing.md) {
                if row.isEnabled {
                    TargetStepper(row: row, viewModel: viewModel)
                }
                if row.isOptional {
                    Toggle("", isOn: Binding(
                        get: { row.isEnabled },
                        set: { viewModel.setEnabled(row.id, $0) }
                    ))
                    .labelsHidden()
                    .tint(GMColor.accent)
                    .accessibilityLabel("\(row.isEnabled ? "Disable" : "Enable") \(row.name)")
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .opacity(row.isEnabled ? 1 : 0.55)
    }

    private var subtitle: String {
        if row.isOptional && !row.isEnabled { return "optional · off" }
        if row.isOptional { return "optional · on" }
        return "reps / day"
    }
}

private struct TargetStepper: View {
    let row: SettingsViewModel.Row
    let viewModel: SettingsViewModel

    var body: some View {
        HStack(spacing: GMSpacing.md) {
            SettingsStepButton(systemName: "minus", label: "Decrease \(row.name)") {
                viewModel.adjustTarget(row.id, by: -5)
            }

            Text("\(row.target.gmGrouped)")
                .font(.system(size: 20, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(GMColor.ink)
                .frame(minWidth: 44)

            SettingsStepButton(systemName: "plus", label: "Increase \(row.name)") {
                viewModel.adjustTarget(row.id, by: 5)
            }
        }
    }
}

struct SettingsStepButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(GMColor.ink)
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(GMColor.elevated))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
