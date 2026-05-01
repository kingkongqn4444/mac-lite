import SwiftUI

/// Fake Xcode IDE app view
struct XcodeAppView: View {
    let windowState: WindowState
    private let theme = XcodeTheme()

    @State private var fileNodes = XcodeNavigator.sampleFileTree()
    @State private var selectedFileId: UUID?
    @State private var selectedTabIndex = 0
    @State private var codeText = XcodeNavigator.contentViewCode
    @State private var tabs: [IDETab] = [
        IDETab(title: "ContentView.swift", icon: "swift", iconColor: .orange),
    ]
    @State private var terminalOutput = ""

    private let terminalCommands: [String: String] = [
        "swift build": "Build complete! (0.42s)",
        "swift run": "Running MacFakeProject...\nHello, World!",
        "xcodebuild": "** BUILD SUCCEEDED **",
        "swift test": "Test Suite 'All tests' passed.\n  Executed 3 tests, with 0 failures (0 unexpected) in 0.124s",
        "swift package resolve": "Fetching dependencies...\nResolved.",
        "ls": "MacFakeProject  MacFakeProject.xcodeproj  MacFakeProjectTests",
        "pwd": "/Users/admin/Developer/MacFakeProject",
    ]

    var body: some View {
        IDELayoutView(theme: theme) {
            XcodeToolbar(theme: theme, onRun: {
                terminalOutput = "$ xcodebuild -scheme MacFake build"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    terminalOutput = "** BUILD SUCCEEDED **"
                }
            }, onStop: {
                terminalOutput = "Build cancelled."
            })
        } sidebar: {
            XcodeNavigator(
                theme: theme,
                fileNodes: $fileNodes,
                selectedFileId: $selectedFileId,
                onFileSelect: { node in
                    openFile(node)
                }
            )
        } editor: {
            VStack(spacing: 0) {
                IDETabBarView(
                    theme: theme,
                    tabs: tabs,
                    selectedIndex: $selectedTabIndex,
                    onClose: { index in
                        if tabs.count > 1 {
                            tabs.remove(at: index)
                            selectedTabIndex = min(selectedTabIndex, tabs.count - 1)
                        }
                    }
                )
                theme.separatorColor.frame(height: 1)
                CodeEditorView(theme: theme, language: .swift, text: $codeText)
            }
        } bottomPanel: {
            IDETerminalView(
                theme: theme,
                promptPrefix: "admin@MacBook-Pro ~",
                commandResponses: terminalCommands,
                externalOutput: $terminalOutput
            )
        }
        .onAppear {
            windowState.title = "MacFakeProject — ContentView.swift"
        }
    }

    private func openFile(_ node: FileNode) {
        if let content = node.content {
            codeText = content
        }
        // Add tab if not already open
        if !tabs.contains(where: { $0.title == node.name }) {
            tabs.append(IDETab(
                title: node.name,
                icon: "swift",
                iconColor: .orange
            ))
        }
        if let index = tabs.firstIndex(where: { $0.title == node.name }) {
            selectedTabIndex = index
        }
        windowState.title = "MacFakeProject — \(node.name)"
    }
}
