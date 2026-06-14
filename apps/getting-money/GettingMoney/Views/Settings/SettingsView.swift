import SwiftUI

/// Packet 03: target editing + progression settings.
/// Packet 08: beta data utilities (export / reset) + about.
struct SettingsView: View {
    @State private var vm: SettingsViewModel
    @State private var exportURL: URL?

    init(viewModel: SettingsViewModel) {
        _vm = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            ScreenBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: GMSpacing.lg) {
                    header
                    NextProgressionCard(viewModel: vm)
                    SettingsSectionHeader("DAILY TARGETS", action: "Edit")
                    TargetSettingsList(viewModel: vm)
                    SettingsSectionHeader("PROGRESSION")
                    ProgressionSettingsCard(viewModel: vm)
                    SettingsSectionHeader("DATA")
                    dataCard
                    SettingsSectionHeader("ABOUT")
                    aboutCard

                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .font(.gmMeta)
                            .foregroundStyle(GMColor.debt)
                    }
                }
                .gmScreenPadding()
                .padding(.top, GMSpacing.xs)
                .padding(.bottom, 96)
            }
        }
        .task {
            vm.applyDueProgression()
            refreshExport()
        }
        .confirmationDialog(
            "Reset all local data?",
            isPresented: $vm.showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset everything", role: .destructive) {
                vm.resetAllData()
                refreshExport()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This wipes every day, log, target and debt on this device and starts fresh. It can't be undone.")
        }
    }

    private var dataCard: some View {
        GMCard(padding: 0) {
            VStack(spacing: 0) {
                if let exportURL {
                    ShareLink(item: exportURL) {
                        SettingsActionRow(
                            glyph: "square.and.arrow.up",
                            title: "Export my data",
                            subtitle: "Share a JSON snapshot of all days & logs",
                            isDestructive: false
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Export my data as JSON")
                    Divider().overlay(GMColor.hairline)
                }
                Button { vm.showResetConfirmation = true } label: {
                    SettingsActionRow(
                        glyph: "trash",
                        title: "Reset all local data",
                        subtitle: "Wipes everything — asks to confirm first",
                        isDestructive: true
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Reset all local data")
                .accessibilityHint("Asks for confirmation before wiping")
            }
        }
    }

    private var aboutCard: some View {
        GMCard(padding: 0) {
            VStack(spacing: 0) {
                SettingsInfoRow(glyph: "info.circle", title: "Version", value: "\(vm.appVersion) (beta)")
                Divider().overlay(GMColor.hairline)
                SettingsInfoRow(glyph: "lock.shield", title: "Privacy", value: "No tracking · on-device")
            }
        }
    }

    private func refreshExport() {
        guard let data = vm.exportData() else { exportURL = nil; return }
        let url = FileManager.default.temporaryDirectory.appending(path: "getting-money-export.json")
        do {
            try data.write(to: url, options: .atomic)
            exportURL = url
        } catch {
            exportURL = nil
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: GMSpacing.xs) {
            Text("TARGETS · YOUR RULES")
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(GMColor.muted)

            Text("Your targets,\nyour rules.")
                .font(.gmTitle)
                .foregroundStyle(GMColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct SettingsActionRow: View {
    let glyph: String
    let title: String
    let subtitle: String
    let isDestructive: Bool

    var body: some View {
        HStack(spacing: GMSpacing.md) {
            Image(systemName: glyph)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isDestructive ? GMColor.debt : GMColor.ink)
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isDestructive ? GMColor.debt.opacity(0.14) : GMColor.elevated))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isDestructive ? GMColor.debt.opacity(0.3) : GMColor.hairline, lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15.5, weight: .semibold))
                    .foregroundStyle(isDestructive ? GMColor.debt : GMColor.ink)
                Text(subtitle).font(.system(size: 12, weight: .medium)).foregroundStyle(GMColor.muted)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .bold)).foregroundStyle(GMColor.muted)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

private struct SettingsInfoRow: View {
    let glyph: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: GMSpacing.md) {
            Image(systemName: glyph)
                .font(.system(size: 16, weight: .semibold)).foregroundStyle(GMColor.ink)
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(GMColor.elevated))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
            Text(title).font(.system(size: 15.5, weight: .semibold)).foregroundStyle(GMColor.ink)
            Spacer()
            Text(value).font(.system(size: 13, weight: .medium)).foregroundStyle(GMColor.muted)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

private struct SettingsSectionHeader: View {
    let title: String
    let action: String?

    init(_ title: String, action: String? = nil) {
        self.title = title
        self.action = action
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.gmSection)
                .tracking(0.4)
                .foregroundStyle(GMColor.muted)

            Spacer()

            if let action {
                Text(action)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(GMColor.accent)
            }
        }
    }
}

#Preview {
    let store = try! LocalStore(inMemory: true)
    SettingsView(viewModel: SettingsViewModel(repository: store.exerciseRepository, dataAdmin: store))
        .preferredColorScheme(.dark)
}
