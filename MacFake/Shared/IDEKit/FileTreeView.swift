import SwiftUI

/// A node in the fake file tree
struct FileNode: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let iconColor: Color
    let isFolder: Bool
    var children: [FileNode]
    var isExpanded: Bool
    let language: CodeLanguage?
    let content: String?

    init(
        name: String,
        icon: String = "doc",
        iconColor: Color = .gray,
        isFolder: Bool = false,
        children: [FileNode] = [],
        isExpanded: Bool = false,
        language: CodeLanguage? = nil,
        content: String? = nil
    ) {
        self.name = name
        self.icon = icon
        self.iconColor = iconColor
        self.isFolder = isFolder
        self.children = children
        self.isExpanded = isExpanded
        self.language = language
        self.content = content
    }
}

/// Sidebar file navigator with expand/collapse
struct FileTreeView: View {
    let theme: any IDETheme
    @Binding var nodes: [FileNode]
    @Binding var selectedFileId: UUID?
    var onFileSelect: ((FileNode) -> Void)?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(flattenNodes(nodes, depth: 0), id: \.node.id) { item in
                    FileRowView(
                        node: item.node,
                        depth: item.depth,
                        isSelected: selectedFileId == item.node.id,
                        theme: theme
                    ) {
                        handleTap(item.node)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .background(theme.sidebarBackground)
    }

    private func handleTap(_ node: FileNode) {
        if node.isFolder {
            toggleFolder(node.id, in: &nodes)
        } else {
            selectedFileId = node.id
            onFileSelect?(node)
        }
    }

    private func toggleFolder(_ id: UUID, in nodes: inout [FileNode]) {
        for i in nodes.indices {
            if nodes[i].id == id {
                nodes[i].isExpanded.toggle()
                return
            }
            if !nodes[i].children.isEmpty {
                toggleFolder(id, in: &nodes[i].children)
            }
        }
    }

    private struct FlatItem {
        let node: FileNode
        let depth: Int
    }

    private func flattenNodes(_ nodes: [FileNode], depth: Int) -> [FlatItem] {
        var result: [FlatItem] = []
        for node in nodes {
            result.append(FlatItem(node: node, depth: depth))
            if node.isFolder && node.isExpanded {
                result.append(contentsOf: flattenNodes(node.children, depth: depth + 1))
            }
        }
        return result
    }
}

// MARK: - File Row
private struct FileRowView: View {
    let node: FileNode
    let depth: Int
    let isSelected: Bool
    let theme: any IDETheme
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            if node.isFolder {
                Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 5))
                    .foregroundStyle(theme.textSecondary)
                    .frame(width: 7)
            } else {
                Spacer().frame(width: 7)
            }

            Image(systemName: node.icon)
                .font(.system(size: 7))
                .foregroundStyle(node.iconColor)

            Text(node.name)
                .font(theme.editorUIFont)
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.leading, CGFloat(depth) * 8 + 2)
        .padding(.vertical, 1)
        .background(isSelected ? theme.selectionColor.opacity(0.5) : .clear)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
