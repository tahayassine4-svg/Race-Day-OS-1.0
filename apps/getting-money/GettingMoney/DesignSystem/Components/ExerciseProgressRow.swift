import SwiftUI

/// One exercise row: glyph, name (+ optional coral "owed" marker), progress fill, value.
struct ExerciseProgressRow: View {
    let item: ExerciseProgressSample

    var body: some View {
        HStack(spacing: GMSpacing.md + 2) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(GMColor.elevated)
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(GMColor.hairline, lineWidth: 1))
                Image(systemName: item.glyph)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(GMColor.ink)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(item.name).font(.system(size: 15, weight: .semibold)).foregroundStyle(GMColor.ink)
                    if item.repsOwed > 0 { owedTag }
                }
                GMProgressBar(fraction: item.fraction, height: 7)
            }

            VStack(alignment: .trailing, spacing: 2) {
                (Text(item.completed.gmGrouped).foregroundStyle(GMColor.ink)
                 + Text("/\(item.target.gmGrouped)").foregroundStyle(GMColor.muted))
                    .font(.gmValue).monospacedDigit()
                Text("\(item.remaining) to go").font(.gmMeta).foregroundStyle(GMColor.muted)
            }
            .frame(minWidth: 74, alignment: .trailing)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.name)
        .accessibilityValue("\(item.completed) of \(item.target) reps\(item.repsOwed > 0 ? ", \(item.repsOwed) owed" : "")")
    }

    private var owedTag: some View {
        Text("\(item.repsOwed) owed")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(GMColor.debt)
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(Capsule().fill(GMColor.debt.opacity(0.12)))
            .overlay(Capsule().stroke(GMColor.debt.opacity(0.25), lineWidth: 1))
    }
}
