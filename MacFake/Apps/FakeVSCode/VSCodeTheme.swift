import SwiftUI

/// VS Code Dark+ (Default Dark) theme
struct VSCodeTheme: IDETheme {
    // MARK: - Backgrounds
    let editorBackground = Color(red: 0.118, green: 0.118, blue: 0.118)    // #1e1e1e
    let sidebarBackground = Color(red: 0.145, green: 0.145, blue: 0.149)   // #252526
    let toolbarBackground = Color(red: 0.145, green: 0.145, blue: 0.149)   // #252526
    let terminalBackground = Color(red: 0.118, green: 0.118, blue: 0.118)  // #1e1e1e
    let tabBarBackground = Color(red: 0.145, green: 0.145, blue: 0.149)    // #252526
    let tabActiveBackground = Color(red: 0.118, green: 0.118, blue: 0.118) // #1e1e1e
    let tabInactiveBackground = Color(red: 0.176, green: 0.176, blue: 0.176) // #2d2d2d

    // MARK: - Text
    let textPrimary = Color(red: 0.831, green: 0.831, blue: 0.831)   // #d4d4d4
    let textSecondary = Color(red: 0.522, green: 0.522, blue: 0.522) // #858585
    let accentColor = Color(red: 0.0, green: 0.478, blue: 0.800)     // #007acc
    let lineNumberColor = Color(red: 0.522, green: 0.522, blue: 0.522)
    let selectionColor = Color(red: 0.149, green: 0.310, blue: 0.471) // #264f78

    // MARK: - Syntax (Dark+ defaults)
    let syntaxKeyword = Color(red: 0.337, green: 0.612, blue: 0.839)  // #569cd6 blue
    let syntaxString = Color(red: 0.808, green: 0.569, blue: 0.471)   // #ce9178 orange-brown
    let syntaxComment = Color(red: 0.416, green: 0.600, blue: 0.333)  // #6a9955 green
    let syntaxNumber = Color(red: 0.710, green: 0.808, blue: 0.659)   // #b5cea8 light green
    let syntaxType = Color(red: 0.306, green: 0.788, blue: 0.690)     // #4ec9b0 teal
    let syntaxFunction = Color(red: 0.863, green: 0.863, blue: 0.667) // #dcdcaa yellow
    let syntaxProperty = Color(red: 0.612, green: 0.863, blue: 0.996) // #9cdcfe light blue

    // MARK: - VS Code specific
    let activityBarBackground = Color(red: 0.2, green: 0.2, blue: 0.2) // #333333
    let statusBarBackground = Color(red: 0.0, green: 0.478, blue: 0.800) // #007acc

    let sidebarWidth: CGFloat = 110
}
