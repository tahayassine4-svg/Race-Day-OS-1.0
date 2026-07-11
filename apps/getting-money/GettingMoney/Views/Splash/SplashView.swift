import SwiftUI

/// Decides whether the launch splash plays. Pure so it's unit-testable.
/// Automated flows (screenshot runs, UI fixtures) launch with -GMInitialScreen
/// or -GMSkipSplash and must land on their screen immediately.
enum SplashPolicy {
  static func shouldShow(arguments: [String]) -> Bool {
    !arguments.contains("-GMSkipSplash") && !arguments.contains("-GMInitialScreen")
  }
}

/// Branded cold-launch splash (approved design/packet-21-splash.png): the coin
/// drops in with a spring, lime rings pulse outward once, the wordmark fades up,
/// then the whole overlay cross-fades into the app. ~1.4s total.
/// Reduce Motion: everything appears static, then a plain fade-out.
struct SplashView: View {
  let onFinished: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var coinDown = false
  @State private var ringsOut = false
  @State private var wordUp = false

  var body: some View {
    ZStack {
      GMColor.pageGradient.ignoresSafeArea()
      VStack(spacing: 0) {
        rings
        wordmark
          .padding(.top, 34)
      }
      footer
    }
    .task(run)
    .accessibilityElement()
    .accessibilityLabel("Training Bank")
  }

  private var rings: some View {
    ZStack {
      ring(280, opacity: 0.06)
      ring(225, opacity: 0.12)
      ring(170, opacity: 0.22)
      coin
    }
    .frame(width: 280, height: 280)
  }

  private func ring(_ size: CGFloat, opacity: Double) -> some View {
    Circle()
      .stroke(GMColor.accent.opacity(opacity), lineWidth: 1)
      .frame(width: size, height: size)
      .scaleEffect(ringsOut ? 1 : 0.62)
      .opacity(ringsOut ? 1 : 0)
  }

  private var coin: some View {
    ZStack {
      Circle()
        .fill(
          RadialGradient(
            colors: [Color(hex: "#20272E"), Color(hex: "#0C0F13")],
            center: .init(x: 0.38, y: 0.3), startRadius: 4, endRadius: 90)
        )
        .overlay(Circle().stroke(GMColor.accent.opacity(0.45), lineWidth: 2))
        .overlay(
          Circle().strokeBorder(Color.white.opacity(0.05), lineWidth: 6).blur(radius: 2)
            .padding(7)
        )
        .shadow(color: .black.opacity(0.6), radius: 25, y: 12)
        .shadow(color: GMColor.accent.opacity(0.14), radius: 22)
      Text("$")
        .font(GMFont.display(52, .bold))
        .foregroundStyle(GMColor.accent)
    }
    .frame(width: 120, height: 120)
    .offset(y: coinDown ? 0 : -300)
    .opacity(coinDown ? 1 : 0)
  }

  private var wordmark: some View {
    VStack(spacing: 6) {
      Text("Training Bank")
        .font(GMFont.display(26, .bold))
        .foregroundStyle(GMColor.ink)
      Text("Reps in. Money up.")
        .font(GMFont.body(13, .semibold))
        .foregroundStyle(GMColor.mutedSoft)
    }
    .opacity(wordUp ? 1 : 0)
    .offset(y: wordUp ? 0 : 10)
  }

  private var footer: some View {
    VStack {
      Spacer()
      Text("GETTING MONEY")
        .font(GMFont.body(11, .bold))
        .tracking(3)
        .foregroundStyle(GMColor.faint)
        .padding(.bottom, 56)
    }
    .opacity(wordUp ? 1 : 0)
  }

  @Sendable private func run() async {
    if reduceMotion {
      coinDown = true
      ringsOut = true
      wordUp = true
    } else {
      withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) { coinDown = true }
      withAnimation(.easeOut(duration: 0.7).delay(0.35)) { ringsOut = true }
      withAnimation(.easeOut(duration: 0.5).delay(0.45)) { wordUp = true }
    }
    // Structured sleep: cancelled automatically if the splash disappears early.
    try? await Task.sleep(for: .seconds(reduceMotion ? 0.8 : 1.4))
    guard !Task.isCancelled else { return }
    onFinished()
  }
}

#Preview {
  SplashView {}
}
