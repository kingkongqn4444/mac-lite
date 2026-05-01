import SwiftUI

enum MacShadows {
    static func window(isFocused: Bool) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .shadow(
                color: .black.opacity(isFocused ? 0.3 : 0.15),
                radius: isFocused ? 12 : 6,
                x: 0,
                y: isFocused ? 4 : 2
            )
    }

    static let dock = ViewModifier_Shadow(radius: 20, opacity: 0.2, y: 0)
    static let dropdown = ViewModifier_Shadow(radius: 8, opacity: 0.15, y: 2)
    static let trafficLight = ViewModifier_Shadow(radius: 0.5, opacity: 0.2, y: 0.5)
}

struct ViewModifier_Shadow: ViewModifier {
    let radius: CGFloat
    let opacity: Double
    let y: CGFloat

    func body(content: Content) -> some View {
        content.shadow(color: .black.opacity(opacity), radius: radius, x: 0, y: y)
    }
}

extension View {
    func macShadow(_ shadow: ViewModifier_Shadow) -> some View {
        modifier(shadow)
    }
}
