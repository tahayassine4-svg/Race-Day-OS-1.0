import SwiftUI

/// The app's living backdrop: a deep radial gradient with two slow-drifting
/// aura blobs behind the top of the screen (dashboard only, per the design).
/// Motion respects Reduce Motion.
struct AmbientBackground: View {
  var showsAura: Bool = false
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var animate = false

  var body: some View {
    ZStack(alignment: .top) {
      GMColor.pageGradient
        .ignoresSafeArea()

      if showsAura {
        ZStack {
          Circle()
            .fill(
              RadialGradient(
                colors: [
                  GMColor.accent.opacity(0.55), Color(hex: "#78DC96").opacity(0.18), .clear,
                ],
                center: .center, startRadius: 0, endRadius: 160)
            )
            .frame(width: 320, height: 320)
            .offset(x: animate ? -18 : 0, y: animate ? 26 : -130)
            .scaleEffect(animate ? 1.22 : 1)
            .blur(radius: 48)
          Circle()
            .fill(
              RadialGradient(
                colors: [Color(hex: "#46C8FF").opacity(0.3), .clear],
                center: .center, startRadius: 0, endRadius: 120)
            )
            .frame(width: 240, height: 240)
            .offset(x: animate ? 40 : -70, y: animate ? -18 : -40)
            .scaleEffect(animate ? 1.3 : 1)
            .blur(radius: 56)
        }
        .frame(height: 380, alignment: .top)
        .frame(maxWidth: .infinity, alignment: .top)
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onAppear {
          guard !reduceMotion else { return }
          withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
            animate = true
          }
        }
      }
    }
  }
}
