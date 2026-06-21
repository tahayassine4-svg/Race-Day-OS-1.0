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
      pixelExerciseIcon

      VStack(alignment: .leading, spacing: 3) {
        Text(row.name)
          .font(.system(size: 17, weight: .bold))
          .foregroundStyle(GMColor.ink)
          .lineLimit(1)

        Text(subtitle)
          .font(.gmMeta)
          .foregroundStyle(GMColor.muted)
          .lineLimit(1)
      }

      Spacer(minLength: GMSpacing.sm)

      // The target stepper shows whenever the exercise is on; optional
      // exercises always keep a toggle so they can be turned back OFF.
      HStack(spacing: GMSpacing.sm) {
        if row.isEnabled {
          TargetStepper(row: row, viewModel: viewModel)
        }
        if row.isOptional {
          PixelToggle(
            isOn: row.isEnabled,
            label: "\(row.isEnabled ? "Disable" : "Enable") \(row.name)"
          ) {
            viewModel.setEnabled(row.id, !row.isEnabled)
          }
        }
      }
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 14)
    .opacity(row.isEnabled ? 1 : 0.55)
  }

  private var exerciseImageName: String {
    switch row.id {
    case "pushups": return "pixel_exercise_pushups"
    case "pullups": return "pixel_exercise_pullups"
    case "squats": return "pixel_exercise_squats"
    case "dips": return "pixel_exercise_dips"
    default:
      assertionFailure("Unknown exercise key: \(row.id)")
      return "pixel_exercise_pushups"
    }
  }

  private var pixelExerciseIcon: some View {
    Image(exerciseImageName)
      .pixelArt()
      .frame(width: 38, height: 44)
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
    HStack(spacing: GMSpacing.sm) {
      PixelStepButton(kind: .minus, label: "Decrease \(row.name)") {
        viewModel.adjustTarget(row.id, by: -5)
      }

      Text("\(row.target.gmGrouped)")
        .font(.system(size: 19, weight: .bold))
        .monospacedDigit()
        .foregroundStyle(GMColor.ink)
        .lineLimit(1)
        .fixedSize()
        .frame(minWidth: 40)

      PixelStepButton(kind: .plus, label: "Increase \(row.name)") {
        viewModel.adjustTarget(row.id, by: 5)
      }
    }
  }
}
