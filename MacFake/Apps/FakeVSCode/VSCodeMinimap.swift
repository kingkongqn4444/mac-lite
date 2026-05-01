import SwiftUI

/// VS Code minimap — thin code preview on right edge of editor
struct VSCodeMinimap: View {
    let theme: VSCodeTheme
    let codeText: String

    private var lines: [MinimapLine] {
        codeText.components(separatedBy: "\n").prefix(60).map { line in
            MinimapLine(
                width: min(CGFloat(line.count) * 0.8, 18),
                color: colorForLine(line)
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            // Viewport indicator
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.08))
                .frame(width: 20, height: 40)
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(Array(lines.prefix(15).enumerated()), id: \.offset) { _, line in
                            RoundedRectangle(cornerRadius: 0.5)
                                .fill(line.color.opacity(0.7))
                                .frame(width: line.width, height: 1.5)
                        }
                    }
                    .padding(2)
                }

            // Rest of the minimap
            ForEach(Array(lines.dropFirst(15).enumerated()), id: \.offset) { _, line in
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(line.color.opacity(0.4))
                    .frame(width: line.width, height: 1.5)
            }

            Spacer()
        }
        .frame(width: 20)
        .padding(.top, 4)
        .padding(.horizontal, 1)
        .background(theme.editorBackground.opacity(0.9))
    }

    private struct MinimapLine {
        let width: CGFloat
        let color: Color
    }

    private func colorForLine(_ line: String) -> Color {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") || trimmed.hasPrefix("*") {
            return theme.syntaxComment
        }
        if trimmed.contains("import ") || trimmed.contains("export ") || trimmed.contains("const ") ||
            trimmed.contains("return ") || trimmed.contains("function ") {
            return theme.syntaxKeyword
        }
        if trimmed.contains("\"") || trimmed.contains("'") || trimmed.contains("`") {
            return theme.syntaxString
        }
        if trimmed.isEmpty { return .clear }
        return theme.textPrimary
    }
}
