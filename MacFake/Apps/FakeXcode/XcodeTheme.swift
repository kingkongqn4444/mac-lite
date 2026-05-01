import SwiftUI

/// Xcode default dark theme
struct XcodeTheme: IDETheme {
    // MARK: - Backgrounds
    let editorBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
    let sidebarBackground = Color(red: 0.14, green: 0.14, blue: 0.15)
    let toolbarBackground = Color(red: 0.18, green: 0.18, blue: 0.20)
    let terminalBackground = Color(red: 0.10, green: 0.10, blue: 0.11)
    let tabBarBackground = Color(red: 0.14, green: 0.14, blue: 0.15)
    let tabActiveBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
    let tabInactiveBackground = Color(red: 0.16, green: 0.16, blue: 0.17)

    // MARK: - Text
    let textPrimary = Color(white: 0.85)
    let textSecondary = Color(white: 0.55)
    let accentColor = Color(red: 0.25, green: 0.52, blue: 1.0) // Xcode blue
    let lineNumberColor = Color(white: 0.45)
    let selectionColor = Color(red: 0.20, green: 0.33, blue: 0.55)

    // MARK: - Syntax (Xcode Midnight-style)
    let syntaxKeyword = Color(red: 0.99, green: 0.37, blue: 0.53)   // Pink
    let syntaxString = Color(red: 0.99, green: 0.41, blue: 0.36)    // Red-orange
    let syntaxComment = Color(red: 0.42, green: 0.68, blue: 0.42)   // Green
    let syntaxNumber = Color(red: 0.82, green: 0.75, blue: 0.50)    // Yellow
    let syntaxType = Color(red: 0.56, green: 0.80, blue: 0.73)      // Teal
    let syntaxFunction = Color(red: 0.40, green: 0.72, blue: 0.56)  // Green-teal
    let syntaxProperty = Color(red: 0.56, green: 0.80, blue: 0.73)  // Teal

    let sidebarWidth: CGFloat = 110
}
