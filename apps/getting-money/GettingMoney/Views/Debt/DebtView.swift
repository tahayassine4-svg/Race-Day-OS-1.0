import SwiftUI

struct DebtView: View {
    var body: some View {
        ComingSoonScreen(
            eyebrow: "Debt · Pay it back",
            title: "Pay back what you owe.",
            glyph: "arrow.triangle.2.circlepath",
            note: "Debt tracking and the dynamic payback plan arrive in Packets 05 and 07."
        )
    }
}

#Preview { DebtView().preferredColorScheme(.dark) }
