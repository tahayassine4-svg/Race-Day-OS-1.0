import SwiftUI

/// Soft glass card surface used across the app (docs/ui-system.md).
/// One elevated surface with a hairline border — no nested cards.
struct GMCard<Content: View>: View {
    var padding: CGFloat = GMSpacing.lg
    var tint: Color? = nil
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GMRadius.module, style: .continuous)
                    .fill(tint ?? GMColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GMRadius.module, style: .continuous)
                    .stroke(GMColor.hairline, lineWidth: 1)
            )
    }
}
