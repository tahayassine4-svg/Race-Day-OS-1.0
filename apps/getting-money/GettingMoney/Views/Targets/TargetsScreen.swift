import SwiftUI

/// Daily Targets (reached via the dashboard gear): flip the coin to an exercise,
/// tune its daily goal with a stepper, and toggle auto-progression.
struct TargetsScreen: View {
  @Bindable var vm: SettingsViewModel
  let onClose: () -> Void
  @State private var focus = 0

  private var rows: [SettingsViewModel.Row] { vm.rows.filter(\.isEnabled) }
  private var faces: [CoinFlipView.Face] {
    rows.map {
      CoinFlipView.Face(id: $0.id, name: $0.name, glyph: $0.glyph, caption: "\($0.target) rep goal")
    }
  }
  private var focusRow: SettingsViewModel.Row? {
    rows.isEmpty ? nil : rows[min(focus, rows.count - 1)]
  }

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 20) {
        header
        CoinFlipView(faces: faces, index: $focus)
          .frame(height: 300).frame(maxWidth: .infinity)
          .onChange(of: focus) { _, _ in UISelectionFeedbackGenerator().selectionChanged() }
        stepper
        progression
      }
      .padding(.horizontal, GMSpacing.screen)
      .padding(.top, 4)
      .padding(.bottom, 130)
    }
    .onAppear { vm.load() }
  }

  private var header: some View {
    HStack(alignment: .center, spacing: 12) {
      Button(action: onClose) {
        Image(systemName: "chevron.left")
          .font(.system(size: 16, weight: .bold)).foregroundStyle(GMColor.ink)
          .frame(width: 40, height: 40)
          .background(RoundedRectangle(cornerRadius: 13).fill(Color.white.opacity(0.05)))
      }
      .buttonStyle(PressButtonStyle())
      VStack(alignment: .leading, spacing: 2) {
        Text("Flip to set each goal")
          .font(GMFont.body(14, .semibold)).foregroundStyle(GMColor.ink.opacity(0.5))
        Text("Daily Targets")
          .font(GMFont.display(24, .bold)).foregroundStyle(GMColor.ink)
      }
      Spacer()
    }
  }

  private var stepper: some View {
    let row = focusRow
    let capped = (row?.id == "pullups") && (row?.target ?? 0) >= 10
    return VStack(spacing: 14) {
      Text("\(row?.name ?? "—") · daily goal")
        .font(GMFont.body(13, .semibold)).foregroundStyle(GMColor.ink.opacity(0.55))
      HStack(spacing: 24) {
        stepButton("minus", tint: GMColor.ink, border: Color.white.opacity(0.12)) {
          adjust(-step(for: row))
        }
        Text("\(row?.target ?? 0)")
          .font(GMFont.display(56, .bold)).foregroundStyle(GMColor.ink)
          .monospacedDigit().frame(minWidth: 120)
          .contentTransition(.numericText())
        stepButton("plus", tint: GMColor.accent, border: GMColor.accent.opacity(0.3)) {
          adjust(step(for: row))
        }
        .opacity(capped ? 0.3 : 1)
        .disabled(capped)
      }
      if capped {
        Text("Pull-ups cap at 10 — quality over quantity.")
          .font(GMFont.body(12, .semibold)).foregroundStyle(GMColor.warning)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20).padding(.horizontal, 18)
    .background(
      RoundedRectangle(cornerRadius: 22).fill(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
  }

  private func stepButton(
    _ symbol: String, tint: Color, border: Color, action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.system(size: 22, weight: .regular)).foregroundStyle(tint)
        .frame(width: 54, height: 54)
        .background(
          Circle().fill(
            tint == GMColor.accent ? GMColor.accent.opacity(0.1) : Color.white.opacity(0.05)
          )
          .overlay(Circle().stroke(border, lineWidth: 1)))
    }
    .buttonStyle(PressButtonStyle())
  }

  private var progression: some View {
    HStack(spacing: 14) {
      VStack(alignment: .leading, spacing: 2) {
        Text("Auto-progression")
          .font(GMFont.display(15, .bold)).foregroundStyle(GMColor.ink)
        Text(nextText)
          .font(GMFont.body(13)).foregroundStyle(GMColor.ink.opacity(0.55))
      }
      Spacer()
      Toggle(
        "",
        isOn: Binding(
          get: { vm.autoProgressionEnabled },
          set: { vm.setAutoProgressionEnabled($0) })
      )
      .labelsHidden()
      .tint(GMColor.accent)
    }
    .padding(18)
    .background(
      RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
  }

  private var nextText: String {
    guard vm.autoProgressionEnabled else { return "Off — targets stay put until you change them." }
    return "Next: +\(vm.progressionAmount) reps in \(vm.daysUntilNextProgression) days"
  }

  private func step(for row: SettingsViewModel.Row?) -> Int { row?.id == "pullups" ? 1 : 5 }

  private func adjust(_ delta: Int) {
    guard let row = focusRow else { return }
    vm.adjustTarget(row.id, by: delta)
    UISelectionFeedbackGenerator().selectionChanged()
  }
}
