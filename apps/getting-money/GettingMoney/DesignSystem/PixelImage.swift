import SwiftUI

extension Image {
  func pixelArt() -> some View {
    self.resizable()
      .interpolation(.none)
      .antialiased(false)
  }
}

struct PixelToggle: View {
  var isOn: Bool
  let label: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(isOn ? "pixel_toggle_on" : "pixel_toggle_off")
        .pixelArt()
        .frame(width: 71, height: 40)
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(label)
    .accessibilityValue(isOn ? "On" : "Off")
  }
}

struct PixelStepButton: View {
  let kind: StepKind
  let label: String
  var enabled: Bool = true
  let action: () -> Void

  enum StepKind { case plus, minus }

  var body: some View {
    Button(action: action) {
      Image(kind == .plus ? "pixel_btn_plus" : "pixel_btn_minus")
        .pixelArt()
        .frame(width: 40, height: 34)
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
        .opacity(enabled ? 1 : 0.4)
    }
    .buttonStyle(.plain)
    .disabled(!enabled)
    .accessibilityLabel(label)
  }
}
