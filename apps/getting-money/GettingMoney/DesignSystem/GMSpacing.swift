import CoreGraphics

/// Spacing scale (docs/ui-system.md): 4 · 8 · 12 · 16 · 20 · 24 · 32.
enum GMSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32

    /// Standard screen horizontal padding.
    static let screen: CGFloat = 20
}

/// Corner-radius scale: controls 10 · rows 14 · modules 20.
enum GMRadius {
    static let control: CGFloat = 10
    static let row: CGFloat = 14
    static let module: CGFloat = 20
}
