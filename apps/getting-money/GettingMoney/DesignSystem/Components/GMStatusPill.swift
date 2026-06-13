import SwiftUI

/// Status states. Always color + label (never color alone), per accessibility rules.
enum GMStatus {
    case onTrack, profit, behind, activeDebt, paidOff

    var label: String {
        switch self {
        case .onTrack:    "On track"
        case .profit:     "Profit"
        case .behind:     "Behind"
        case .activeDebt: "Active debt"
        case .paidOff:    "Paid off"
        }
    }

    var color: Color {
        switch self {
        case .onTrack, .profit, .paidOff: GMColor.success
        case .behind:                     GMColor.warning
        case .activeDebt:                 GMColor.debt
        }
    }
}

struct GMStatusPill: View {
    let status: GMStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(status.color).frame(width: 7, height: 7)
            Text(status.label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(status.color)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(status.color.opacity(0.14))
        )
        .overlay(
            Capsule().stroke(status.color.opacity(0.28), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Status: \(status.label)")
    }
}
