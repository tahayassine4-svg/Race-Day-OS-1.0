import SwiftUI

/// The exercise picker as a flippable coin. Tapping (or swiping) advances to the
/// next exercise with a 3D Y-axis flip; the coin face shows the exercise glyph,
/// name, and a caption. Used on Rounds and Targets.
struct CoinFlipView: View {
  struct Face: Identifiable, Equatable {
    let id: String
    let name: String
    let glyph: String
    let caption: String
  }

  let faces: [Face]
  @Binding var index: Int

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var flip: Double = 0

  private var face: Face {
    faces.isEmpty
      ? Face(id: "", name: "—", glyph: "circle", caption: "") : faces[index % faces.count]
  }

  var body: some View {
    Button(action: advance) {
      ZStack {
        // ambient ring
        Circle()
          .fill(
            RadialGradient(
              colors: [GMColor.accent.opacity(0.16), .clear], center: .center, startRadius: 0,
              endRadius: 150)
          )
          .frame(width: 300, height: 300)

        Circle()
          .fill(
            RadialGradient(
              colors: [Color(hex: "#20272E"), Color(hex: "#0C0F13")],
              center: .init(x: 0.38, y: 0.3), startRadius: 4, endRadius: 170)
          )
          .overlay(Circle().stroke(GMColor.accent.opacity(0.25), lineWidth: 2))
          .overlay(
            Circle().strokeBorder(Color.white.opacity(0.05), lineWidth: 8).blur(radius: 3).padding(
              6)
          )
          .frame(width: 230, height: 230)
          .shadow(color: .black.opacity(0.5), radius: 30, y: 16)

        VStack(spacing: 12) {
          Image(systemName: face.glyph)
            .font(.system(size: 62, weight: .regular))
            .foregroundStyle(GMColor.accent)
          Text(face.name)
            .font(GMFont.display(22, .bold))
            .foregroundStyle(GMColor.ink)
          Text(face.caption)
            .font(GMFont.body(12, .semibold))
            .foregroundStyle(GMColor.mutedSoft)
        }
        // keep text readable through the flip (un-mirror past 90°)
        .scaleEffect(
          x: abs(flip.truncatingRemainder(dividingBy: 360)) > 90
            && abs(flip.truncatingRemainder(dividingBy: 360)) < 270 ? -1 : 1
        )
        .opacity(coinFaceOpacity)
      }
      .frame(width: 300, height: 300)
      .rotation3DEffect(.degrees(flip), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
      .contentShape(Circle())
    }
    .buttonStyle(PressButtonStyle(scale: 0.97))
    .highPriorityGesture(
      DragGesture(minimumDistance: 20)
        .onEnded { value in
          if value.translation.width < -20 {
            advance()
          } else if value.translation.width > 20 {
            retreat()
          }
        }
    )
    .accessibilityElement()
    .accessibilityLabel("\(face.name), \(face.caption)")
    .accessibilityHint("Double-tap to switch exercise")
    .accessibilityAddTraits(.isButton)
  }

  private var coinFaceOpacity: Double {
    let a = abs(flip.truncatingRemainder(dividingBy: 180))
    return a > 60 && a < 120 ? 0.25 : 1
  }

  private func advance() { step(+1) }
  private func retreat() { step(-1) }

  private func step(_ delta: Int) {
    guard !faces.isEmpty else { return }
    let next = ((index + delta) % faces.count + faces.count) % faces.count
    if reduceMotion {
      index = next
      return
    }
    withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
      flip += Double(delta) * 180
    }
    // swap the face at the midpoint so the incoming face reads correctly
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
      index = next
    }
  }
}
