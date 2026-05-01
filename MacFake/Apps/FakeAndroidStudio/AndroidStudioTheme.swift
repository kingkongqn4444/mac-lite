import SwiftUI

/// Android Studio Darcula theme
struct AndroidStudioTheme: IDETheme {
    // MARK: - Backgrounds
    let editorBackground = Color(red: 0.16, green: 0.17, blue: 0.19)
    let sidebarBackground = Color(red: 0.19, green: 0.20, blue: 0.22)
    let toolbarBackground = Color(red: 0.22, green: 0.23, blue: 0.25)
    let terminalBackground = Color(red: 0.14, green: 0.15, blue: 0.17)
    let tabBarBackground = Color(red: 0.19, green: 0.20, blue: 0.22)
    let tabActiveBackground = Color(red: 0.16, green: 0.17, blue: 0.19)
    let tabInactiveBackground = Color(red: 0.22, green: 0.23, blue: 0.25)

    // MARK: - Text
    let textPrimary = Color(red: 0.66, green: 0.69, blue: 0.73)     // #a9b7c6
    let textSecondary = Color(white: 0.50)
    let accentColor = Color(red: 0.24, green: 0.64, blue: 0.28)     // Android green
    let lineNumberColor = Color(white: 0.42)
    let selectionColor = Color(red: 0.17, green: 0.33, blue: 0.50)

    // MARK: - Syntax (Darcula)
    let syntaxKeyword = Color(red: 0.80, green: 0.50, blue: 0.20)   // Orange
    let syntaxString = Color(red: 0.42, green: 0.60, blue: 0.30)    // Green
    let syntaxComment = Color(red: 0.50, green: 0.50, blue: 0.50)   // Gray
    let syntaxNumber = Color(red: 0.42, green: 0.58, blue: 0.78)    // Blue
    let syntaxType = Color(red: 0.88, green: 0.82, blue: 0.58)      // Light yellow
    let syntaxFunction = Color(red: 0.98, green: 0.78, blue: 0.45)  // Gold
    let syntaxProperty = Color(red: 0.60, green: 0.44, blue: 0.72)  // Purple

    let sidebarWidth: CGFloat = 110
}
