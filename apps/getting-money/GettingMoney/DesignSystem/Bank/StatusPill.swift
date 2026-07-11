import SwiftUI

/// The single-line status pill on the dashboard: a glowing dot + "Title · sub".
struct StatusPill: View {
  let tint: Color
  let title: String
  let subtitle: String
  var action: (() -> Void)? = nil

  var body: some View {
    let pill = HStack(spacing: 9) {
      Circle()
        .fill(tint)
        .frame(width: 8, height: 8)
        .shadow(color: tint.opacity(0.9), radius: 5)
      Text("\(title) · \(subtitle)")
        .font(GMFont.body(13, .semibold))
        .foregroundStyle(tint)
        .lineLimit(1)
    }
    .padding(.horizontal, 15)
    .padding(.vertical, 9)
    .background(
      Capsule().fill(tint.opacity(0.1))
        .overlay(Capsule().stroke(tint.opacity(0.25), lineWidth: 1))
    )

    if let action {
      Button(action: action) { pill }
        .buttonStyle(PressButtonStyle())
    } else {
      pill
    }
  }
}

/// Shared tap feel: a subtle scale-down on press (the design's `.gm-tap`).
struct PressButtonStyle: ButtonStyle {
  var scale: CGFloat = 0.96
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? scale : 1)
      .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
  }
}
