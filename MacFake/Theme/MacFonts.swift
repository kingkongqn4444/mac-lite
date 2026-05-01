import SwiftUI

enum MacFonts {
    // MARK: - Menu Bar
    static let menuBar = Font.system(size: 11, weight: .medium)
    static let menuBarBold = Font.system(size: 11, weight: .semibold)

    // MARK: - Window
    static let windowTitle = Font.system(size: 11, weight: .semibold)

    // MARK: - Body
    static let body = Font.system(size: 11)
    static let bodySmall = Font.system(size: 10)

    // MARK: - Sidebar
    static let sidebar = Font.system(size: 11)
    static let sidebarHeader = Font.system(size: 10, weight: .semibold)

    // MARK: - Dock
    static let dockLabel = Font.system(size: 8)

    // MARK: - Desktop
    static let desktopIcon = Font.system(size: 10)

    // MARK: - Terminal
    static let terminal = Font.system(size: 11, design: .monospaced)

    // MARK: - Calculator
    static let calculatorDisplay = Font.system(size: 28, weight: .light)
    static let calculatorButton = Font.system(size: 16)

    // MARK: - Dropdown
    static let dropdownItem = Font.system(size: 11)
    static let dropdownShortcut = Font.system(size: 10, design: .monospaced)
}
