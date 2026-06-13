import SwiftUI

struct RoundCircleCard: View {
    let round: PlannedRound
    let viewModel: RoundsViewModel

    var body: some View {
        GMCard {
            VStack(alignment: .leading, spacing: GMSpacing.md) {
                HStack(spacing: GMSpacing.md) {
                    Text("\(round.id)")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(GMColor.onAccent)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(GMColor.accent))
                    Text("Circle \(round.id)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(GMColor.ink)
                    Spacer()
                    Text("Edit").font(.system(size: 15, weight: .bold)).foregroundStyle(GMColor.accent)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: GMSpacing.sm), count: 3), spacing: GMSpacing.sm) {
                    ForEach(round.exercises, id: \.key) { exercise in
                        VStack(spacing: 6) {
                            Text(exercise.reps.gmGrouped)
                                .font(.system(size: 24, weight: .heavy))
                                .monospacedDigit()
                                .foregroundStyle(GMColor.ink)
                            Text(label(for: exercise))
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .foregroundStyle(GMColor.muted)
                            HStack(spacing: 8) {
                                adjustButton("minus") { viewModel.adjust(roundID: round.id, exerciseKey: exercise.key, by: -1) }
                                adjustButton("plus") { viewModel.adjust(roundID: round.id, exerciseKey: exercise.key, by: 1) }
                            }
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GMColor.elevated))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
                    }
                }
            }
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

    private func label(for target: RoundTarget) -> String {
        target.name.lowercased()
    }
}
