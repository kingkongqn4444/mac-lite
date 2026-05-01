import SwiftUI

/// Xcode-style navigator panel with tab icons and file tree
struct XcodeNavigator: View {
    let theme: XcodeTheme
    @Binding var fileNodes: [FileNode]
    @Binding var selectedFileId: UUID?
    var onFileSelect: ((FileNode) -> Void)?

    @State private var activeTab = 0

    private let navTabs: [(String, String)] = [
        ("folder", "Project"), ("magnifyingglass", "Search"),
        ("exclamationmark.triangle", "Issues"), ("flag", "Breakpoints"),
        ("checkmark.diamond", "Tests"), ("gauge.medium", "Debug"),
        ("doc.text", "Reports"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Navigator tab icons
            HStack(spacing: 0) {
                ForEach(Array(navTabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        activeTab = index
                    } label: {
                        Image(systemName: tab.0)
                            .font(.system(size: 6))
                            .foregroundStyle(index == activeTab ? theme.accentColor : theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 14)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(theme.sidebarBackground)

            theme.separatorColor.frame(height: 1)

            // File tree (only for Project tab, others show placeholder)
            if activeTab == 0 {
                FileTreeView(
                    theme: theme,
                    nodes: $fileNodes,
                    selectedFileId: $selectedFileId,
                    onFileSelect: onFileSelect
                )
            } else {
                VStack {
                    Spacer()
                    Text(navTabs[activeTab].1)
                        .font(theme.editorUIFont)
                        .foregroundStyle(theme.textSecondary)
                    Text("No content")
                        .font(.system(size: 6))
                        .foregroundStyle(theme.textSecondary.opacity(0.6))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(theme.sidebarBackground)
            }
        }
    }
}

// MARK: - Sample Xcode Project Tree
extension XcodeNavigator {
    static func sampleFileTree() -> [FileNode] {
        [FileNode(
            name: "MacFakeProject", icon: "folder.fill", iconColor: .blue,
            isFolder: true, children: [
                FileNode(name: "MacFakeProject", icon: "folder.fill", iconColor: .yellow,
                         isFolder: true, children: [
                    FileNode(name: "AppDelegate.swift", icon: "swift", iconColor: .orange,
                             language: .swift, content: Self.appDelegateCode),
                    FileNode(name: "ContentView.swift", icon: "swift", iconColor: .orange,
                             language: .swift, content: Self.contentViewCode),
                    FileNode(name: "Models", icon: "folder.fill", iconColor: .yellow,
                             isFolder: true, children: [
                        FileNode(name: "User.swift", icon: "swift", iconColor: .orange,
                                 language: .swift, content: Self.userModelCode),
                    ]),
                    FileNode(name: "Views", icon: "folder.fill", iconColor: .yellow,
                             isFolder: true, children: [
                        FileNode(name: "HomeView.swift", icon: "swift", iconColor: .orange,
                                 language: .swift, content: Self.homeViewCode),
                    ]),
                    FileNode(name: "Assets.xcassets", icon: "photo", iconColor: .blue),
                    FileNode(name: "Info.plist", icon: "doc.text", iconColor: .gray),
                ], isExpanded: true),
                FileNode(name: "MacFakeProjectTests", icon: "folder.fill", iconColor: .yellow,
                         isFolder: true, children: [
                    FileNode(name: "Tests.swift", icon: "swift", iconColor: .orange,
                             language: .swift),
                ]),
            ], isExpanded: true
        )]
    }

    // MARK: - Sample Swift Code
    static let contentViewCode = """
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

    static let appDelegateCode = """
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
                        .transition(.opacity)
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

    static let userModelCode = """
import SwiftUI

enum FakeApp: String, CaseIterable, Identifiable {
    case finder, safari, calculator, notes, textEdit
    case terminal, settings, aboutMac
    case photos, music, maps, calendar
    case xcode, vscode, androidStudio

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .finder: "Finder"
        case .safari: "Safari"
        case .calculator: "Calculator"
        case .xcode: "Xcode"
        case .vscode: "Visual Studio Code"
        default: rawValue.capitalized
        }
    }
}
"""

    static let homeViewCode = """
import SwiftUI

@Observable
final class WindowManager {
    var windows: [WindowState] = []
    var focusedWindowId: UUID?
    private var nextZIndex: Int = 0

    func openApp(_ app: FakeApp, screenSize: CGSize) {
        let position = cascadePosition(for: app, screenSize: screenSize)
        let window = WindowState(
            app: app, position: position,
            size: app.defaultWindowSize
        )
        windows.append(window)
        bringToFront(window.id)
    }

    func closeWindow(_ id: UUID) {
        windows.removeAll { $0.id == id }
    }

    func bringToFront(_ id: UUID) {
        guard let index = windows.firstIndex(where: { $0.id == id }) else { return }
        nextZIndex += 1
        windows[index].zIndex = nextZIndex
        focusedWindowId = id
    }
}
"""
}
