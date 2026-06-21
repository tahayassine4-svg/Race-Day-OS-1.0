import SwiftUI

struct RoundCircleCard: View {
  let round: PlannedRound
  let viewModel: RoundsViewModel

  private var isDone: Bool { viewModel.isCompleted(round.id) }

  var body: some View {
    GMCard {
      VStack(alignment: .leading, spacing: GMSpacing.md) {
        headerRow
        exerciseGrid
        footerRow
      }
    }
    .overlay(
      Rectangle()
        .stroke(isDone ? GMColor.success.opacity(0.5) : .clear, lineWidth: 1.5)
    )
    .background(
      Rectangle()
        .fill(isDone ? GMColor.success.opacity(0.06) : .clear)
    )
  }

  private var headerRow: some View {
    HStack(spacing: GMSpacing.md) {
      ZStack {
        Rectangle()
          .fill(isDone ? GMColor.success : GMColor.accent)
          .frame(width: 42, height: 42)
        if isDone {
          GMPixelIcon(kind: .check, size: 28, color: GMColor.onAccent)
        } else {
          Text("\(round.id)")
            .font(.system(size: 17, weight: .heavy, design: .monospaced))
            .foregroundStyle(GMColor.onAccent)
        }
      }
      Text("Round \(round.id)")
        .font(.system(size: 20, weight: .heavy, design: .monospaced))
        .foregroundStyle(GMColor.ink)
      Spacer()
      if round.payoffReps > 0 {
        Text("+ payoff")
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(GMColor.debt)
          .padding(.horizontal, 9).padding(.vertical, 4)
          .background(Rectangle().fill(GMColor.debt.opacity(0.14)))
          .overlay(Rectangle().stroke(GMColor.debt.opacity(0.28), lineWidth: 1))
      }
    }
  }

  private var exerciseGrid: some View {
    LazyVGrid(
      columns: Array(repeating: GridItem(.flexible(), spacing: GMSpacing.sm), count: 3),
      spacing: GMSpacing.sm
    ) {
      ForEach(round.exercises, id: \.key) { exercise in
        VStack(spacing: 6) {
          Text(exercise.reps.gmGrouped)
            .font(.system(size: 24, weight: .heavy))
            .monospacedDigit()
            .foregroundStyle(GMColor.ink)
          Text(exercise.name.lowercased())
            .font(.system(size: 12, weight: .medium))
            .lineLimit(1).minimumScaleFactor(0.75)
            .foregroundStyle(GMColor.muted)
          if exercise.payoffReps > 0 {
            Text("+\(exercise.payoffReps) owed")
              .font(.system(size: 10.5, weight: .bold)).monospacedDigit()
              .foregroundStyle(GMColor.debt)
          }
          // Steppers only when the round is still open for editing.
          if !isDone {
            HStack(spacing: 8) {
              adjustButton("minus", label: "Decrease \(exercise.name) in round \(round.id)") {
                viewModel.adjust(roundID: round.id, exerciseKey: exercise.key, by: -1)
              }
              adjustButton("plus", label: "Increase \(exercise.name) in round \(round.id)") {
                viewModel.adjust(roundID: round.id, exerciseKey: exercise.key, by: 1)
              }
            }
          }
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Rectangle().fill(GMColor.stage))
        .overlay(Rectangle().stroke(GMColor.hairline, lineWidth: 1))
      }
    }
  }

  @ViewBuilder
  private var footerRow: some View {
    if isDone {
      HStack {
        HStack(spacing: 7) {
          GMPixelIcon(kind: .check, size: 20, color: GMColor.success)
          Text("Done · added to balance")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(GMColor.success)
        }
        Spacer()
        Button {
          viewModel.toggleRoundCompleted(round.id)
        } label: {
          Text("Edit")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(GMColor.accent)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(Rectangle().fill(GMColor.accent.opacity(0.12)))
            .overlay(Rectangle().stroke(GMColor.hotline, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Edit round \(round.id) (removes it from your balance)")
      }
    } else {
      Button {
        viewModel.toggleRoundCompleted(round.id)
      } label: {
        HStack(spacing: 8) {
          GMPixelIcon(kind: .check, size: 20, color: GMColor.onAccent)
          Text("Mark round \(round.id) done").font(.system(size: 15, weight: .bold))
        }
        .foregroundStyle(GMColor.onAccent)
        .frame(maxWidth: .infinity).frame(height: 46)
        .background(Rectangle().fill(GMColor.accent))
        .overlay(Rectangle().stroke(GMColor.hotline, lineWidth: 1.5))
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Mark round \(round.id) done and add its reps to your balance")
    }
  }

  private func adjustButton(_ systemName: String, label: String, action: @escaping () -> Void)
    -> some View
  {
    Button(action: action) {
      GMPixelIcon(
        kind: systemName == "plus" ? .plus : .minus,
        size: 30,
        color: GMColor.accent
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(label)
  }
}
