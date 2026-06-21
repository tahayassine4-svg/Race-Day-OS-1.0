import SwiftUI

struct LogExerciseCard: View {
  let row: RepLoggerViewModel.Row
  let viewModel: RepLoggerViewModel
  let reduceMotion: Bool

  var body: some View {
    GMParchmentCard {
      VStack(alignment: .leading, spacing: GMSpacing.md) {
        HStack(spacing: GMSpacing.md) {
          exerciseIcon
          Text(row.name)
            .font(.system(size: 17, weight: .heavy, design: .monospaced))
            .foregroundStyle(GMColor.parchmentInk)
          Spacer()
          (Text(row.displayed.gmGrouped).foregroundStyle(GMColor.parchmentInk)
            + Text(" / \(row.target.gmGrouped)").foregroundStyle(GMColor.parchmentInk.opacity(0.6)))
            .font(.system(size: 14, weight: .heavy, design: .monospaced))
            .monospacedDigit()
        }

        GMProgressBar(fraction: row.fraction, height: 7)

        HStack(spacing: GMSpacing.md) {
          PixelStepButton(kind: .minus, label: "Decrease \(row.name)") { adjust(-1) }
          Text(row.displayed.gmGrouped)
            .font(.system(size: 28, weight: .heavy, design: .monospaced))
            .monospacedDigit()
            .foregroundStyle(GMColor.parchmentInk)
            .frame(minWidth: 54)
          PixelStepButton(kind: .plus, label: "Increase \(row.name)") { adjust(1) }
          Spacer(minLength: 0)
        }

        HStack(spacing: GMSpacing.sm) {
          ForEach(row.quickAdds, id: \.self) { amount in
            quickAddButton(amount)
          }
        }
      }
    }
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

  private var exerciseIcon: some View {
    Image(exerciseImageName)
      .pixelArt()
      .frame(width: 38, height: 44)
  }

  private func quickAddButton(_ amount: Int) -> some View {
    Button("+\(amount)") { adjust(amount) }
      .font(.system(size: 14, weight: .heavy, design: .monospaced))
      .lineLimit(1)
      .minimumScaleFactor(0.82)
      .foregroundStyle(GMColor.accent)
      .frame(maxWidth: .infinity, minHeight: 42)
      .background(Rectangle().fill(Color(hex: "#31451B")))
      .overlay(Rectangle().stroke(Color(hex: "#718C37"), lineWidth: 1.5))
  }

  private func adjust(_ amount: Int) {
    if reduceMotion {
      viewModel.adjust(row.id, by: amount)
    } else {
      withAnimation(.snappy(duration: 0.18)) {
        viewModel.adjust(row.id, by: amount)
      }
    }
  }
}
