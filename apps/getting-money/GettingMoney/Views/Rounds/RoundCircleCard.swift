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
            RoundedRectangle(cornerRadius: GMRadius.module, style: .continuous)
                .stroke(isDone ? GMColor.success.opacity(0.5) : .clear, lineWidth: 1.5)
        )
        .background(
            RoundedRectangle(cornerRadius: GMRadius.module, style: .continuous)
                .fill(isDone ? GMColor.success.opacity(0.06) : .clear)
        )
    }

    private var headerRow: some View {
        HStack(spacing: GMSpacing.md) {
            ZStack {
                Circle().fill(isDone ? GMColor.success : GMColor.accent).frame(width: 42, height: 42)
                if isDone {
                    Image(systemName: "checkmark").font(.system(size: 18, weight: .heavy)).foregroundStyle(GMColor.onAccent)
                } else {
                    Text("\(round.id)").font(.system(size: 17, weight: .heavy)).foregroundStyle(GMColor.onAccent)
                }
            }
            Text("Circle \(round.id)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(GMColor.ink)
            Spacer()
            if round.payoffReps > 0 {
                Text("+ payoff")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(GMColor.debt)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(Capsule().fill(GMColor.debt.opacity(0.14)))
                    .overlay(Capsule().stroke(GMColor.debt.opacity(0.28), lineWidth: 1))
            }
        }
    }

    private var exerciseGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: GMSpacing.sm), count: 3), spacing: GMSpacing.sm) {
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
                            adjustButton("minus") { viewModel.adjust(roundID: round.id, exerciseKey: exercise.key, by: -1) }
                            adjustButton("plus") { viewModel.adjust(roundID: round.id, exerciseKey: exercise.key, by: 1) }
                        }
                    }
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GMColor.elevated))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
            }
        }
    }

    @ViewBuilder
    private var footerRow: some View {
        if isDone {
            HStack {
                Label("Done · added to balance", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(GMColor.success)
                Spacer()
                Button { viewModel.toggleRoundCompleted(round.id) } label: {
                    Text("Edit")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(GMColor.accent)
                        .padding(.horizontal, 16).padding(.vertical, 9)
                        .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(GMColor.accent.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Edit round \(round.id) (removes it from your balance)")
            }
        } else {
            Button { viewModel.toggleRoundCompleted(round.id) } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle").font(.system(size: 16, weight: .bold))
                    Text("Mark round \(round.id) done").font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(GMColor.onAccent)
                .frame(maxWidth: .infinity).frame(height: 46)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GMColor.accent))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Mark round \(round.id) done and add its reps to your balance")
        }
    }

    private func adjustButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(GMColor.accent)
                .frame(width: 30, height: 28)
                .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(GMColor.accent.opacity(0.10)))
        }
        .buttonStyle(.plain)
    }
}
