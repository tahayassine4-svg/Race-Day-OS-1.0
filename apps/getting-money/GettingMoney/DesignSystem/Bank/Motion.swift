import SwiftUI

extension View {
  /// One-shot staggered entrance: fades in while rising 10pt, offset by `delay`.
  /// Under Reduce Motion the view simply appears (no fade, no movement).
  func entrance(_ entered: Bool, delay: Double, reduceMotion: Bool) -> some View {
    self
      .opacity(reduceMotion || entered ? 1 : 0)
      .offset(y: reduceMotion || entered ? 0 : 10)
      .animation(
        reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.85).delay(delay),
        value: entered)
  }
}
