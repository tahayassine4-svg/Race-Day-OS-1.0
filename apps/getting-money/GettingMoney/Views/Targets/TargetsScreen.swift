import SwiftUI

/// Daily Targets (reached via the dashboard gear): flip the coin to an exercise,
/// tune its daily goal with a stepper, and toggle auto-progression.
struct TargetsScreen: View {
  @Bindable var vm: SettingsViewModel
  let onClose: () -> Void
  /// Called after a confirmed reset so the root can reload every VM + widget.
  let onReset: () -> Void
  @State private var focus = 0
  @State private var resetFailed = false
  @State private var confirmReset: Bool

  init(vm: SettingsViewModel, onClose: @escaping () -> Void, onReset: @escaping () -> Void) {
    self.vm = vm
    self.onClose = onClose
    self.onReset = onReset
    var showConfirm = false
    #if DEBUG
      // Screenshot hook, same pattern as -GMInitialScreen: launch straight into
      // the reset confirmation so the sheet can be visually verified.
      showConfirm = ProcessInfo.processInfo.arguments.contains("-GMShowResetConfirm")
    #endif
    _confirmReset = State(initialValue: showConfirm)
  }

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
        dangerZone
      }
      .padding(.horizontal, GMSpacing.screen)
      .padding(.top, 4)
      .padding(.bottom, 130)
    }
    .onAppear { vm.load() }
    .sheet(isPresented: $confirmReset) {
      ResetConfirmSheet(
        onConfirm: {
          confirmReset = false
          vm.resetAllData()
          // A destructive action must never report success it didn't have:
          // only a clean reset reloads the app + shows the success toast.
          if vm.errorMessage == nil {
            onReset()
          } else {
            resetFailed = true
          }
        },
        onCancel: { confirmReset = false }
      )
      .presentationDetents([.height(330)])
      .presentationDragIndicator(.hidden)
      .presentationBackground(Color(hex: "#14181C"))
    }
    .alert("Reset failed", isPresented: $resetFailed) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Nothing was deleted. Your reps and bank are untouched — try again.")
    }
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

  // MARK: Danger zone (Packet 21 — restores the reset lost in the redesign)

  private var dangerZone: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("DANGER ZONE")
        .font(GMFont.body(11, .bold)).tracking(1.6)
        .foregroundStyle(GMColor.debt.opacity(0.85))
      HStack(spacing: 12) {
        VStack(alignment: .leading, spacing: 2) {
          Text("Reset all reps")
            .font(GMFont.display(15, .bold)).foregroundStyle(GMColor.ink)
          Text("Wipes every rep, debt and bank balance on this device.")
            .font(GMFont.body(12.5, .medium)).foregroundStyle(GMColor.ink.opacity(0.5))
        }
        Spacer()
        Button {
          confirmReset = true
        } label: {
          Text("Reset…")
            .font(GMFont.body(13.5, .bold))
            .foregroundStyle(GMColor.debt)
            .padding(.horizontal, 16).padding(.vertical, 11)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .stroke(GMColor.debt.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("Reset all reps")
      }
    }
    .padding(18)
    .background(
      RoundedRectangle(cornerRadius: 20).fill(GMColor.debt.opacity(0.05))
        .overlay(
          RoundedRectangle(cornerRadius: 20).stroke(GMColor.debt.opacity(0.22), lineWidth: 1))
    )
  }
}

/// The destructive confirmation for "Reset all reps" (design/packet-21-reset.png).
struct ResetConfirmSheet: View {
  let onConfirm: () -> Void
  let onCancel: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        Circle().fill(GMColor.debt.opacity(0.12))
          .overlay(Circle().stroke(GMColor.debt.opacity(0.3), lineWidth: 1))
        Image(systemName: "exclamationmark.triangle")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(GMColor.ink)
      }
      .frame(width: 52, height: 52)
      .padding(.top, 26)

      Text("Reset all reps?")
        .font(GMFont.display(20, .bold)).foregroundStyle(GMColor.ink)
        .padding(.top, 14)
      Text(
        "This deletes every logged rep, all rep debt and your whole bank balance on this device. There's no undo."
      )
      .font(GMFont.body(14, .medium)).foregroundStyle(GMColor.ink.opacity(0.55))
      .multilineTextAlignment(.center)
      .lineSpacing(3)
      .padding(.horizontal, 28)
      .padding(.top, 8)

      Button(action: onConfirm) {
        Text("Yes, wipe it all")
          .font(GMFont.display(16, .bold))
          .foregroundStyle(Color(hex: "#14060A"))
          .frame(maxWidth: .infinity).frame(height: 54)
          .background(RoundedRectangle(cornerRadius: 16).fill(GMColor.debt))
      }
      .buttonStyle(PressButtonStyle())
      .padding(.horizontal, 20)
      .padding(.top, 20)
      .accessibilityLabel("Confirm reset of all reps")

      Button(action: onCancel) {
        Text("Keep my money")
          .font(GMFont.body(15, .bold)).foregroundStyle(GMColor.ink)
          .frame(maxWidth: .infinity).frame(height: 50)
          .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05))
              .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1)))
      }
      .buttonStyle(PressButtonStyle())
      .padding(.horizontal, 20)
      .padding(.top, 10)

      Spacer(minLength: 0)
    }
    .preferredColorScheme(.dark)
  }
}
