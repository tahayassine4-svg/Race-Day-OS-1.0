import SwiftUI

/// Shared dark canvas with the subtle lime/coral ambient glow from the mockup.
struct ScreenBackground: View {
    var body: some View {
        GMColor.background
            .overlay(alignment: .topTrailing) {
                Circle().fill(GMColor.accent.opacity(0.10))
                    .frame(width: 360, height: 360)
                    .blur(radius: 90).offset(x: 120, y: -160)
            }
            .overlay(alignment: .bottomLeading) {
                Circle().fill(GMColor.debt.opacity(0.06))
                    .frame(width: 320, height: 320)
                    .blur(radius: 90).offset(x: -120, y: 160)
            }
            .ignoresSafeArea()
    }
}

extension View {
    func gmScreenBackground() -> some View {
        background(ScreenBackground())
    }
}
