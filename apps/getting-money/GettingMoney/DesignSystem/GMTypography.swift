import SwiftUI

/// Type roles — pixel-game register. Headlines, labels and numbers all use the
/// monospaced system face (SF Mono) for the blocky, arcade-HUD feel; body and
/// meta stay proportional for readability.
extension Font {
  static let gmHero = Font.system(size: 44, weight: .heavy, design: .monospaced)  // balance / debt hero
  static let gmTitle = Font.system(size: 25, weight: .heavy, design: .monospaced)  // screen title
  static let gmSection = Font.system(size: 12, weight: .heavy, design: .monospaced)  // section label
  static let gmBody = Font.system(size: 16, weight: .regular)
  static let gmValue = Font.system(size: 16, weight: .heavy, design: .monospaced)  // inline numbers
  static let gmMeta = Font.system(size: 12, weight: .medium, design: .monospaced)
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
