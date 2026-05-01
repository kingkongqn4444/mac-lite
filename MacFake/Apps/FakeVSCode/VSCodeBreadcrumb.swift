import SwiftUI

/// VS Code breadcrumb path bar between tabs and editor
struct VSCodeBreadcrumb: View {
    let theme: VSCodeTheme
    let pathSegments: [String]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(pathSegments.enumerated()), id: \.offset) { index, segment in
                if index > 0 {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 4))
                        .foregroundStyle(theme.textSecondary)
                }
                Text(segment)
                    .font(.system(size: 6.5))
                    .foregroundStyle(index == pathSegments.count - 1 ? theme.textPrimary : theme.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 1)
        .background(theme.editorBackground)
    }
}
