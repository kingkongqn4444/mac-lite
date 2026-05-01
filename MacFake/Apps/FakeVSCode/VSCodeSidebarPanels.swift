import SwiftUI

/// Static search panel for VS Code sidebar
struct VSCodeSearchPanel: View {
    let theme: VSCodeTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SEARCH")
                .font(.system(size: 6, weight: .semibold))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 8)
                .padding(.top, 6)

            // Search input placeholder
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 6))
                    .foregroundStyle(theme.textSecondary)
                Text("Search")
                    .font(.system(size: 5))
                    .foregroundStyle(theme.textSecondary.opacity(0.6))
                Spacer()
            }
            .padding(5)
            .background(Color(white: 0.22))
            .cornerRadius(3)
            .padding(.horizontal, 8)

            Text("3 results in 2 files")
                .font(.system(size: 6))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 8)

            // Fake search results
            VStack(alignment: .leading, spacing: 2) {
                searchResultGroup("App.tsx", results: [
                    ("5", "import { Header } from './Header'"),
                    ("12", "const [count, setCount] = useState(0)"),
                ])
                searchResultGroup("main.tsx", results: [
                    ("3", "import { App } from './components/App'"),
                ])
            }
            .padding(.horizontal, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.sidebarBackground)
    }

    private func searchResultGroup(_ file: String, results: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(file)
                .font(.system(size: 7, weight: .medium))
                .foregroundStyle(theme.textPrimary)
                .padding(.leading, 4)
            ForEach(results, id: \.0) { line, text in
                HStack(spacing: 4) {
                    Text("L\(line):")
                        .font(.system(size: 5.5, design: .monospaced))
                        .foregroundStyle(theme.textSecondary)
                    Text(text)
                        .font(.system(size: 6, design: .monospaced))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)
                }
                .padding(.leading, 12)
            }
        }
    }
}

/// Static source control panel
struct VSCodeSourceControlPanel: View {
    let theme: VSCodeTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SOURCE CONTROL")
                .font(.system(size: 6, weight: .semibold))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 8)
                .padding(.top, 6)

            Text("0 pending changes")
                .font(.system(size: 5))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 8)

            Divider().background(theme.separatorColor)

            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 6))
                    .foregroundStyle(.green)
                Text("feat: add header component")
                    .font(.system(size: 6))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.sidebarBackground)
    }
}

/// Static extensions panel
struct VSCodeExtensionsPanel: View {
    let theme: VSCodeTheme

    private let extensions: [(String, String)] = [
        ("Prettier", "Prettier"), ("ESLint", "Microsoft"),
        ("GitLens", "GitKraken"), ("Thunder Client", "Thunder"),
        ("GitHub Copilot", "GitHub"), ("Tailwind CSS", "Tailwind Labs"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("INSTALLED (\(extensions.count))")
                .font(.system(size: 6, weight: .semibold))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 8)
                .padding(.top, 6)

            ForEach(extensions, id: \.0) { name, author in
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.accentColor.opacity(0.3))
                        .frame(width: 14, height: 14)
                        .overlay {
                            Image(systemName: "puzzlepiece.extension")
                                .font(.system(size: 6))
                                .foregroundStyle(theme.accentColor)
                        }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(name)
                            .font(.system(size: 7, weight: .medium))
                            .foregroundStyle(theme.textPrimary)
                        Text(author)
                            .font(.system(size: 6))
                            .foregroundStyle(theme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 5))
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.sidebarBackground)
    }
}
