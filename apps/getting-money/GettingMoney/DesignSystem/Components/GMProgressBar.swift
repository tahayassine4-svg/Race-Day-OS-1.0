import SwiftUI

/// Lime progress fill used for daily target and per-exercise progress.
struct GMProgressBar: View {
    /// 0...1
    let fraction: Double
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(Color(hex: "#0E120F"))
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                            .stroke(GMColor.hairline, lineWidth: 1)
                    )
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#8FD02B"), GMColor.accent],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(1, fraction)) * geo.size.width)
            }
        }
        .frame(height: height)
        .accessibilityElement()
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int((max(0, min(1, fraction))) * 100)) percent")
    }
}
