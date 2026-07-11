import SwiftUI

/// Semantic color tokens — "Training Bank" dark spec (docs/ui-system.md).
/// One lime accent does the real work; coral is reserved for debt/loss only.
/// Token *names* are kept stable across the redesign so every surface stays
/// consistent. Values come straight from the approved design file.
enum GMColor {
  // Backdrop
  static let background = Color(hex: "#070A0D")  // page base
  static let stage = Color(hex: "#05080B")  // deepest layer
  static let surface = Color(white: 1, opacity: 0.04)  // panels / cards on backdrop
  static let elevated = Color(white: 1, opacity: 0.06)
  static let hairline = Color(white: 1, opacity: 0.08)  // borders
  static let hairlineStrong = Color(white: 1, opacity: 0.12)

  // Text
  static let ink = Color(hex: "#F2F5F0")  // primary text / numbers
  static let muted = Color(hex: "#F2F5F0").opacity(0.6)  // secondary text
  static let mutedSoft = Color(hex: "#F2F5F0").opacity(0.45)  // tertiary / captions
  static let faint = Color(hex: "#F2F5F0").opacity(0.3)

  // Accent (lime) — earnings, progress, primary action
  static let accent = Color(hex: "#C6F833")
  static let accentDeep = Color(hex: "#9BE000")
  static let accentPressed = Color(hex: "#A9D92B")
  static let onAccent = Color(hex: "#0A0D11")  // text on the accent fill

  // Semantic feedback
  static let success = Color(hex: "#C6F833")  // "all paid up" reuses the accent
  static let warning = Color(hex: "#FFC24B")  // in-progress / due
  static let debt = Color(hex: "#FF5B5B")  // debt / loss (coral)
  static let gold = Color(hex: "#FFD34D")

  // Legacy tokens (still referenced by the outgoing pixel views; retained so the
  // codebase compiles through the redesign — removed with those views later).
  static let hotline = Color(hex: "#6C742D")
  static let parchment = Color(hex: "#E8D8B8")
  static let parchmentLine = Color(hex: "#B08A54")
  static let parchmentInk = Color(hex: "#1C1710")

  // Wallet card gradient stops (graphite)
  static let cardTop = Color(hex: "#2B3138")
  static let cardMid = Color(hex: "#181C22")
  static let cardBot = Color(hex: "#12151A")

  /// Standard page background: a soft radial "living" gradient toward the top.
  static var pageGradient: RadialGradient {
    RadialGradient(
      colors: [Color(hex: "#141B22"), Color(hex: "#080B0F"), stage],
      center: .init(x: 0.5, y: -0.05),
      startRadius: 0,
      endRadius: 620
    )
  }

  /// The wallet / hero card fill.
  static var cardGradient: LinearGradient {
    LinearGradient(
      colors: [cardTop, cardMid, cardBot],
      startPoint: .init(x: 0.15, y: 0), endPoint: .init(x: 0.85, y: 1)
    )
  }
}
