import SwiftUI

struct LogExerciseCard: View {
    let row: RepLoggerViewModel.Row
    let viewModel: RepLoggerViewModel
    let reduceMotion: Bool

    var body: some View {
        GMCard {
            VStack(alignment: .leading, spacing: GMSpacing.md) {
                HStack(spacing: GMSpacing.md) {
                    Image(systemName: row.glyph)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(GMColor.ink)
                        .frame(width: 38, height: 38)
                        .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(GMColor.elevated))
                        .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))

                    Text(row.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(GMColor.ink)
                    Spacer()
                    (Text(row.displayed.gmGrouped).foregroundStyle(GMColor.ink)
                     + Text(" / \(row.target.gmGrouped)").foregroundStyle(GMColor.muted))
                        .font(.system(size: 14, weight: .semibold))
                        .monospacedDigit()
                }

                GMProgressBar(fraction: row.fraction, height: 7)

                HStack(spacing: GMSpacing.md) {
                    stepButton("minus", label: "Decrease \(row.name)") { adjust(-1) }
                    Text(row.displayed.gmGrouped)
                        .font(.system(size: 26, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(GMColor.ink)
                        .frame(minWidth: 54)
                    stepButton("plus", label: "Increase \(row.name)") { adjust(1) }
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

    private func quickAddButton(_ amount: Int) -> some View {
        Button("+\(amount)") { adjust(amount) }
            .font(.system(size: 14, weight: .bold))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .foregroundStyle(GMColor.accent)
            .frame(maxWidth: .infinity, minHeight: 42)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GMColor.accent.opacity(0.10)))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GMColor.accent.opacity(0.34), lineWidth: 1))
    }

    private func stepButton(_ systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(GMColor.ink)
                .frame(width: 46, height: 46)
                .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(GMColor.elevated))
                .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
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
