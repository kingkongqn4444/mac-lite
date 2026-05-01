import SwiftUI

struct SpotlightView: View {
    @Environment(WindowManager.self) private var windowManager
    @Binding var isShowing: Bool
    @State private var searchText = ""
    @State private var selectedIndex = 0
    @FocusState private var isFocused: Bool
    let screenSize: CGSize

    private var results: [SpotlightResult] {
        guard !searchText.isEmpty else { return defaultSuggestions }
        let query = searchText.lowercased()
        var matches: [SpotlightResult] = []
        for app in FakeApp.allCases where app != .aboutMac {
            if app.displayName.lowercased().contains(query) {
                matches.append(SpotlightResult(
                    name: app.displayName, icon: app.iconName, iconColor: app.iconColor,
                    type: "Application", app: app
                ))
            }
        }
        // System commands
        let cmds: [(String, String, Color)] = [
            ("About This Mac", "apple.logo", .white),
            ("System Settings", "gearshape.fill", .gray),
            ("Restart", "arrow.clockwise", .gray),
            ("Sleep", "moon.fill", .indigo),
            ("Lock Screen", "lock.fill", .blue),
        ]
        for (name, icon, color) in cmds {
            if name.lowercased().contains(query) {
                matches.append(SpotlightResult(name: name, icon: icon, iconColor: color, type: "Command", app: nil))
            }
        }
        return matches
    }

    private var defaultSuggestions: [SpotlightResult] {
        FakeApp.dockApps.prefix(7).map { app in
            SpotlightResult(name: app.displayName, icon: app.iconName, iconColor: app.iconColor, type: "Application", app: app)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search input
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(white: 0.5))

                TextField("Search for apps and commands...", text: $searchText)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isFocused)
                    .onChange(of: searchText) { selectedIndex = 0 }
                    .onSubmit { activateSelected() }

                Spacer()

                // Keyboard hints
                HStack(spacing: 4) {
                    keyHint("Tab")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(white: 0.18))

            // Divider
            Rectangle().fill(Color(white: 0.25)).frame(height: 1)

            // Results
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if !results.isEmpty {
                        Text(searchText.isEmpty ? "Suggestions" : "Results")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(white: 0.45))
                            .padding(.horizontal, 14)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                    }

                    ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                        resultRow(result, index: index)
                    }
                }
            }
            .frame(maxHeight: 220)
            .background(Color(white: 0.13))

            // Footer
            Rectangle().fill(Color(white: 0.25)).frame(height: 1)
            HStack {
                Spacer()
                HStack(spacing: 12) {
                    footerAction("Open", key: "↩")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color(white: 0.15))
        }
        .frame(width: min(520, screenSize.width * 0.65))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(white: 0.3), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.6), radius: 24, y: 8)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isFocused = true }
        }
    }

    // MARK: - Result Row

    @ViewBuilder
    private func resultRow(_ result: SpotlightResult, index: Int) -> some View {
        Button {
            selectedIndex = index
            activateSelected()
        } label: {
            HStack(spacing: 10) {
                // App icon
                Image(systemName: result.icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(result.iconColor.gradient)
                    )

                // Name
                Text(result.name)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)

                Spacer()

                // Type badge
                Text(result.type)
                    .font(.system(size: 9))
                    .foregroundStyle(Color(white: 0.45))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(white: 0.2))
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(index == selectedIndex ? Color(white: 0.22) : .clear)
                    .padding(.horizontal, 6)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func keyHint(_ key: String) -> some View {
        Text(key)
            .font(.system(size: 9, weight: .medium, design: .rounded))
            .foregroundStyle(Color(white: 0.5))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(white: 0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color(white: 0.35), lineWidth: 0.5)
                    )
            )
    }

    @ViewBuilder
    private func footerAction(_ label: String, key: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color(white: 0.5))
            keyHint(key)
        }
    }

    private func activateSelected() {
        guard selectedIndex < results.count else { return }
        let result = results[selectedIndex]
        if let app = result.app {
            windowManager.openApp(app, screenSize: screenSize)
        }
        isFocused = false
        isShowing = false
        searchText = ""
    }
}

struct SpotlightResult: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let iconColor: Color
    let type: String
    let app: FakeApp?
}
