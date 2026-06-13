import SwiftUI

/// Semantic color tokens — dark-first, from docs/ui-system.md.
/// One lime accent does the work; coral is reserved for debt/loss only.
enum GMColor {
    static let background = Color(hex: "#0A0D0B")
    static let surface    = Color(hex: "#131714")
    static let elevated   = Color(hex: "#1B201C")
    static let hairline   = Color(hex: "#2A302C")

    static let ink   = Color(hex: "#F3F7F1")   // primary text / numbers
    static let muted = Color(hex: "#8A938C")   // secondary text

    static let accent        = Color(hex: "#AEE63D")  // earnings, progress, primary action
    static let accentPressed = Color(hex: "#93C32F")
    static let onAccent      = Color(hex: "#13200A")  // text on the accent fill

    static let success = Color(hex: "#5FD08A")  // on track / paid
    static let warning = Color(hex: "#F2C14E")  // behind / due
    static let debt    = Color(hex: "#FF6A5A")  // debt / loss (coral)
}
