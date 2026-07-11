import CoreText
import SwiftUI

/// Bundled type system — Space Grotesk (display + numbers) and Manrope (body),
/// matching the Training Bank design spec. Both ship as variable fonts registered
/// at launch; `GMFont` resolves a weight against the wght axis.
enum GMFont {
  /// Family names as registered by Core Text from the bundled variable fonts.
  static let displayFamily = "Space Grotesk"
  static let bodyFamily = "Manrope"

  /// Display / numeric face (Space Grotesk).
  static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
    .custom(displayFamily, fixedSize: size).weight(weight)
  }

  /// Display face that scales with Dynamic Type (relative to a text style).
  static func display(
    _ size: CGFloat, weight: Font.Weight = .bold, relativeTo style: Font.TextStyle
  ) -> Font {
    .custom(displayFamily, size: size, relativeTo: style).weight(weight)
  }

  /// Body / meta face (Manrope).
  static func body(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
    .custom(bodyFamily, fixedSize: size).weight(weight)
  }

  static func body(
    _ size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle
  ) -> Font {
    .custom(bodyFamily, size: size, relativeTo: style).weight(weight)
  }
}

@MainActor
enum GMFontRegistration {
  private static var didRegister = false

  /// Registers the bundled variable fonts so `Font.custom(family:)` resolves.
  /// Idempotent — safe to call from `App.init` and from SwiftUI previews.
  static func registerIfNeeded() {
    guard !didRegister else { return }
    didRegister = true
    for name in ["SpaceGrotesk-VF", "Manrope-VF"] {
      guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
      var error: Unmanaged<CFError>?
      CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
    }
  }
}
