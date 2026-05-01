import SwiftUI

private struct MenuButtonPreferenceKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct MenuBarView: View {
    @Environment(WindowManager.self) private var windowManager
    @Binding var activeMenu: String?
    @Binding var showWiFiDropdown: Bool
    @Binding var showBatteryDropdown: Bool
    @Binding var showClockDropdown: Bool
    @State private var currentTime = Date()
    @State private var menuPositions: [String: CGRect] = [:]
    let screenSize: CGSize

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var appName: String {
        windowManager.focusedApp?.displayName ?? "Finder"
    }

    private var menuItems: [String] {
        windowManager.focusedApp?.menuItems ?? FakeApp.finder.menuItems
    }

    var body: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 52) // Safe area for Dynamic Island left

            menuButton("apple.logo", key: "__apple", isSymbol: true)

            Text(appName)
                .font(MacFonts.menuBarBold)
                .foregroundStyle(MacColors.menuBarText)
                .padding(.horizontal, 8)

            ForEach(menuItems, id: \.self) { item in
                menuButton(item, key: item)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    showWiFiDropdown.toggle()
                    showBatteryDropdown = false
                    showClockDropdown = false
                    activeMenu = nil
                } label: {
                    Image(systemName: "wifi")
                        .font(.system(size: 11))
                        .foregroundStyle(MacColors.menuBarText)
                }
                .buttonStyle(.plain)

                Button {
                    showBatteryDropdown.toggle()
                    showWiFiDropdown = false
                    showClockDropdown = false
                    activeMenu = nil
                } label: {
                    Image(systemName: batteryIcon)
                        .font(.system(size: 13))
                        .foregroundStyle(MacColors.menuBarText)
                }
                .buttonStyle(.plain)

                Button {
                    showClockDropdown.toggle()
                    showWiFiDropdown = false
                    showBatteryDropdown = false
                    activeMenu = nil
                } label: {
                    Text(timeString)
                        .font(MacFonts.menuBar)
                        .foregroundStyle(MacColors.menuBarText)
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(MacColors.menuBarText)
            .padding(.trailing, 56)
        }
        .frame(height: 24)
        .background(.ultraThinMaterial.opacity(0.8))
        .background(MacColors.menuBarBackground)
        .backgroundPreferenceValue(MenuButtonPreferenceKey.self) { prefs in
            GeometryReader { geometry in
                Color.clear
                    .onAppear { updatePositions(prefs, in: geometry) }
                    .onChange(of: prefs.count) { updatePositions(prefs, in: geometry) }
            }
        }
        .onReceive(timer) { currentTime = $0 }
    }

    /// Returns the x-offset for the dropdown of the given menu key
    func dropdownX(for key: String) -> CGFloat {
        menuPositions[key]?.minX ?? 0
    }

    // MARK: - Action Handler

    func handleAction(_ action: MenuAction) {
        switch action {
        case .openApp(let app):
            windowManager.openApp(app, screenSize: screenSize)
        case .closeWindow:
            if let focused = windowManager.focusedWindowId {
                windowManager.closeWindow(focused)
            }
        case .minimizeWindow:
            if let focused = windowManager.focusedWindowId {
                windowManager.minimizeWindow(focused)
            }
        case .zoomWindow:
            if let focused = windowManager.focusedWindowId {
                windowManager.maximizeWindow(focused, screenSize: screenSize)
            }
        case .bringAllToFront:
            for window in windowManager.windows where window.isMinimized {
                windowManager.restoreWindow(window.id)
            }
        case .none:
            break
        }
    }

    private func updatePositions(_ prefs: [String: Anchor<CGRect>], in geometry: GeometryProxy) {
        for (key, anchor) in prefs {
            menuPositions[key] = geometry[anchor]
        }
    }

    private var batteryIcon: String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState
        let charging = state == .charging || state == .full
        if level > 0.75 { return charging ? "battery.100.bolt" : "battery.100" }
        if level > 0.5 { return charging ? "battery.75.bolt" : "battery.75" }
        if level > 0.25 { return charging ? "battery.50.bolt" : "battery.50" }
        return charging ? "battery.25.bolt" : "battery.25"
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d  h:mm a"
        return formatter.string(from: currentTime)
    }

    @ViewBuilder
    private func menuButton(_ title: String, key: String, isSymbol: Bool = false) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.1)) {
                activeMenu = activeMenu == key ? nil : key
            }
        } label: {
            Group {
                if isSymbol {
                    Image(systemName: title)
                        .font(.system(size: 13, weight: .medium))
                } else {
                    Text(title)
                        .font(MacFonts.menuBar)
                }
            }
            .foregroundStyle(MacColors.menuBarText)
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(activeMenu == key ? MacColors.menuBarActiveItem : .clear)
            )
        }
        .buttonStyle(.plain)
        .frame(height: 24) // Full menu bar height = tap area
        .contentShape(Rectangle())
        .anchorPreference(key: MenuButtonPreferenceKey.self, value: .bounds) { [key: $0] }
    }
}
