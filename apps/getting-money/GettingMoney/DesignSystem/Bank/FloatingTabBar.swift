import SwiftUI

/// The custom floating glass tab bar (4 tabs). Replaces the system TabView chrome
/// so it can match the design's translucent pill with a scaling active icon.
struct FloatingTabBar: View {
  struct Item: Identifiable {
    let id: AppTab
    let label: String
    let symbol: String
  }

  let items: [Item]
  @Binding var selection: AppTab

  var body: some View {
    HStack(spacing: 0) {
      ForEach(items) { item in
        Button {
          selection = item.id
        } label: {
          tabLabel(item, active: selection == item.id)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, 8)
    .frame(height: 68)
    .background(
      RoundedRectangle(cornerRadius: 26, style: .continuous)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 26, style: .continuous)
            .stroke(Color.white.opacity(0.09), lineWidth: 1))
    )
    .shadow(color: .black.opacity(0.5), radius: 24, y: 12)
    .padding(.horizontal, 18)
  }

  private func tabLabel(_ item: Item, active: Bool) -> some View {
    VStack(spacing: 5) {
      Image(systemName: item.symbol)
        .font(.system(size: 20, weight: active ? .semibold : .regular))
        .scaleEffect(active ? 1.12 : 1)
      Text(item.label)
        .font(GMFont.body(10.5, .bold))
    }
    .foregroundStyle(active ? GMColor.accent : GMColor.faint)
    .frame(maxWidth: .infinity)
    .contentShape(Rectangle())
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: active)
  }
}

/// The app's screens. Four are primary tabs; `targets` is reached via the
/// dashboard gear and shows the tab bar with no item highlighted.
enum AppTab: Hashable {
  case dashboard, rounds, bank, debt, targets
}
