import SwiftUI

@Observable
final class WindowState: Identifiable {
    let id = UUID()
    let app: FakeApp
    var title: String
    var position: CGPoint
    var size: CGSize
    var isMinimized: Bool = false
    var isMaximized: Bool = false
    var zIndex: Int
    var preMaximizeFrame: CGRect?

    init(app: FakeApp, title: String, position: CGPoint, size: CGSize, zIndex: Int) {
        self.app = app
        self.title = title
        self.position = position
        self.size = size
        self.zIndex = zIndex
    }

    var frame: CGRect {
        CGRect(origin: position, size: size)
    }
}
