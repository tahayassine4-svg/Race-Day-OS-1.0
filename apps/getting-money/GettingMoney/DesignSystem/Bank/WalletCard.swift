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
          .animation(reduceMotion ? nil : .snappy(duration: 0.45), value: balance)
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
  }

  /// The two overlapping coins breathe on a slow cycle. Time-driven (not
  /// state-driven) so scrolling/collapse re-renders can't kill the motion.
  private var coins: some View {
    Group {
      if reduceMotion {
        coinPair(scale: 1)
      } else {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { context in
          let t = context.date.timeIntervalSinceReferenceDate
          coinPair(scale: 1 + 0.05 * sin(t * .pi * 2 / 2.8))
        }
      }
    }
  }

  private func coinPair(scale: CGFloat) -> some View {
    ZStack {
      Circle().fill(GMColor.accent).frame(width: 24, height: 24)
        .offset(x: -7)
      Circle().fill(GMColor.debt).frame(width: 24, height: 24)
        .blendMode(.screen)
        .offset(x: 7)
    }
    .frame(width: 38)
    .scaleEffect(scale)
  }

  /// Diagonal sheen: sweeps for ~1.7s, rests, repeats. Driven by wall-clock
  /// time via TimelineView so it survives any re-render (the old
  /// onAppear+repeatForever version died as soon as scroll collapsed the card,
  /// and snapped back instead of sweeping).
  @ViewBuilder private var sheenOverlay: some View {
    if reduceMotion {
      Color.clear.allowsHitTesting(false)
    } else {
      GeometryReader { geo in
        let w = geo.size.width
        TimelineView(.animation(minimumInterval: 1.0 / 60)) { context in
          let t = context.date.timeIntervalSinceReferenceDate
          let phase = CGFloat(min(1, t.truncatingRemainder(dividingBy: 4.6) / 1.7))
          LinearGradient(
            colors: [.clear, Color.white.opacity(0.07), .clear],
            startPoint: .leading, endPoint: .trailing
          )
          .frame(width: 70)
          .rotationEffect(.degrees(18))
          .offset(x: -120 + phase * (w + 220))
        }
      }
      .allowsHitTesting(false)
    }
  }
}
