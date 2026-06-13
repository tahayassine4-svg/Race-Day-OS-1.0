import SwiftUI

/// Titled placeholder for tabs whose functionality lands in a later packet.
/// Keeps every tab openable and on-brand in Packet 01.
struct ComingSoonScreen: View {
    let eyebrow: String
    let title: String
    let glyph: String
    let note: String

    var body: some View {
        ZStack {
            ScreenBackground()
            VStack(alignment: .leading, spacing: GMSpacing.lg) {
                VStack(alignment: .leading, spacing: GMSpacing.xs) {
                    Text(eyebrow.uppercased())
                        .font(.system(size: 12, weight: .semibold)).tracking(1.4)
                        .foregroundStyle(GMColor.muted)
                    Text(title).font(.gmTitle).foregroundStyle(GMColor.ink)
                }
                GMCard {
                    HStack(spacing: GMSpacing.md) {
                        Image(systemName: glyph)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(GMColor.accent)
                            .frame(width: 40, height: 40)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(GMColor.accent.opacity(0.12)))
                        Text(note).font(.gmBody).foregroundStyle(GMColor.muted)
                    }
                }
                Spacer()
            }
            .gmScreenPadding()
            .padding(.top, GMSpacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
