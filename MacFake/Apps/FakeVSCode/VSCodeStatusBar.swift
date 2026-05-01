import SwiftUI

/// VS Code bottom status bar
struct VSCodeStatusBar: View {
    let theme: VSCodeTheme

    var body: some View {
        HStack(spacing: 0) {
            // Left section
            HStack(spacing: 8) {
                // Branch
                HStack(spacing: 3) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 5))
                    Text("main")
                        .font(.system(size: 6))
                }

                // Diagnostics
                HStack(spacing: 6) {
                    HStack(spacing: 2) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 5))
                        Text("0")
                            .font(.system(size: 6))
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 5))
                        Text("0")
                            .font(.system(size: 6))
                    }
                }
            }
            .padding(.leading, 8)

            Spacer()

            // Right section
            HStack(spacing: 10) {
                Text("Ln 4, Col 8")
                Text("Spaces: 2")
                Text("UTF-8")
                Text("TypeScript React")
                HStack(spacing: 2) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 7))
                    Text("Prettier")
                }
            }
            .font(.system(size: 6))
            .padding(.trailing, 8)
        }
        .foregroundStyle(.white)
        .frame(height: 14)
        .background(theme.statusBarBackground)
    }
}
