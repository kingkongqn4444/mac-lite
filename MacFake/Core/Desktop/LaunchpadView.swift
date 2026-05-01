import SwiftUI

/// Full-screen Launchpad overlay with blurred background and app grid
struct LaunchpadView: View {
    @Binding var isShowing: Bool
    @Environment(WindowManager.self) private var windowManager
    let screenSize: CGSize

    @State private var searchText = ""

    /// All launchable apps (excluding aboutMac)
    private var allApps: [FakeApp] {
        FakeApp.allCases.filter { $0 != .aboutMac && $0 != .finder }
    }

    private var filteredApps: [FakeApp] {
        if searchText.isEmpty { return allApps }
        return allApps.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            // Blurred dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 8) {
                // Search bar
                searchBar
                    .padding(.top, 30)

                // App grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: gridColumns, spacing: 10) {
                        ForEach(filteredApps) { app in
                            appIcon(app)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Page dots (decorative)
                HStack(spacing: 4) {
                    Circle().fill(.white).frame(width: 5, height: 5)
                    Circle().fill(.white.opacity(0.4)).frame(width: 5, height: 5)
                }
                .padding(.bottom, 50)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Grid columns

    private var gridColumns: [GridItem] {
        let count = screenSize.width > 700 ? 8 : 6
        return Array(repeating: GridItem(.flexible(), spacing: 6), count: count)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.6))
            TextField("Search", text: $searchText)
                .font(.system(size: 10))
                .foregroundStyle(.white)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.white.opacity(0.15))
        .cornerRadius(6)
        .frame(width: 180)
    }

    // MARK: - App Icon

    private func appIcon(_ app: FakeApp) -> some View {
        Button {
            launchApp(app)
        } label: {
            VStack(spacing: 3) {
                appIconImage(app)
                    .frame(width: 40, height: 40)

                Text(app.displayName)
                    .font(.system(size: 7))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(width: 55)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func appIconImage(_ app: FakeApp) -> some View {
        if let assetName = app.iconAssetName,
           let path = Bundle.main.path(forResource: assetName, ofType: "png", inDirectory: "Assets"),
           let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        } else {
            // SF Symbol fallback
            Image(systemName: app.iconName)
                .font(.system(size: 18))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .fill(app.iconColor.gradient)
                )
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        }
    }

    // MARK: - Actions

    private func launchApp(_ app: FakeApp) {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            windowManager.openApp(app, screenSize: screenSize)
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) { isShowing = false }
    }
}
