import SwiftUI

/// Packet 02: a persisted Settings section proving the data layer.
/// Shows the seeded exercises + their targets and lets dips be toggled — the
/// change persists across launches. Full target editing arrives in Packet 03.
struct SettingsView: View {
    @State private var vm: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _vm = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            ScreenBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: GMSpacing.lg) {
                    VStack(alignment: .leading, spacing: GMSpacing.xs) {
                        Text("TARGETS · YOUR RULES")
                            .font(.system(size: 12, weight: .semibold)).tracking(1.4)
                            .foregroundStyle(GMColor.muted)
                        Text("Your targets, your rules.")
                            .font(.gmTitle).foregroundStyle(GMColor.ink)
                    }

                    Text("EXERCISES")
                        .font(.gmSection).tracking(0.4).foregroundStyle(GMColor.muted)

                    GMCard(padding: 0) {
                        VStack(spacing: 0) {
                            ForEach(Array(vm.rows.enumerated()), id: \.element.id) { index, row in
                                if index > 0 { Divider().overlay(GMColor.hairline) }
                                exerciseRow(row)
                            }
                        }
                    }

                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .font(.gmMeta)
                            .foregroundStyle(GMColor.debt)
                    }

                    Text("Editing targets, the pull-up cap, and auto-progression arrive in Packet 03.")
                        .font(.gmMeta).foregroundStyle(GMColor.muted)
                }
                .gmScreenPadding()
                .padding(.top, GMSpacing.xs)
            }
        }
        .task {
            vm.load()
        }
    }

    private func exerciseRow(_ row: SettingsViewModel.Row) -> some View {
        HStack(spacing: GMSpacing.md + 2) {
            Image(systemName: row.glyph)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(row.isEnabled ? GMColor.ink : GMColor.muted)
                .frame(width: 38, height: 38)
                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(GMColor.elevated))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(row.name).font(.system(size: 15, weight: .semibold)).foregroundStyle(GMColor.ink)
                Text(row.isOptional ? "optional" : "\(row.target.gmGrouped) reps / day")
                    .font(.gmMeta).foregroundStyle(GMColor.muted)
            }
            Spacer()

            if row.isOptional {
                Toggle("", isOn: Binding(
                    get: { row.isEnabled },
                    set: { vm.setEnabled(row.id, $0) }
                ))
                .labelsHidden()
                .tint(GMColor.accent)
                .accessibilityLabel("Enable \(row.name)")
            } else {
                Text("\(row.target.gmGrouped)")
                    .font(.system(size: 17, weight: .bold)).monospacedDigit()
                    .foregroundStyle(GMColor.ink)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .opacity(row.isEnabled ? 1 : 0.55)
    }
}

#Preview {
    let store = try! LocalStore(inMemory: true)
    SettingsView(viewModel: SettingsViewModel(repository: store.exerciseRepository))
        .preferredColorScheme(.dark)
}
