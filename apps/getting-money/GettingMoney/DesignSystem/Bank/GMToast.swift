import SwiftUI

/// A transient earnings toast: "+$12  ·  paid $8 debt · +$4 bonus".
struct GMToast: Identifiable, Equatable {
  let id = UUID()
  let main: String
  let sub: String
}

/// Floating toast host. Overlay this above the tab bar; it animates in/out
/// whenever `toast` changes and auto-clears after a delay.
struct GMToastView: View {
  let toast: GMToast

  var body: some View {
    HStack(spacing: 10) {
      Text(toast.main)
        .font(GMFont.display(17, .bold))
        .foregroundStyle(GMColor.accent)
      Text(toast.sub)
        .font(GMFont.body(13, .medium))
        .foregroundStyle(GMColor.ink.opacity(0.6))
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(GMColor.accent.opacity(0.3), lineWidth: 1))
    )
    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }
}
