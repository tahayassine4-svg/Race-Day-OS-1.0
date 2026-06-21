import SwiftUI

/// Shared dark pixel canvas. No soft default gradients: the redesign uses a
/// low-contrast grid/noise layer so every tab stays in the game world.
struct ScreenBackground: View {
  var body: some View {
    GMColor.background
      .overlay {
        PixelNoise(color: GMColor.hairline.opacity(0.18), spacing: 8)
      }
      .ignoresSafeArea()
  }
}

extension View {
  func gmScreenBackground() -> some View {
    background(ScreenBackground())
  }
}
