import Foundation

/// Deterministic, locale-independent number formatting so the UI matches the
/// approved design (US-style "1,284") regardless of the device region.
/// Interpolate these Strings into Text to bypass SwiftUI's locale formatting.
extension Int {
  /// Grouped integer, e.g. 1284 -> "1,284".
  var gmGrouped: String {
    Self.grouping.string(from: NSNumber(value: self)) ?? "\(self)"
  }

  /// Coin count with no currency symbol — pair inline with PixelCoinView.
  /// The app's currency metaphor is the pixel coin, never a dollar sign.
  var gmCoins: String { gmGrouped }

  private static let grouping: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.groupingSeparator = ","
    f.usesGroupingSeparator = true
    f.maximumFractionDigits = 0
    return f
  }()
}
