import SwiftUI

/// Semantic color tokens — dark-first, from docs/ui-system.md.
/// One lime accent does the work; coral is reserved for debt/loss only.
enum GMColor {
  static let background = Color(hex: "#050806")
  static let stage = Color(hex: "#0A0D0B")
  static let surface = Color(hex: "#10140F")
  static let elevated = Color(hex: "#171D13")
  static let hairline = Color(hex: "#343829")
  static let hotline = Color(hex: "#6C742D")

  static let ink = Color(hex: "#F3F7F1")  // primary text / numbers
  static let muted = Color(hex: "#9A9485")  // secondary text

  static let accent = Color(hex: "#AEE63D")  // earnings, progress, primary action
  static let accentPressed = Color(hex: "#93C32F")
  static let onAccent = Color(hex: "#071006")  // text on the accent fill

  static let success = Color(hex: "#5FD08A")  // on track / paid
  static let warning = Color(hex: "#F2C14E")  // behind / due
  static let debt = Color(hex: "#E85D4F")  // debt / loss (coral)
  static let gold = Color(hex: "#FFD34D")
  static let parchment = Color(hex: "#E8D8B8")
  static let parchmentLine = Color(hex: "#B08A54")
  static let parchmentInk = Color(hex: "#1C1710")
}
