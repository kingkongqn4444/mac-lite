import SwiftUI

/// VS Code sidebar panel types
enum VSCodePanel: Int, CaseIterable {
    case explorer, search, sourceControl, extensions

    var icon: String {
        switch self {
        case .explorer: "doc.on.doc"
        case .search: "magnifyingglass"
        case .sourceControl: "arrow.triangle.branch"
        case .extensions: "square.grid.2x2"
        }
    }
}

/// VS Code activity bar — vertical icon strip on the left
struct VSCodeActivityBar: View {
    @Binding var activePanel: VSCodePanel
    let theme: VSCodeTheme

    var body: some View {
        VStack(spacing: 0) {
            ForEach(VSCodePanel.allCases, id: \.rawValue) { panel in
                Button {
                    activePanel = panel
                } label: {
                    Image(systemName: panel.icon)
                        .font(.system(size: 9))
                        .foregroundStyle(panel == activePanel ? .white : theme.textSecondary)
                        .frame(width: 22, height: 22)
                        .overlay(alignment: .leading) {
                            if panel == activePanel {
                                theme.accentColor.frame(width: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
            Spacer()

            // Bottom icons (settings)
            Button {} label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 8))
                    .foregroundStyle(theme.textSecondary)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 22)
        .background(theme.activityBarBackground)
    }
}
