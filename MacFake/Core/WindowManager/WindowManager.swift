import SwiftUI

@Observable
final class WindowManager {
    var windows: [WindowState] = []
    var focusedWindowId: UUID?
    private var nextZIndex: Int = 0

    var focusedApp: FakeApp? {
        windows.first { $0.id == focusedWindowId }?.app
    }

    var visibleWindows: [WindowState] {
        windows.filter { !$0.isMinimized }.sorted { $0.zIndex < $1.zIndex }
    }

    func isRunning(_ app: FakeApp) -> Bool {
        windows.contains { $0.app == app }
    }

    func openApp(_ app: FakeApp, screenSize: CGSize) {
        // If app already open and minimized, restore it
        if let existing = windows.first(where: { $0.app == app && $0.isMinimized }) {
            restoreWindow(existing.id)
            return
        }

        // If app already open, bring to front
        if let existing = windows.first(where: { $0.app == app }) {
            bringToFront(existing.id)
            return
        }

        let windowSize = app.defaultWindowSize
        // .position() uses CENTER point, so center the window on screen
        // Account for menu bar (24pt top) and dock (56pt bottom)
        let menuBarH: CGFloat = 24
        let dockH: CGFloat = 40
        let usableCenter = CGPoint(
            x: screenSize.width / 2,
            y: menuBarH + (screenSize.height - menuBarH - dockH) / 2
        )
        let cascade = CGFloat(windows.count) * 18
        let minY = menuBarH + windowSize.height / 2 + 4 // Ensure title bar below menu bar
        let position = CGPoint(
            x: usableCenter.x + cascade.truncatingRemainder(dividingBy: 60) - 30,
            y: max(minY, usableCenter.y + cascade.truncatingRemainder(dividingBy: 40) - 20)
        )

        let window = WindowState(
            app: app,
            title: app.displayName,
            position: position,
            size: windowSize,
            zIndex: nextZIndex
        )
        nextZIndex += 1
        windows.append(window)
        focusedWindowId = window.id
    }

    func closeWindow(_ id: UUID) {
        windows.removeAll { $0.id == id }
        if focusedWindowId == id {
            focusedWindowId = visibleWindows.last?.id
        }
    }

    func minimizeWindow(_ id: UUID) {
        guard let window = windows.first(where: { $0.id == id }) else { return }
        window.isMinimized = true
        if focusedWindowId == id {
            focusedWindowId = visibleWindows.last?.id
        }
    }

    func restoreWindow(_ id: UUID) {
        guard let window = windows.first(where: { $0.id == id }) else { return }
        window.isMinimized = false
        bringToFront(id)
    }

    func maximizeWindow(_ id: UUID, screenSize: CGSize, menuBarHeight: CGFloat = 24, dockHeight: CGFloat = 40) {
        guard let window = windows.first(where: { $0.id == id }) else { return }

        if window.isMaximized, let saved = window.preMaximizeFrame {
            window.position = saved.origin
            window.size = saved.size
            window.isMaximized = false
        } else {
            window.preMaximizeFrame = CGRect(origin: window.position, size: window.size)
            window.position = CGPoint(
                x: screenSize.width / 2,
                y: menuBarHeight + (screenSize.height - menuBarHeight - dockHeight) / 2
            )
            window.size = CGSize(
                width: screenSize.width,
                height: screenSize.height - menuBarHeight - dockHeight
            )
            window.isMaximized = true
        }
        bringToFront(id)
    }

    func bringToFront(_ id: UUID) {
        guard let window = windows.first(where: { $0.id == id }) else { return }
        window.zIndex = nextZIndex
        nextZIndex += 1
        focusedWindowId = id
    }

    func updatePosition(_ id: UUID, _ position: CGPoint) {
        guard let window = windows.first(where: { $0.id == id }) else { return }
        // Clamp: title bar (top of window) must stay below menu bar (24pt)
        // .position() is CENTER, so top edge = y - height/2
        // Title bar must be at least partially visible: y - height/2 >= 24
        let minY = 24 + window.size.height / 2
        window.position = CGPoint(
            x: position.x,
            y: max(minY, position.y)
        )
        window.isMaximized = false
    }

    func updateSize(_ id: UUID, _ size: CGSize) {
        guard let window = windows.first(where: { $0.id == id }) else { return }
        let minSize = window.app.minWindowSize
        window.size = CGSize(
            width: max(minSize.width, size.width),
            height: max(minSize.height, size.height)
        )
        window.isMaximized = false
    }
}
