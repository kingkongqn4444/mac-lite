import SwiftUI

enum MacColors {
    // MARK: - Menu Bar
    static let menuBarBackground = Color.black.opacity(0.25)
    static let menuBarText = Color.white
    static let menuBarActiveItem = Color.white.opacity(0.2)

    // MARK: - Dock
    static let dockBackground = Color.white.opacity(0.15)
    static let dockSeparator = Color.white.opacity(0.3)

    // MARK: - Window Chrome
    static let windowTitleBar = Color(white: 0.96)
    static let windowTitleBarActive = Color(white: 0.93)
    static let windowBackground = Color(white: 0.96)
    static let windowBorder = Color(white: 0.78)
    static let windowTitleText = Color(white: 0.2)

    // MARK: - Traffic Lights
    static let closeButton = Color(red: 1.0, green: 0.38, blue: 0.34)
    static let minimizeButton = Color(red: 1.0, green: 0.74, blue: 0.02)
    static let maximizeButton = Color(red: 0.15, green: 0.78, blue: 0.25)
    static let trafficLightInactive = Color(white: 0.8)

    // MARK: - Text
    static let primaryText = Color.black
    static let secondaryText = Color(white: 0.45)
    static let tertiaryText = Color(white: 0.6)

    // MARK: - Sidebar
    static let sidebarBackground = Color(white: 0.95)
    static let sidebarSelection = Color.accentColor.opacity(0.2)

    // MARK: - Desktop
    static let desktopIconLabel = Color.white
    static let desktopIconLabelShadow = Color.black.opacity(0.6)
    static let selectionHighlight = Color.accentColor

    // MARK: - Dropdown
    static let dropdownBackground = Color(white: 0.98)
    static let dropdownSeparator = Color(white: 0.88)
    static let dropdownHover = Color.accentColor
}
