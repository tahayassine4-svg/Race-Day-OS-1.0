import SwiftUI

/// Pixel-game surface used across the app. One elevated surface with a crisp
/// 1.5pt hairline border and sharp corners — no nested cards, no soft glass.
struct GMCard<Content: View>: View {
  var padding: CGFloat = GMSpacing.lg
  var tint: Color? = nil
  var border: Color = GMColor.hairline
  @ViewBuilder var content: Content

  var body: some View {
    content
      .padding(padding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: GMRadius.module)
          .fill(tint ?? GMColor.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: GMRadius.module)
          .stroke(border, lineWidth: 1.5)
      )
      .overlay(alignment: .top) {
        Rectangle()
          .fill(Color.white.opacity(0.04))
          .frame(height: 1)
      }
  }
}

struct GMParchmentCard<Content: View>: View {
  var padding: CGFloat = GMSpacing.lg
  @ViewBuilder var content: Content

  var body: some View {
    content
      .padding(padding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .foregroundStyle(GMColor.parchmentInk)
      .background(
        Rectangle()
          .fill(GMColor.parchment)
          .overlay {
            PixelNoise(color: GMColor.parchmentLine.opacity(0.08), spacing: 8)
          }
      )
      .overlay(Rectangle().stroke(GMColor.parchmentLine, lineWidth: 2))
      .overlay(alignment: .top) {
        Rectangle().fill(Color.white.opacity(0.25)).frame(height: 2)
      }
      .overlay(alignment: .bottom) {
        Rectangle().fill(Color.black.opacity(0.12)).frame(height: 2)
      }
  }
}

struct PixelNoise: View {
  var color: Color
  var spacing: CGFloat = 10

  var body: some View {
    GeometryReader { proxy in
      let columns = max(1, Int(proxy.size.width / spacing))
      let rows = max(1, Int(proxy.size.height / spacing))
      Canvas { context, _ in
        for y in 0..<rows {
          for x in 0..<columns where (x * 7 + y * 11).isMultiple(of: 9) {
            let rect = CGRect(
              x: CGFloat(x) * spacing,
              y: CGFloat(y) * spacing,
              width: 1,
              height: 1
            )
            context.fill(Path(rect), with: .color(color))
          }
        }
      }
    }
    .allowsHitTesting(false)
  }
}
