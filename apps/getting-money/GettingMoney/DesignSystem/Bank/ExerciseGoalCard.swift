import SwiftUI

/// A swipeable "today's goal" card on the dashboard: big progress number, a
/// drifting glow blob, and +1 / +10 quick-log buttons. The count springs when
/// it changes (the design's `gm-pop`).
struct ExerciseGoalCard: View {
  let name: String
  let glyph: String
  let done: Int
  let target: Int
  let debt: Int
  let onAdd1: () -> Void
  let onAdd10: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var pop = false

  private var tint: Color {
    if done >= target { return GMColor.accent }
    return debt > 0 ? GMColor.debt : GMColor.warning
  }
  private var fraction: CGFloat {
    target == 0 ? 0 : min(1, CGFloat(done) / CGFloat(target))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text(name)
          .font(GMFont.display(15, .semibold))
          .foregroundStyle(GMColor.ink)
        Spacer()
        Circle().fill(tint).frame(width: 9, height: 9)
          .shadow(color: tint.opacity(0.7), radius: 5)
      }

      HStack(alignment: .firstTextBaseline, spacing: 7) {
        Text("\(done)")
          .font(GMFont.display(50, .bold))
          .foregroundStyle(GMColor.ink)
          .monospacedDigit()
          .contentTransition(.numericText(value: Double(done)))
          .animation(reduceMotion ? nil : .snappy(duration: 0.4), value: done)
          .scaleEffect(pop ? 1.16 : 1, anchor: .bottomLeading)
        Text("/ \(target)")
          .font(GMFont.display(16, .medium))
          .foregroundStyle(GMColor.ink.opacity(0.4))
      }
      .padding(.top, 18)

      // progress
      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule().fill(Color.white.opacity(0.08))
          Capsule().fill(tint)
            .frame(width: geo.size.width * fraction)
            .shadow(color: tint.opacity(0.6), radius: 6)
        }
      }
      .frame(height: 5)
      .padding(.top, 16)

      HStack {
        Image(systemName: glyph)
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(tint)
          .frame(width: 38, height: 38)
          .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.35)))
        Spacer()
        Button(action: {
          bump()
          onAdd10()
        }) {
          Text("+10")
            .font(GMFont.display(14, .bold))
            .foregroundStyle(GMColor.ink.opacity(0.8))
            .frame(height: 38).padding(.horizontal, 13)
            .background(
              RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05))
                .overlay(
                  RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1)
                ))
        }
        .buttonStyle(PressButtonStyle())
        Button(action: {
          bump()
          onAdd1()
        }) {
          Image(systemName: "plus")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(GMColor.onAccent)
            .frame(width: 46, height: 38)
            .background(RoundedRectangle(cornerRadius: 12).fill(GMColor.accent))
            .shadow(color: GMColor.accent.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(PressButtonStyle())
      }
      .padding(.top, 18)
    }
    .padding(20)
    .frame(width: 236)
    .background(
      RoundedRectangle(cornerRadius: GMRadius.cardLarge, style: .continuous)
        .fill(
          LinearGradient(
            colors: [Color(hex: "#202830"), Color(hex: "#13171C")],
            startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
          RoundedRectangle(cornerRadius: GMRadius.cardLarge, style: .continuous)
            .stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
    .overlay(alignment: .topTrailing) {
      Circle()
        .fill(
          RadialGradient(
            colors: [tint.opacity(0.33), .clear], center: .center, startRadius: 0, endRadius: 85)
        )
        .frame(width: 170, height: 170)
        .offset(x: 40, y: -50)
        .blur(radius: 4)
        .allowsHitTesting(false)
    }
    .clipShape(RoundedRectangle(cornerRadius: GMRadius.cardLarge, style: .continuous))
    .shadow(color: .black.opacity(0.4), radius: 20, y: 12)
  }

  private func bump() {
    guard !reduceMotion else { return }
    withAnimation(.spring(response: 0.28, dampingFraction: 0.5)) { pop = true }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { pop = false }
    }
  }
}
