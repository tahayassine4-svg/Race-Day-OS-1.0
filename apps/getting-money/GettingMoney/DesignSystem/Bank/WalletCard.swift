import SwiftUI

/// The Training Bank wallet card — the app's signature object. It appears on the
/// dashboard (where `collapse` is driven by scroll to shrink into a compact bar)
/// and, static, in onboarding. A slow diagonal sheen sweeps across it.
struct WalletCard: View {
  let bankName: String
  let balance: Int
  let earned: Int
  let debt: Int
  /// 0 = fully expanded, 1 = collapsed (driven by scroll on the dashboard).
  var collapse: CGFloat = 0

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var sheen = false

  private var p: CGFloat { min(1, max(0, collapse)) }

  var body: some View {
    let detailOpacity = max(0, 1 - p * 3.2)
    let nameOpacity = max(0, 1 - p * 2.6)

    VStack(alignment: .leading, spacing: 0) {
      // header
      HStack {
        Text("Training Bank")
          .font(GMFont.display(15, .bold))
          .foregroundStyle(GMColor.ink)
        Spacer()
        Image(systemName: "plus")
          .font(.system(size: 15, weight: .medium))
          .foregroundStyle(GMColor.ink)
          .frame(width: 28, height: 28)
          .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.08)))
      }

      // bank name
      Text(bankName)
        .font(GMFont.display(25 - 6 * p, .medium))
        .foregroundStyle(GMColor.ink.opacity(0.55))
        .lineLimit(1)
        .opacity(nameOpacity)
        .frame(height: max(0, (1 - p * 1.9)) * 32, alignment: .leading)
        .clipped()

      Spacer(minLength: 0)

      // balance + coins
      HStack(alignment: .bottom) {
        Text(balance.gmDollars)
          .font(GMFont.display(40 - 9 * p, .bold))
          .foregroundStyle(GMColor.ink)
          .monospacedDigit()
          .contentTransition(.numericText())
        Spacer()
        coins
      }

      // earned / debt row
      HStack {
        Text("Earned ·· \(earned.gmDollars)")
        Spacer()
        Text("Debt ·· \(debt.gmDollars)")
      }
      .font(GMFont.display(13, .regular))
      .foregroundStyle(GMColor.ink.opacity(0.45))
      .padding(.top, 8)
      .opacity(detailOpacity)
      .frame(height: max(0, (1 - p * 2.1)) * 22, alignment: .top)
      .clipped()
    }
    .padding(.horizontal, 22 - 4 * p)
    .padding(.vertical, 22 - 9 * p)
    .frame(height: 196 - 104 * p)
    .background(
      RoundedRectangle(cornerRadius: GMRadius.card, style: .continuous)
        .fill(GMColor.cardGradient)
        .overlay(
          RoundedRectangle(cornerRadius: GMRadius.card, style: .continuous)
            .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    )
    .overlay(sheenOverlay)
    .clipShape(RoundedRectangle(cornerRadius: GMRadius.card, style: .continuous))
    .shadow(color: .black.opacity(0.4 + 0.2 * p), radius: 28 + 18 * p, x: 0, y: 12 + 14 * p)
    .onAppear {
      guard !reduceMotion else { return }
      withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: false)) {
        sheen = true
      }
    }
  }

  private var coins: some View {
    ZStack {
      Circle().fill(GMColor.accent).frame(width: 24, height: 24)
        .offset(x: -7)
      Circle().fill(GMColor.debt).frame(width: 24, height: 24)
        .blendMode(.screen)
        .offset(x: 7)
    }
    .frame(width: 38)
  }

  private var sheenOverlay: some View {
    GeometryReader { geo in
      let w = geo.size.width
      LinearGradient(
        colors: [.clear, Color.white.opacity(0.07), .clear],
        startPoint: .leading, endPoint: .trailing
      )
      .frame(width: 70)
      .rotationEffect(.degrees(18))
      .offset(x: sheen ? w + 80 : -120)
    }
    .allowsHitTesting(false)
  }
}
