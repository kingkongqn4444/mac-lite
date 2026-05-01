import SwiftUI

struct DesktopView: View {
    @Environment(WindowManager.self) private var windowManager
    @Environment(WallpaperManager.self) private var wallpaperManager
    @State private var activeMenu: String?
    @State private var showWiFiDropdown = false
    @State private var showBatteryDropdown = false
    @State private var showClockDropdown = false
    @State private var showSpotlight = false
    @State private var showLaunchpad = false

    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size

            ZStack(alignment: .top) {
                // Layer 0: Wallpaper (fill screen, clipped to bounds)
                wallpaper
                    .frame(width: screenSize.width, height: screenSize.height)
                    .clipped()

                // Layer 1: Desktop icons (top-right)
                desktopIcons(screenSize: screenSize)

                // Layer 2: Windows
                WindowsLayerView(screenSize: screenSize)

                // Layer 3: Menu bar at top
                VStack(spacing: 0) {
                    MenuBarView(
                        activeMenu: $activeMenu,
                        showWiFiDropdown: $showWiFiDropdown,
                        showBatteryDropdown: $showBatteryDropdown,
                        showClockDropdown: $showClockDropdown,
                        screenSize: screenSize
                    )
                    Spacer()
                }

                // Layer 4: Dock at bottom
                VStack {
                    Spacer()
                    DockView(screenSize: screenSize, showLaunchpad: $showLaunchpad)
                        .padding(.bottom, 16)
                }

                // Layer 5: Menu dropdown (above all)
                if let menu = activeMenu {
                    dropdownOverlay(menu: menu, screenSize: screenSize)
                }

                // Layer 6: Spotlight search
                if showSpotlight {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.15)) { showSpotlight = false }
                        }

                    VStack {
                        Spacer().frame(height: screenSize.height * 0.15)
                        SpotlightView(isShowing: $showSpotlight, screenSize: screenSize)
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // Layer 7: Launchpad
                if showLaunchpad {
                    LaunchpadView(isShowing: $showLaunchpad, screenSize: screenSize)
                }

                // Layer 8: Status dropdowns (WiFi, Battery, Clock)
                if showWiFiDropdown || showBatteryDropdown || showClockDropdown {
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            showWiFiDropdown = false
                            showBatteryDropdown = false
                            showClockDropdown = false
                        }

                    VStack {
                        HStack {
                            Spacer()
                            if showWiFiDropdown {
                                WiFiDropdownView(isShowing: $showWiFiDropdown)
                            } else if showBatteryDropdown {
                                BatteryDropdownView()
                            } else if showClockDropdown {
                                ClockDropdownView()
                            }
                            Spacer().frame(width: 56)
                        }
                        .padding(.top, 24)
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Wallpaper

    @ViewBuilder
    private var wallpaper: some View {
        Group {
            if let img = wallpaperManager.wallpaperImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else if let path = Bundle.main.path(forResource: "default_background", ofType: "jpg", inDirectory: "Assets"),
                      let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Final fallback gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.10, blue: 0.25),
                        Color(red: 0.08, green: 0.15, blue: 0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .onTapGesture {
            activeMenu = nil
            showWiFiDropdown = false
            showBatteryDropdown = false
            showClockDropdown = false
            if showSpotlight { showSpotlight = false }
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    // Swipe down on desktop → open Spotlight
                    if value.translation.height > 50 && abs(value.translation.width) < 100 {
                        withAnimation(.spring(response: 0.3)) {
                            showSpotlight = true
                        }
                    }
                }
        )
    }

    // MARK: - Desktop Icons

    private func desktopIcons(screenSize: CGSize) -> some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    DesktopIconView(
                        name: "Macintosh HD",
                        iconName: "internaldrive.fill",
                        iconColor: .gray
                    ) { }

                    DesktopIconView(
                        name: "admin",
                        iconName: "folder.fill",
                        iconColor: .blue
                    ) {
                        windowManager.openApp(.finder, screenSize: screenSize)
                    }
                }
                .padding(.top, 32)
                .padding(.trailing, 12)
            }
            Spacer()
        }
    }

    // MARK: - Dropdown Overlay

    @ViewBuilder
    private func dropdownOverlay(menu: String, screenSize: CGSize) -> some View {
        // Dismiss tap area
        Color.black.opacity(0.001)
            .onTapGesture { activeMenu = nil }

        // Dropdown positioned below menu bar
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 24) // Menu bar height

            HStack(alignment: .top) {
                Spacer().frame(width: max(4, menuDropdownX(for: menu)))

                MenuDropdown(
                    menuName: menu,
                    onAction: { handleMenuAction($0, screenSize: screenSize) },
                    onDismiss: { activeMenu = nil }
                )
                .fixedSize()

                Spacer()
            }

            Spacer()
        }
    }

    // MARK: - Menu Actions

    private func handleMenuAction(_ action: MenuAction, screenSize: CGSize) {
        switch action {
        case .openApp(let app):
            windowManager.openApp(app, screenSize: screenSize)
        case .closeWindow:
            if let focused = windowManager.focusedWindowId {
                withAnimation(.easeOut(duration: 0.15)) {
                    windowManager.closeWindow(focused)
                }
            }
        case .minimizeWindow:
            if let focused = windowManager.focusedWindowId {
                withAnimation(.easeOut(duration: 0.2)) {
                    windowManager.minimizeWindow(focused)
                }
            }
        case .zoomWindow:
            if let focused = windowManager.focusedWindowId {
                withAnimation(.spring(response: 0.3)) {
                    windowManager.maximizeWindow(focused, screenSize: screenSize)
                }
            }
        case .bringAllToFront:
            for window in windowManager.windows where window.isMinimized {
                windowManager.restoreWindow(window.id)
            }
        case .none:
            break
        }
    }

    private func menuDropdownX(for key: String) -> CGFloat {
        let safeLeft: CGFloat = 52 // Dynamic Island left padding
        let appName = windowManager.focusedApp?.displayName ?? "Finder"
        let menuItems = windowManager.focusedApp?.menuItems ?? FakeApp.finder.menuItems

        if key == "__apple" { return safeLeft + 4 }

        let appleWidth: CGFloat = 30
        let appNameWidth = CGFloat(appName.count) * 7 + 16
        var x = safeLeft + appleWidth + appNameWidth

        for item in menuItems {
            if item == key { break }
            x += CGFloat(item.count) * 7 + 16
        }
        return x
    }
}
