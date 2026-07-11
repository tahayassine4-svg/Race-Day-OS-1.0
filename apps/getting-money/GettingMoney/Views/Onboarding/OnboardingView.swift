import SwiftUI

/// First-launch intro: three concept slides then a "name your bank" card.
/// Additive to the app — gated by `@AppStorage("gm.onboardingComplete")`.
struct OnboardingView: View {
  @Binding var bankName: String
  let onDone: () -> Void

  @State private var step = 0
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var glow = false
  @FocusState private var nameFocused: Bool

  private struct Slide {
    let symbol: String
    let title: String
    let body: String
  }
  private let slides: [Slide] = [
    .init(
      symbol: "dollarsign", title: "Every rep is money",
      body: "Push-ups, pull-ups, squats. Each rep you complete earns $1 in your training bank."),
    .init(
      symbol: "nosign", title: "Misses become debt",
      body:
        "Fall short of a daily target and the gap becomes rep debt. Pay it back with extra reps — never with money."
    ),
    .init(
      symbol: "target", title: "Get your debt to zero",
      body: "Set targets, split them into rounds, and watch your bank grow every single day."),
    .init(
      symbol: "banknote", title: "Open your bank",
      body: "Name your training bank. You start at $0 — every rep from here grows it."),
  ]

  private var slide: Slide { slides[step] }
  private var isLast: Bool { step == slides.count - 1 }

  var body: some View {
    VStack(spacing: 0) {
      // progress dots
      HStack(spacing: 6) {
        ForEach(0..<slides.count, id: \.self) { i in
          Capsule()
            .fill(i <= step ? GMColor.accent : Color.white.opacity(0.12))
            .frame(height: 4)
            .animation(.easeInOut(duration: 0.3), value: step)
        }
      }
      .padding(.top, 8)
      .padding(.bottom, 34)

      Spacer()

      VStack(spacing: 26) {
        if isLast {
          WalletCard(
            bankName: bankName.isEmpty ? "Your Bank" : bankName, balance: 0, earned: 0, debt: 0
          )
          .transition(.scale(scale: 0.94).combined(with: .opacity))
        } else {
          ZStack {
            Circle()
              .fill(
                RadialGradient(
                  colors: [Color(hex: "#1D242B"), Color(hex: "#0A0D11")],
                  center: .init(x: 0.38, y: 0.28), startRadius: 4, endRadius: 90)
              )
              .overlay(Circle().stroke(GMColor.accent.opacity(0.12), lineWidth: 8))
              .frame(width: 130, height: 130)
              .shadow(color: GMColor.accent.opacity(glow ? 0.35 : 0.15), radius: 40)
            Image(systemName: slide.symbol)
              .font(.system(size: 48, weight: .bold))
              .foregroundStyle(GMColor.accent)
          }
        }

        Text(slide.title)
          .font(GMFont.display(30, .bold))
          .foregroundStyle(GMColor.ink)
          .multilineTextAlignment(.center)

        Text(slide.body)
          .font(GMFont.body(16))
          .foregroundStyle(GMColor.ink.opacity(0.6))
          .multilineTextAlignment(.center)
          .lineSpacing(3)
          .frame(maxWidth: 300)

        if isLast {
          TextField(
            "", text: $bankName, prompt: Text("Name your bank").foregroundColor(GMColor.mutedSoft)
          )
          .font(GMFont.display(16, .semibold))
          .foregroundStyle(GMColor.ink)
          .multilineTextAlignment(.center)
          .focused($nameFocused)
          .frame(height: 52)
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.05))
              .overlay(
                RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.12), lineWidth: 1)))
        }
      }
      .animation(.spring(response: 0.5, dampingFraction: 0.85), value: step)

      Spacer()

      VStack(spacing: 14) {
        Button(action: next) {
          Text(isLast ? "Start training" : "Continue")
            .font(GMFont.display(17, .bold))
            .foregroundStyle(GMColor.onAccent)
            .frame(maxWidth: .infinity).frame(height: 58)
            .background(RoundedRectangle(cornerRadius: 18).fill(GMColor.accent))
            .shadow(color: GMColor.accent.opacity(0.3), radius: 12, y: 8)
        }
        .buttonStyle(PressButtonStyle())

        Button(action: finish) {
          Text("Skip intro")
            .font(GMFont.body(14, .semibold))
            .foregroundStyle(GMColor.ink.opacity(0.4))
        }
      }
    }
    .padding(.horizontal, 26)
    .padding(.vertical, 24)
    .onAppear {
      guard !reduceMotion else { return }
      withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { glow = true }
    }
  }

  private func next() {
    if isLast {
      finish()
    } else {
      withAnimation { step += 1 }
    }
  }

  private func finish() {
    if bankName.trimmingCharacters(in: .whitespaces).isEmpty { bankName = "Your Bank" }
    onDone()
  }
}
