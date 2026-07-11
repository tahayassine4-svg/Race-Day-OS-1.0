import SwiftUI

/// Type roles — Space Grotesk for display + numbers, Manrope for body/meta
/// (Training Bank spec). The `gm*` names are kept stable across the redesign so
/// existing call sites keep working; the faces underneath are now the bundled
/// brand fonts.
extension Font {
  static let gmHero = GMFont.display(44, .bold)  // balance / debt hero
  static let gmTitle = GMFont.display(24, .bold)  // screen title
  static let gmSection = GMFont.display(18, .bold)  // section label
  static let gmEyebrow = GMFont.body(13, .semibold)  // small caps-ish label
  static let gmBody = GMFont.body(16, .regular)
  static let gmValue = GMFont.display(16, .semibold)  // inline numbers
  static let gmMeta = GMFont.body(13, .medium)
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
