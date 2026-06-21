import SwiftUI

/// Status states. Always color + label (never color alone), per accessibility rules.
enum GMStatus {
  case onTrack, profit, behind, activeDebt, paidOff

  var label: String {
    switch self {
    case .onTrack: "On track"
    case .profit: "Profit"
    case .behind: "Behind"
    case .activeDebt: "Active debt"
    case .paidOff: "Paid off"
    }
  }

  var color: Color {
    switch self {
    case .onTrack, .profit, .paidOff: GMColor.success
    case .behind: GMColor.warning
    case .activeDebt: GMColor.debt
    }
  }
}

struct GMStatusPill: View {
  let status: GMStatus

  var body: some View {
    HStack(spacing: 6) {
      Circle().fill(status.color).frame(width: 7, height: 7)
      Text(status.label.uppercased())
        .font(.system(size: 11, weight: .heavy, design: .monospaced))
        .tracking(0.5)
        .foregroundStyle(status.color)
    }
    .padding(.horizontal, 9)
    .padding(.vertical, 5)
    .background(
      RoundedRectangle(cornerRadius: 2).fill(status.color.opacity(0.14))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 2).strokeBorder(status.color.opacity(0.32), lineWidth: 1.5)
    )
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Status: \(status.label)")
  }
}
