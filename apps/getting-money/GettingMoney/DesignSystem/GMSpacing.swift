import CoreGraphics

/// Spacing scale (docs/ui-system.md): 4 · 8 · 12 · 16 · 20 · 24 · 32.
enum GMSpacing {
  static let xs: CGFloat = 4
  static let sm: CGFloat = 8
  static let md: CGFloat = 12
  static let lg: CGFloat = 16
  static let xl: CGFloat = 20
  static let xxl: CGFloat = 24
  static let xxxl: CGFloat = 32

  /// Standard screen horizontal padding.
  static let screen: CGFloat = 22
}

/// Corner-radius scale — Training Bank soft spec: pills fully rounded, controls
/// 12–14, cards 18–28. Named roles keep every surface consistent.
enum GMRadius {
  static let control: CGFloat = 13  // chips / small buttons
  static let button: CGFloat = 18  // primary CTA
  static let row: CGFloat = 18  // list rows / small panels
  static let module: CGFloat = 22  // panels / charts
  static let card: CGFloat = 24  // wallet + hero cards
  static let cardLarge: CGFloat = 28  // exercise goal cards
  static let pill: CGFloat = 99  // status pills / progress tracks
}
