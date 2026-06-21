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
  static let screen: CGFloat = 20
}

/// Corner-radius scale — pixel-game sharp: controls 3 · rows 3 · modules 4.
/// Kept as named roles so every surface stays consistent; the small values
/// read as crisp pixel corners against the monospaced type and segmented bars.
enum GMRadius {
  static let control: CGFloat = 3
  static let row: CGFloat = 3
  static let module: CGFloat = 4
}
