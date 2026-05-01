import SwiftUI

/// A tab in the editor tab bar
struct IDETab: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let iconColor: Color
}

/// Horizontal scrolling tab bar for editor files
struct IDETabBarView: View {
    let theme: any IDETheme
    let tabs: [IDETab]
    @Binding var selectedIndex: Int
    var onClose: ((Int) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                    TabItemView(
                        tab: tab,
                        isActive: index == selectedIndex,
                        theme: theme,
                        onTap: { selectedIndex = index },
                        onClose: { onClose?(index) }
                    )
                }
                Spacer()
            }
        }
        .frame(height: 20)
        .background(theme.tabBarBackground)
    }
}

// MARK: - Tab Item
private struct TabItemView: View {
    let tab: IDETab
    let isActive: Bool
    let theme: any IDETheme
    let onTap: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: tab.icon)
                .font(.system(size: 6))
                .foregroundStyle(tab.iconColor)

            Text(tab.title)
                .font(theme.editorUIFont)
                .foregroundStyle(isActive ? theme.textPrimary : theme.textSecondary)
                .lineLimit(1)

            if isActive {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 5, weight: .bold))
                        .foregroundStyle(theme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 20)
        .background(isActive ? theme.tabActiveBackground : theme.tabInactiveBackground)
        .overlay(alignment: .trailing) {
            theme.separatorColor.frame(width: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
