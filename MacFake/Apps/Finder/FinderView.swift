import SwiftUI

struct FinderView: View {
    let windowState: WindowState
    @Environment(WindowManager.self) private var windowManager
    @State private var fileSystem = FakeFileSystem.shared
    @State private var currentPath: [FakeNode] = []
    @State private var isListView = true
    @State private var selectedSidebar = "admin"

    private var currentFolder: FakeNode {
        currentPath.last ?? fileSystem.root
    }

    private var currentChildren: [FakeNode] {
        currentFolder.children ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            finderToolbar
            Divider()
            HStack(spacing: 0) {
                finderSidebar
                    .frame(width: 120)
                Divider()
                finderContent
            }
            Divider()
            pathBar
        }
        .onAppear {
            if let users = fileSystem.root.children?.first(where: { $0.name == "Users" }),
               let admin = users.children?.first(where: { $0.name == "admin" }) {
                currentPath = [fileSystem.root, users, admin]
            }
            updateTitle()
        }
    }

    // MARK: - Toolbar

    private var finderToolbar: some View {
        HStack(spacing: 6) {
            Button { goBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 8))
            }
            .disabled(currentPath.count <= 1)

            Button {} label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 8))
            }
            .disabled(true)

            Spacer()

            Text(currentFolder.name)
                .font(.system(size: 9, weight: .medium))

            Spacer()

            // View mode toggle
            Picker("View", selection: $isListView) {
                Image(systemName: "list.bullet").tag(true)
                Image(systemName: "square.grid.2x2").tag(false)
            }
            .pickerStyle(.segmented)
            .frame(width: 50)
            .controlSize(.mini)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .buttonStyle(.plain)
    }

    // MARK: - Sidebar

    private var finderSidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                sidebarSection("Favorites") {
                    sidebarItem("Recents", icon: "clock.fill", id: "recents") {
                        navigateToPath(["Users", "admin"])
                    }
                    sidebarItem("Applications", icon: "square.grid.2x2.fill", id: "apps") {
                        navigateToPath(["Applications"])
                    }
                    sidebarItem("Desktop", icon: "menubar.dock.rectangle", id: "desktop") {
                        navigateToPath(["Users", "admin", "Desktop"])
                    }
                    sidebarItem("Documents", icon: "doc.fill", id: "documents") {
                        navigateToPath(["Users", "admin", "Documents"])
                    }
                    sidebarItem("Downloads", icon: "arrow.down.circle.fill", id: "downloads") {
                        navigateToPath(["Users", "admin", "Downloads"])
                    }
                }

                sidebarSection("Locations") {
                    sidebarItem("Macintosh HD", icon: "internaldrive.fill", id: "hd") {
                        currentPath = [fileSystem.root]
                        updateTitle()
                    }
                }
            }
            .padding(.top, 4)
        }
        .background(MacColors.sidebarBackground)
    }

    @ViewBuilder
    private func sidebarSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(MacColors.tertiaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
            content()
        }
    }

    private func sidebarItem(_ name: String, icon: String, id: String, action: @escaping () -> Void) -> some View {
        Button {
            selectedSidebar = id
            action()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundStyle(.blue)
                    .frame(width: 14)
                Text(name)
                    .font(.system(size: 9))
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selectedSidebar == id ? Color.blue.opacity(0.2) : .clear)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
    }

    // MARK: - Content

    @ViewBuilder
    private var finderContent: some View {
        if isListView {
            listView
        } else {
            iconGridView
        }
    }

    // MARK: - List View

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Header
                HStack {
                    Text("Name").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Size").frame(width: 50, alignment: .trailing)
                    Text("Modified").frame(width: 65, alignment: .trailing)
                }
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(MacColors.tertiaryText)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)

                Divider()

                ForEach(currentChildren) { node in
                    listRow(node)
                }
            }
        }
    }

    @ViewBuilder
    private func listRow(_ node: FakeNode) -> some View {
        Button {
            handleNodeTap(node)
        } label: {
            HStack(spacing: 4) {
                nodeIcon(node, size: 12)
                    .frame(width: 14)
                Text(node.name)
                    .font(.system(size: 9))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(node.formattedSize)
                    .font(.system(size: 8))
                    .foregroundStyle(MacColors.secondaryText)
                    .frame(width: 50, alignment: .trailing)
                Text(node.modifiedDate, style: .date)
                    .font(.system(size: 8))
                    .foregroundStyle(MacColors.secondaryText)
                    .frame(width: 65, alignment: .trailing)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Icon Grid View

    private var iconGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 52))], spacing: 4) {
                ForEach(currentChildren) { node in
                    Button {
                        handleNodeTap(node)
                    } label: {
                        VStack(spacing: 2) {
                            nodeIcon(node, size: 32)
                                .frame(width: 36, height: 36)
                            Text(node.name.replacingOccurrences(of: ".app", with: ""))
                                .font(.system(size: 7))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 52, height: 56)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
        }
    }

    // MARK: - Node Icon (supports real app icons from Assets/)

    @ViewBuilder
    private func nodeIcon(_ node: FakeNode, size: CGFloat) -> some View {
        if let app = node.fakeApp,
           let assetName = app.iconAssetName,
           let path = Bundle.main.path(forResource: assetName, ofType: "png", inDirectory: "Assets"),
           let uiImage = UIImage(contentsOfFile: path) {
            // Real app icon from Assets/
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        } else if node.isFolder {
            Image(systemName: "folder.fill")
                .font(.system(size: size * 0.8))
                .foregroundStyle(.blue)
        } else if node.fakeApp != nil {
            // App without custom icon — use SF Symbol with gradient background
            Image(systemName: node.fakeApp!.iconName)
                .font(.system(size: size * 0.4))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: size * 0.22)
                        .fill(node.fakeApp!.iconColor.gradient)
                )
        } else {
            Image(systemName: node.icon)
                .font(.system(size: size * 0.7))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Path Bar

    private var pathBar: some View {
        HStack(spacing: 3) {
            ForEach(Array(currentPath.enumerated()), id: \.element.id) { index, node in
                if index > 0 {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 5))
                        .foregroundStyle(MacColors.tertiaryText)
                }
                Button(node.name) {
                    currentPath = Array(currentPath.prefix(index + 1))
                    updateTitle()
                }
                .font(.system(size: 8))
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(white: 0.97))
    }

    // MARK: - Navigation & Actions

    private func handleNodeTap(_ node: FakeNode) {
        if let app = node.fakeApp {
            // Launch the app
            let screen = UIScreen.main.bounds.size
            windowManager.openApp(app, screenSize: screen)
        } else if node.isFolder {
            navigateInto(node)
        }
    }

    private func navigateInto(_ folder: FakeNode) {
        currentPath.append(folder)
        updateTitle()
    }

    private func goBack() {
        guard currentPath.count > 1 else { return }
        currentPath.removeLast()
        updateTitle()
    }

    private func navigateToPath(_ pathNames: [String]) {
        var path: [FakeNode] = [fileSystem.root]
        var current = fileSystem.root
        for name in pathNames {
            if let child = current.children?.first(where: { $0.name == name }) {
                path.append(child)
                current = child
            }
        }
        currentPath = path
        updateTitle()
    }

    private func updateTitle() {
        windowState.title = currentPath.last?.name ?? "Finder"
    }
}
