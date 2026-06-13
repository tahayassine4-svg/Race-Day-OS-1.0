import SwiftUI

struct LogView: View {
    var body: some View {
        ComingSoonScreen(
            eyebrow: "Log · Today",
            title: "Log your reps.",
            glyph: "plus.circle.fill",
            note: "Fast rep logging and earnings arrive in Packet 04."
        )
    }
}

#Preview { LogView().preferredColorScheme(.dark) }
