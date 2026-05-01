import SwiftUI

import Photos

struct SettingsView: View {
    let windowState: WindowState
    @Environment(WallpaperManager.self) private var wallpaperManager
    @State private var selectedPanel = "General"
    @State private var photoAssets: [PHAsset] = []
    @State private var photosAuthorized = false

    var body: some View {
        HStack(spacing: 0) {
            settingsSidebar
                .frame(width: 190)
            Divider()
            settingsDetail
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { windowState.title = "System Settings" }
    }

    // MARK: - Sidebar

    private var settingsSidebar: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // User profile
                HStack(spacing: 8) {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 32, height: 32)
                        .overlay(Text("A").font(.system(size: 14, weight: .medium)).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Admin User").font(.system(size: 11, weight: .medium))
                        Text("Apple Account").font(.system(size: 9)).foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 10).padding(.vertical, 6)

                sidebarDivider

                sidebarItem("Wi-Fi", icon: "wifi", color: .blue)
                sidebarItem("Bluetooth", icon: "b.circle.fill", color: .blue)
                sidebarItem("Network", icon: "globe", color: .blue)

                sidebarDivider

                sidebarItem("General", icon: "gear", color: .gray)
                sidebarItem("Accessibility", icon: "accessibility", color: .blue)
                sidebarItem("Appearance", icon: "paintbrush.fill", color: .purple)

                sidebarDivider

                sidebarItem("Desktop & Dock", icon: "dock.rectangle", color: .blue)
                sidebarItem("Displays", icon: "display", color: .blue)
                sidebarItem("Wallpaper", icon: "photo.fill", color: .cyan)

                sidebarDivider

                sidebarItem("Notifications", icon: "bell.badge.fill", color: .red)
                sidebarItem("Sound", icon: "speaker.wave.3.fill", color: .pink)
                sidebarItem("Battery", icon: "battery.100", color: .green)

                sidebarDivider

                sidebarItem("Privacy & Security", icon: "hand.raised.fill", color: .blue)
            }
            .padding(.vertical, 4)
        }
        .background(Color(white: 0.95))
    }

    @ViewBuilder
    private func sidebarItem(_ title: String, icon: String, color: Color) -> some View {
        Button { selectedPanel = title } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(RoundedRectangle(cornerRadius: 4).fill(color.gradient))

                Text(title)
                    .font(.system(size: 11))
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 10).padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(selectedPanel == title ? Color.accentColor : .clear)
                    .padding(.horizontal, 6)
            )
            .foregroundStyle(selectedPanel == title ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    private var sidebarDivider: some View {
        Divider().padding(.horizontal, 10).padding(.vertical, 3)
    }

    // MARK: - Detail Panel

    @ViewBuilder
    private var settingsDetail: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                switch selectedPanel {
                case "General": generalPanel
                case "Wi-Fi": wifiPanel
                case "Appearance": appearancePanel
                case "Desktop & Dock": dockPanel
                case "Displays": displaysPanel
                case "Battery": batteryPanel
                case "Sound": soundPanel
                case "Wallpaper": wallpaperPanel
                default: genericPanel(selectedPanel)
                }
            }
            .padding(14)
        }
        .background(Color(white: 0.92))
    }

    // MARK: - General

    private var generalPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            panelTitle("General")

            settingsGroup {
                settingsRow("About", icon: "info.circle.fill", color: .gray, detail: "MacBook Pro")
                groupDivider
                settingsRow("Software Update", icon: "arrow.triangle.2.circlepath", color: .gray, detail: "Up to Date")
                groupDivider
                settingsRow("Storage", icon: "internaldrive.fill", color: .gray, detail: "234 GB available")
            }

            settingsGroup {
                settingsRow("AirDrop & Handoff", icon: "airplayaudio", color: .blue)
                groupDivider
                settingsRow("Date & Time", icon: "clock.fill", color: .blue)
                groupDivider
                settingsRow("Language & Region", icon: "globe", color: .blue, detail: "English")
            }

            settingsGroup {
                settingsRow("Login Items & Extensions", icon: "person.crop.circle.fill", color: .blue)
                groupDivider
                settingsRow("Sharing", icon: "shareplay", color: .blue)
                groupDivider
                settingsRow("Time Machine", icon: "clock.arrow.circlepath", color: .teal)
            }
        }
    }

    // MARK: - Wi-Fi

    private var wifiPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            panelTitle("Wi-Fi")

            settingsGroup {
                HStack {
                    Text("Wi-Fi").font(.system(size: 11))
                    Spacer()
                    Toggle("", isOn: .constant(true)).labelsHidden().scaleEffect(0.7)
                }
            }

            settingsGroup {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(.blue).frame(width: 14)
                    Image(systemName: "wifi").font(.system(size: 10)).foregroundStyle(.blue)
                    Text("MacFake_WiFi").font(.system(size: 11))
                    Spacer()
                    Text("Connected").font(.system(size: 9)).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Appearance

    private var appearancePanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            panelTitle("Appearance")

            settingsGroup {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Appearance").font(.system(size: 10)).foregroundStyle(.secondary)
                    HStack(spacing: 10) {
                        appearanceOption("Light", selected: true)
                        appearanceOption("Dark", selected: false)
                        appearanceOption("Auto", selected: false)
                    }
                }
            }

            settingsGroup {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Accent Color").font(.system(size: 10)).foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        ForEach([Color.blue, .purple, .pink, .red, .orange, .yellow, .green, .gray], id: \.self) { c in
                            Circle().fill(c).frame(width: 14, height: 14)
                                .overlay(c == .blue ? Image(systemName: "checkmark").font(.system(size: 7, weight: .bold)).foregroundStyle(.white) : nil)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func appearanceOption(_ name: String, selected: Bool) -> some View {
        VStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 4)
                .fill(name == "Dark" ? Color(white: 0.2) : Color(white: 0.98))
                .frame(width: 50, height: 32)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(selected ? .blue : Color(white: 0.8), lineWidth: selected ? 2 : 0.5))
            Text(name).font(.system(size: 9)).foregroundStyle(selected ? .blue : .secondary)
        }
    }

    // MARK: - Dock

    private var dockPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            panelTitle("Desktop & Dock")

            settingsGroup {
                settingsSlider("Size", value: 0.5)
                groupDivider
                settingsToggleRow("Magnification", isOn: true)
                groupDivider
                VStack(alignment: .leading, spacing: 4) {
                    Text("Position on screen").font(.system(size: 10)).foregroundStyle(.secondary)
                    Picker("", selection: .constant("Bottom")) {
                        Text("Left").tag("Left"); Text("Bottom").tag("Bottom"); Text("Right").tag("Right")
                    }.pickerStyle(.segmented).frame(width: 180)
                }
            }

            settingsGroup {
                settingsToggleRow("Automatically hide and show the Dock", isOn: false)
                groupDivider
                settingsToggleRow("Show recent applications in Dock", isOn: true)
            }
        }
    }

    // MARK: - Displays

    private var displaysPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            panelTitle("Displays")

            settingsGroup {
                HStack(spacing: 10) {
                    Image(systemName: "display").font(.system(size: 24)).foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Built-in Liquid Retina XDR").font(.system(size: 11, weight: .medium))
                        Text("3024 × 1964 · ProMotion").font(.system(size: 9)).foregroundStyle(.secondary)
                    }
                }
            }

            settingsGroup {
                settingsSlider("Brightness", value: 0.75)
                groupDivider
                settingsToggleRow("True Tone", isOn: true)
                groupDivider
                settingsToggleRow("Automatically adjust brightness", isOn: true)
            }
        }
    }

    // MARK: - Battery

    private var batteryPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            panelTitle("Battery")

            settingsGroup {
                HStack(spacing: 8) {
                    Image(systemName: "battery.100.bolt").font(.system(size: 20)).foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("100% — Fully Charged").font(.system(size: 11, weight: .medium))
                        Text("Power Adapter").font(.system(size: 9)).foregroundStyle(.secondary)
                    }
                }
            }

            settingsGroup {
                settingsToggleRow("Low Power Mode", isOn: false)
                groupDivider
                settingsToggleRow("Optimized Battery Charging", isOn: true)
            }
        }
    }

    // MARK: - Sound

    private var soundPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            panelTitle("Sound")

            settingsGroup {
                settingsSlider("Output volume", value: 0.6)
                groupDivider
                settingsToggleRow("Play sound on startup", isOn: true)
                groupDivider
                settingsToggleRow("Play user interface sound effects", isOn: true)
            }

            settingsGroup {
                HStack {
                    Text("Alert sound").font(.system(size: 11))
                    Spacer()
                    Text("Breeze").font(.system(size: 10)).foregroundStyle(.secondary)
                    Image(systemName: "chevron.right").font(.system(size: 8)).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Wallpaper

    private var wallpaperPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            panelTitle("Wallpaper")

            // Current wallpaper preview
            settingsGroup {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Wallpaper").font(.system(size: 10)).foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Group {
                            if let img = wallpaperManager.wallpaperImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                LinearGradient(
                                    colors: [Color(red: 0.12, green: 0.22, blue: 0.42), Color(red: 0.85, green: 0.65, blue: 0.45)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            }
                        }
                        .frame(width: 80, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.blue, lineWidth: 2))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(wallpaperManager.wallpaperImage != nil ? "Custom Photo" : "macOS Sequoia")
                                .font(.system(size: 11, weight: .medium))
                            if wallpaperManager.wallpaperImage != nil {
                                Button("Reset to Default") {
                                    wallpaperManager.resetToDefault()
                                }
                                .font(.system(size: 10))
                                .buttonStyle(.plain)
                                .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }

            // Photo library grid
            settingsGroup {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Choose from Photos").font(.system(size: 10)).foregroundStyle(.secondary)

                    if !photosAuthorized {
                        Button("Allow Photo Library Access") {
                            requestPhotoAccess()
                        }
                        .font(.system(size: 11))
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    } else if photoAssets.isEmpty {
                        Text("No photos found")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 56), spacing: 3)], spacing: 3) {
                            ForEach(photoAssets.prefix(30), id: \.localIdentifier) { asset in
                                WallpaperThumbnail(asset: asset) {
                                    wallpaperManager.setWallpaper(from: asset)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear { requestPhotoAccess() }
    }

    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                photosAuthorized = status == .authorized || status == .limited
                if photosAuthorized { loadWallpaperPhotos() }
            }
        }
    }

    private func loadWallpaperPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 30
        let result = PHAsset.fetchAssets(with: .image, options: options)
        var fetched: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in fetched.append(asset) }
        photoAssets = fetched
    }

    // MARK: - Generic

    private func genericPanel(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            panelTitle(title)
            settingsGroup {
                Text("Configure \(title.lowercased()) settings.")
                    .font(.system(size: 11)).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Shared Components

    @ViewBuilder
    private func panelTitle(_ title: String) -> some View {
        Text(title).font(.system(size: 16, weight: .semibold)).padding(.bottom, 2)
    }

    @ViewBuilder
    private func settingsGroup(@ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) { content() }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
    }

    private var groupDivider: some View {
        Divider().padding(.leading, 28).padding(.vertical, 4)
    }

    @ViewBuilder
    private func settingsRow(_ title: String, icon: String, color: Color, detail: String? = nil) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(RoundedRectangle(cornerRadius: 5).fill(color.gradient))

            Text(title).font(.system(size: 11))
            Spacer()
            if let detail {
                Text(detail).font(.system(size: 10)).foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right").font(.system(size: 8, weight: .semibold)).foregroundStyle(Color(white: 0.75))
        }
    }

    @ViewBuilder
    private func settingsToggleRow(_ title: String, isOn: Bool) -> some View {
        HStack {
            Text(title).font(.system(size: 11))
            Spacer()
            Toggle("", isOn: .constant(isOn)).labelsHidden().scaleEffect(0.7)
        }
    }

    @ViewBuilder
    private func settingsSlider(_ title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.system(size: 10)).foregroundStyle(.secondary)
            Slider(value: .constant(value))
        }
    }
}

// MARK: - Wallpaper Thumbnail

struct WallpaperThumbnail: View {
    let asset: PHAsset
    let onSelect: () -> Void
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle().fill(Color(white: 0.9))
            }
        }
        .frame(width: 56, height: 38)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(white: 0.85), lineWidth: 0.5))
        .onTapGesture { onSelect() }
        .onAppear {
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 120, height: 80),
                contentMode: .aspectFill,
                options: nil
            ) { img, _ in image = img }
        }
    }
}
