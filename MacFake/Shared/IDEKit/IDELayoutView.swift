import SwiftUI

/// Configurable split-pane layout container for IDE apps
struct IDELayoutView<Toolbar: View, Sidebar: View, Editor: View, BottomPanel: View>: View {
    let theme: any IDETheme
    @ViewBuilder var toolbar: () -> Toolbar
    @ViewBuilder var sidebar: () -> Sidebar
    @ViewBuilder var editor: () -> Editor
    @ViewBuilder var bottomPanel: () -> BottomPanel

    @State private var showSidebar = true
    @State private var showBottomPanel = true
    @State private var bottomPanelHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbar()
                .frame(height: 22)
                .background(theme.toolbarBackground)

            theme.separatorColor.frame(height: 1)

            // Main content area
            HStack(spacing: 0) {
                // Sidebar
                if showSidebar {
                    sidebar()
                        .frame(width: theme.sidebarWidth)

                    theme.separatorColor.frame(width: 1)
                }

                // Editor + Bottom panel
                VStack(spacing: 0) {
                    editor()

                    if showBottomPanel {
                        theme.separatorColor.frame(height: 1)

                        bottomPanel()
                            .frame(height: bottomPanelHeight)
                    }
                }
            }
        }
        .background(theme.editorBackground)
    }
}
