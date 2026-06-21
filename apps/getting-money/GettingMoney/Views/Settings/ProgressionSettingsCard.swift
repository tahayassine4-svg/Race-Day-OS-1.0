import SwiftUI

struct NextProgressionCard: View {
  let viewModel: SettingsViewModel

  var body: some View {
    GMCard {
      HStack(spacing: GMSpacing.md) {
        Image("pixel_icon_dumbbell")
          .pixelArt()
          .frame(width: 40, height: 27)

        VStack(alignment: .leading, spacing: 3) {
          Text("Next auto-increase")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(GMColor.muted)

          Text(
            viewModel.autoProgressionEnabled
              ? "in \(viewModel.daysUntilNextProgression) days · +\(viewModel.progressionAmount) reps"
              : "off · manual targets only"
          )
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
        progressionRow(
          "Increase", value: viewModel.progressionAmount, suffix: "reps",
          minus: { viewModel.adjustProgressionAmount(by: -1) },
          plus: { viewModel.adjustProgressionAmount(by: 1) })
        Divider().overlay(GMColor.hairline)
        progressionRow(
          "Frequency", value: viewModel.progressionIntervalDays, suffix: "days",
          minus: { viewModel.adjustProgressionIntervalDays(by: -1) },
          plus: { viewModel.adjustProgressionIntervalDays(by: 1) })
      }
    }
  }

  private var toggleRow: some View {
    HStack(spacing: GMSpacing.md) {
      VStack(alignment: .leading, spacing: 3) {
        Text("Auto-increase")
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(GMColor.ink)

        Text(
          "Every \(viewModel.progressionIntervalDays) days · +\(viewModel.progressionAmount) reps"
        )
        .font(.gmMeta)
        .foregroundStyle(GMColor.muted)
      }

      Spacer()

      PixelToggle(
        isOn: viewModel.autoProgressionEnabled,
        label: "Auto-increase targets"
      ) {
        viewModel.setAutoProgressionEnabled(!viewModel.autoProgressionEnabled)
      }
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 16)
  }

  private func progressionRow(
    _ title: String, value: Int, suffix: String, minus: @escaping () -> Void,
    plus: @escaping () -> Void
  ) -> some View {
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

      PixelStepButton(kind: .minus, label: "Decrease \(title)", action: minus)
      Text("\(value)")
        .font(.system(size: 18, weight: .bold))
        .monospacedDigit()
        .foregroundStyle(GMColor.ink)
        .frame(minWidth: 34)
      PixelStepButton(kind: .plus, label: "Increase \(title)", action: plus)
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 12)
  }
}
