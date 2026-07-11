import SwiftUI

/// Publishes a scroll view's vertical offset (iOS 17-compatible, no
/// `onScrollGeometryChange`). Drop `ScrollOffsetReader(space:)` as the first
/// child inside the scroll content and read the value via `.onPreferenceChange`.
struct ScrollOffsetKey: PreferenceKey {
  static let defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

struct ScrollOffsetReader: View {
  let space: String
  var body: some View {
    GeometryReader { proxy in
      Color.clear.preference(
        key: ScrollOffsetKey.self,
        value: -proxy.frame(in: .named(space)).minY)
    }
    .frame(height: 0)
  }
}
