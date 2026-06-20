import SwiftUI

struct PixelCoinView: View {
  var size: CGFloat = 14

  var body: some View {
    Canvas { ctx, sz in
      let s = sz.width
      ctx.fill(
        Path(ellipseIn: CGRect(x: 0, y: 0, width: s, height: s)),
        with: .color(Color(hex: "#1A1A1A"))
      )
      ctx.fill(
        Path(ellipseIn: CGRect(x: s * 0.1, y: s * 0.1, width: s * 0.8, height: s * 0.8)),
        with: .color(Color(hex: "#FFD700"))
      )
      let hl = CGFloat(2)
      ctx.fill(
        Path(CGRect(x: s * 0.2, y: s * 0.2, width: hl, height: hl)),
        with: .color(.white.opacity(0.8))
      )
    }
    .frame(width: size, height: size)
  }
}
