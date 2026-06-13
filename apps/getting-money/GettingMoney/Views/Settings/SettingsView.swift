import SwiftUI

/// Packet 03: target editing + progression settings.
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
                    header
                    NextProgressionCard(viewModel: vm)
                    SettingsSectionHeader("DAILY TARGETS", action: "Edit")
                    TargetSettingsList(viewModel: vm)
                    SettingsSectionHeader("PROGRESSION")
                    ProgressionSettingsCard(viewModel: vm)

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
    SettingsView(viewModel: SettingsViewModel(repository: store.exerciseRepository))
        .preferredColorScheme(.dark)
}
