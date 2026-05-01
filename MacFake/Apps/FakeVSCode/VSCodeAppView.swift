import SwiftUI

/// Fake VS Code IDE app view
struct VSCodeAppView: View {
    let windowState: WindowState
    private let theme = VSCodeTheme()

    @State private var activePanel: VSCodePanel = .explorer
    @State private var fileNodes = Self.sampleFileTree()
    @State private var selectedFileId: UUID?
    @State private var selectedTabIndex = 0
    @State private var codeText = Self.appTsxCode
    @State private var breadcrumb = ["src", "components", "App.tsx"]
    @State private var tabs: [IDETab] = [
        IDETab(title: "App.tsx", icon: "doc", iconColor: .blue),
    ]

    private let terminalCommands: [String: String] = [
        "npm run dev": "> vite\n\n  VITE v5.4.0  ready in 142ms\n\n  ➜  Local:   http://localhost:5173/",
        "npm test": "Tests: 8 passed, 0 failed\nTime: 1.42s",
        "npm run build": "vite v5.4.0 building...\n✓ 42 modules transformed.\n✓ built in 1.23s",
        "git status": "On branch main\nnothing to commit, working tree clean",
        "git log": "commit a1b2c3d (HEAD -> main)\nAuthor: dev <dev@example.com>\n\n    feat: add header component",
        "tsc --noEmit": "Done in 0.8s.",
        "npx prettier --check .": "All matched files use Prettier code style!",
        "ls": "node_modules  public  src  package.json  tsconfig.json  vite.config.ts",
        "pwd": "/Users/admin/projects/my-vscode-project",
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Activity bar
                VSCodeActivityBar(activePanel: $activePanel, theme: theme)

                theme.separatorColor.frame(width: 1)

                // Sidebar
                sidebarContent
                    .frame(width: theme.sidebarWidth)

                theme.separatorColor.frame(width: 1)

                // Editor area
                VStack(spacing: 0) {
                    IDETabBarView(
                        theme: theme, tabs: tabs,
                        selectedIndex: $selectedTabIndex,
                        onClose: { i in
                            if tabs.count > 1 {
                                tabs.remove(at: i)
                                selectedTabIndex = min(selectedTabIndex, tabs.count - 1)
                            }
                        }
                    )

                    VSCodeBreadcrumb(theme: theme, pathSegments: breadcrumb)
                    theme.separatorColor.frame(height: 1)

                    HStack(spacing: 0) {
                        CodeEditorView(theme: theme, language: .typescript, text: $codeText)
                        VSCodeMinimap(theme: theme, codeText: codeText)
                    }

                    theme.separatorColor.frame(height: 1)

                    IDETerminalView(
                        theme: theme, promptPrefix: "$",
                        commandResponses: terminalCommands
                    )
                    .frame(height: 55)
                }
            }

            VSCodeStatusBar(theme: theme)
        }
        .background(theme.editorBackground)
        .onAppear {
            windowState.title = "App.tsx — my-vscode-project — Visual Studio Code"
        }
    }

    @ViewBuilder
    private var sidebarContent: some View {
        switch activePanel {
        case .explorer:
            FileTreeView(
                theme: theme, nodes: $fileNodes,
                selectedFileId: $selectedFileId,
                onFileSelect: { node in openFile(node) }
            )
        case .search:
            VSCodeSearchPanel(theme: theme)
        case .sourceControl:
            VSCodeSourceControlPanel(theme: theme)
        case .extensions:
            VSCodeExtensionsPanel(theme: theme)
        }
    }

    private func openFile(_ node: FileNode) {
        if let content = node.content { codeText = content }
        if !tabs.contains(where: { $0.title == node.name }) {
            tabs.append(IDETab(title: node.name, icon: "doc", iconColor: .blue))
        }
        if let index = tabs.firstIndex(where: { $0.title == node.name }) {
            selectedTabIndex = index
        }
        windowState.title = "\(node.name) — my-vscode-project — Visual Studio Code"
    }
}

// MARK: - Sample Data
extension VSCodeAppView {
    static func sampleFileTree() -> [FileNode] {
        [FileNode(
            name: "my-vscode-project", icon: "folder.fill", iconColor: .blue,
            isFolder: true, children: [
                FileNode(name: ".vscode", icon: "folder.fill", iconColor: .gray, isFolder: true, children: [
                    FileNode(name: "settings.json", icon: "gearshape", iconColor: .gray),
                ]),
                FileNode(name: "src", icon: "folder.fill", iconColor: .yellow, isFolder: true, children: [
                    FileNode(name: "components", icon: "folder.fill", iconColor: .yellow, isFolder: true, children: [
                        FileNode(name: "App.tsx", icon: "doc", iconColor: .blue,
                                 language: .typescript, content: appTsxCode),
                        FileNode(name: "Header.tsx", icon: "doc", iconColor: .blue,
                                 language: .typescript, content: headerTsxCode),
                        FileNode(name: "Footer.tsx", icon: "doc", iconColor: .blue,
                                 language: .typescript, content: footerTsxCode),
                    ], isExpanded: true),
                    FileNode(name: "hooks", icon: "folder.fill", iconColor: .yellow, isFolder: true, children: [
                        FileNode(name: "useCounter.ts", icon: "doc", iconColor: .blue, language: .typescript),
                    ]),
                    FileNode(name: "utils", icon: "folder.fill", iconColor: .yellow, isFolder: true, children: [
                        FileNode(name: "helpers.ts", icon: "doc", iconColor: .blue, language: .typescript),
                    ]),
                    FileNode(name: "main.tsx", icon: "doc", iconColor: .blue, language: .typescript),
                ], isExpanded: true),
                FileNode(name: "package.json", icon: "doc", iconColor: .green),
                FileNode(name: "tsconfig.json", icon: "doc", iconColor: .blue),
                FileNode(name: "vite.config.ts", icon: "doc", iconColor: .purple),
            ], isExpanded: true
        )]
    }

    static let appTsxCode = """
import SwiftUI

struct DesktopView: View {
    @Environment(WindowManager.self) private var windowManager
    @Environment(WallpaperManager.self) private var wallpaperManager
    @State private var activeMenu: String?
    @State private var showSpotlight = false

    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            ZStack(alignment: .top) {
                wallpaper
                    .frame(width: screenSize.width, height: screenSize.height)
                    .clipped()
                desktopIcons(screenSize: screenSize)
                WindowsLayerView(screenSize: screenSize)
                VStack(spacing: 0) {
                    MenuBarView(activeMenu: $activeMenu, screenSize: screenSize)
                    Spacer()
                    DockView(screenSize: screenSize)
                }
            }
        }
        .ignoresSafeArea()
    }
}
"""

    static let headerTsxCode = """
import SwiftUI

@main
struct MacFakeApp: App {
    @State private var windowManager = WindowManager()
    @State private var wallpaperManager = WallpaperManager()
    @State private var bootComplete = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if bootComplete {
                    DesktopView()
                        .environment(windowManager)
                        .environment(wallpaperManager)
                } else {
                    BootScreen(bootComplete: $bootComplete)
                }
            }
            .persistentSystemOverlays(.hidden)
            .statusBarHidden(true)
        }
    }
}
"""

    static let footerTsxCode = """
import SwiftUI

@Observable
final class WindowManager {
    var windows: [WindowState] = []
    var focusedWindowId: UUID?
    private var nextZIndex: Int = 0

    func openApp(_ app: FakeApp, screenSize: CGSize) {
        let window = WindowState(
            app: app,
            position: cascadePosition(for: app, screenSize: screenSize),
            size: app.defaultWindowSize
        )
        windows.append(window)
        bringToFront(window.id)
    }

    func closeWindow(_ id: UUID) {
        windows.removeAll { $0.id == id }
    }
}
"""
}
