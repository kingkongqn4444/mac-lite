import SwiftUI

/// Protocol defining visual identity for fake IDE apps
protocol IDETheme {
    // MARK: - Background Colors
    var editorBackground: Color { get }
    var sidebarBackground: Color { get }
    var toolbarBackground: Color { get }
    var terminalBackground: Color { get }
    var tabBarBackground: Color { get }
    var tabActiveBackground: Color { get }
    var tabInactiveBackground: Color { get }

    // MARK: - Text Colors
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var accentColor: Color { get }
    var lineNumberColor: Color { get }
    var selectionColor: Color { get }
    var separatorColor: Color { get }

    // MARK: - Syntax Colors
    var syntaxKeyword: Color { get }
    var syntaxString: Color { get }
    var syntaxComment: Color { get }
    var syntaxNumber: Color { get }
    var syntaxType: Color { get }
    var syntaxFunction: Color { get }
    var syntaxProperty: Color { get }

    // MARK: - Fonts
    var editorFont: Font { get }
    var editorUIFont: Font { get }
    var terminalFont: Font { get }

    // MARK: - Layout
    var sidebarWidth: CGFloat { get }
}

// MARK: - Defaults
extension IDETheme {
    var editorFont: Font { .system(size: 7, design: .monospaced) }
    var editorUIFont: Font { .system(size: 7) }
    var terminalFont: Font { .system(size: 6.5, design: .monospaced) }
    var sidebarWidth: CGFloat { 120 }
    var separatorColor: Color { Color(white: 0.25) }
}
