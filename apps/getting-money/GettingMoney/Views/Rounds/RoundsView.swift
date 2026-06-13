import SwiftUI

struct RoundsView: View {
    var body: some View {
        ComingSoonScreen(
            eyebrow: "Rounds · Today",
            title: "Rounds to hit zero.",
            glyph: "circle.dotted",
            note: "Auto-split circles and editable rounds arrive in Packet 06."
        )
    }
}

#Preview { RoundsView().preferredColorScheme(.dark) }
