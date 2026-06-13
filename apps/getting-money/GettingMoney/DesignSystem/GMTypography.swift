import SwiftUI

/// Type roles (docs/ui-system.md). Numbers use tabular figures.
extension Font {
    static let gmHero    = Font.system(size: 46, weight: .bold)          // balance / debt hero
    static let gmTitle   = Font.system(size: 27, weight: .bold)          // screen title
    static let gmSection = Font.system(size: 13, weight: .semibold)      // section label
    static let gmBody    = Font.system(size: 16, weight: .regular)
    static let gmValue   = Font.system(size: 16, weight: .bold)          // inline numbers
    static let gmMeta    = Font.system(size: 12.5, weight: .medium)
}

extension View {
    /// Tabular figures for any numeric text so digits align.
    func gmTabularNumbers() -> some View {
        monospacedDigit()
    }

    /// Standard screen horizontal padding.
    func gmScreenPadding() -> some View {
        padding(.horizontal, GMSpacing.screen)
    }
}
