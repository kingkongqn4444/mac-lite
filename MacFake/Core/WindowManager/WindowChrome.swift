import SwiftUI

struct WindowChrome<Content: View>: View {
    let window: WindowState
    let isFocused: Bool
    let onClose: () -> Void
    let onMinimize: () -> Void
    let onMaximize: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                TrafficLightButtons(
                    onClose: onClose,
                    onMinimize: onMinimize,
                    onMaximize: onMaximize
                )
                .padding(.leading, 8)

                Spacer()

                Text(window.title)
                    .font(MacFonts.windowTitle)
                    .foregroundStyle(isFocused ? MacColors.windowTitleText : MacColors.tertiaryText)
                    .lineLimit(1)

                Spacer()

                // Balance the traffic lights width
                Color.clear.frame(width: 54)
            }
            .frame(height: 28)
            .background(isFocused ? MacColors.windowTitleBarActive : MacColors.windowTitleBar)

            // Separator
            Rectangle()
                .fill(MacColors.windowBorder)
                .frame(height: 0.5)

            // Content area
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(MacColors.windowBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(MacColors.windowBorder, lineWidth: 0.5)
        )
    }
}
