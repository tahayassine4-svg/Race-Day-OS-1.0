import SwiftUI

struct PixelCoinView: View {
  var size: CGFloat = 14

  var body: some View {
    Canvas { ctx, sz in
      let s = sz.width
      ctx.fill(
        Path(ellipseIn: CGRect(x: 0, y: 0, width: s, height: s)),
        with: .color(Color(hex: "#1A1A1A"))
      )
      ctx.fill(
        Path(ellipseIn: CGRect(x: s * 0.1, y: s * 0.1, width: s * 0.8, height: s * 0.8)),
        with: .color(Color(hex: "#FFD700"))
      )
      let hl = CGFloat(2)
      ctx.fill(
        Path(CGRect(x: s * 0.2, y: s * 0.2, width: hl, height: hl)),
        with: .color(.white.opacity(0.8))
      )
    }
    .frame(width: size, height: size)
  }
}

enum GMPixelIconKind {
  case dashboard, log, rounds, debt, settings
  case pushups, pullups, squats, dips
  case flame, shield, swords, clipboard, gear, chart, upload, trash, info, lock
  case plus, minus, check, calendar, target, coin

  var letters: String {
    switch self {
    case .dashboard: "D"
    case .log: "L"
    case .rounds: "R"
    case .debt: "C"
    case .settings: "G"
    case .pushups: "P"
    case .pullups: "U"
    case .squats: "Q"
    case .dips: "I"
    case .flame: "F"
    case .shield: "S"
    case .swords: "X"
    case .clipboard: "B"
    case .gear: "G"
    case .chart: "XP"
    case .upload: "UP"
    case .trash: "!"
    case .info: "?"
    case .lock: "K"
    case .plus: "+"
    case .minus: "-"
    case .check: "OK"
    case .calendar: "14"
    case .target: "T"
    case .coin: "C"
    }
  }

  var defaultColor: Color {
    switch self {
    case .debt, .trash: GMColor.debt
    case .flame: Color(hex: "#FF8A1F")
    case .coin: GMColor.gold
    case .settings, .dashboard, .rounds, .target, .chart, .plus, .check: GMColor.accent
    default: GMColor.ink
    }
  }

  static func exercise(_ keyOrGlyph: String) -> GMPixelIconKind {
    let value = keyOrGlyph.lowercased()
    if value.contains("pull") { return .pullups }
    if value.contains("squat") { return .squats }
    if value.contains("dip") { return .dips }
    return .pushups
  }

  static func fromSystemName(_ systemName: String) -> GMPixelIconKind {
    if systemName.contains("trash") { return .trash }
    if systemName.contains("arrow.up") { return .upload }
    if systemName.contains("lock") { return .lock }
    if systemName.contains("info") { return .info }
    if systemName.contains("chart") { return .chart }
    if systemName.contains("gear") { return .settings }
    if systemName.contains("calendar") { return .calendar }
    return .target
  }
}

struct GMPixelIcon: View {
  var kind: GMPixelIconKind
  var size: CGFloat = 34
  var color: Color? = nil
  var filled: Bool = false

  var body: some View {
    let tint = color ?? kind.defaultColor
    ZStack {
      Rectangle()
        .fill(filled ? tint.opacity(0.22) : GMColor.stage)
      PixelNoise(color: tint.opacity(0.14), spacing: max(4, size / 6))
      Rectangle()
        .strokeBorder(tint.opacity(0.85), lineWidth: max(1, size / 18))
      Rectangle()
        .inset(by: max(4, size / 6))
        .strokeBorder(tint.opacity(0.2), lineWidth: 1)
      Text(kind.letters)
        .font(.system(size: max(8, size * 0.34), weight: .heavy, design: .monospaced))
        .minimumScaleFactor(0.5)
        .foregroundStyle(tint)
    }
    .frame(width: size, height: size)
    .accessibilityHidden(true)
  }
}

struct GMPixelStepButton: View {
  var kind: GMPixelIconKind
  var label: String
  var enabled: Bool = true
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      GMPixelIcon(kind: kind, size: 38, color: enabled ? GMColor.accent : GMColor.muted)
    }
    .buttonStyle(.plain)
    .disabled(!enabled)
    .opacity(enabled ? 1 : 0.45)
    .accessibilityLabel(label)
  }
}

struct GMPixelToggleButton: View {
  var isOn: Bool
  var label: String
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 0) {
        if isOn { Spacer(minLength: 0) }
        Rectangle()
          .fill(isOn ? GMColor.ink : GMColor.muted)
          .frame(width: 18, height: 18)
        if !isOn { Spacer(minLength: 0) }
      }
      .padding(4)
      .frame(width: 54, height: 30)
      .background(isOn ? GMColor.accent : GMColor.elevated)
      .overlay(Rectangle().stroke(GMColor.hairline, lineWidth: 1.5))
    }
    .buttonStyle(.plain)
    .accessibilityLabel(label)
    .accessibilityValue(isOn ? "On" : "Off")
  }
}
