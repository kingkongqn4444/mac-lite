import UIKit

enum HapticManager {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func dock() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func windowAction() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
