import SwiftUI

/// Segmented pixel progress used for daily target and per-exercise progress.
/// Discrete cells fill left-to-right — the same blocky language as the game HUD.
struct GMProgressBar: View {
  /// 0...1
  let fraction: Double
  var height: CGFloat = 10

  private let gap: CGFloat = 2

  var body: some View {
    GeometryReader { geo in
      let clamped = max(0.0, min(1.0, fraction))
      // Aim for ~12pt-wide cells, then snap the count to fit the width.
      let count: Int = max(8, Int(geo.size.width / 12))
      let cellWidth: CGFloat = (geo.size.width - gap * CGFloat(count - 1)) / CGFloat(count)
      let filledCount: Int = Int((clamped * Double(count)).rounded(.toNearestOrAwayFromZero))
      HStack(spacing: gap) {
        ForEach(0..<count, id: \.self) { i in
          let filled: Bool = i < filledCount
          RoundedRectangle(cornerRadius: 1)
            .fill(filled ? GMColor.accent : GMColor.elevated)
            .frame(width: cellWidth)
            .overlay(
              RoundedRectangle(cornerRadius: 1)
                .strokeBorder(GMColor.hairline, lineWidth: filled ? 0 : 1)
            )
        }
      }
    }
    .frame(height: height)
    .accessibilityElement()
    .accessibilityLabel("Progress")
    .accessibilityValue("\(Int((max(0, min(1, fraction))) * 100)) percent")
  }
}
