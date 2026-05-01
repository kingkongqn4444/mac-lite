import SwiftUI

struct DockIconView: View {
    let app: FakeApp?
    var iconName: String?
    var label: String?
    let isRunning: Bool
    let scale: CGFloat
    let onTap: () -> Void

    @State private var isBouncing = false

    private let baseSize: CGFloat = 30

    var body: some View {
        ZStack(alignment: .bottom) {
            macOSIcon
                .scaleEffect(scale)
                .offset(y: isBouncing ? -4 : 0)
                .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.6), value: scale)

            // Running indicator dot below icon
            Circle()
                .fill(Color.white.opacity(isRunning ? 0.9 : 0))
                .frame(width: 3, height: 3)
                .offset(y: 4)
        }
        .frame(width: baseSize + 6, height: baseSize + 10)
        .contentShape(Rectangle())
        .contextMenu {
            if let app = app {
                Text(app.displayName).font(.headline)
                Divider()
                Button {
                    onTap()
                } label: {
                    Label("New Window", systemImage: "plus.rectangle")
                }
                Button {
                    // no-op
                } label: {
                    Label("Options", systemImage: "ellipsis")
                }
                Divider()
                Button {
                    onTap()
                } label: {
                    Label(isRunning ? "Show All Windows" : "Open", systemImage: isRunning ? "rectangle.stack" : "arrow.up.forward.app")
                }
                if isRunning {
                    Button(role: .destructive) {
                        // no-op — can't force quit in fake
                    } label: {
                        Label("Quit", systemImage: "xmark")
                    }
                }
                Divider()
                Button {
                    // no-op
                } label: {
                    Label("Show in Finder", systemImage: "folder")
                }
            } else {
                // Trash
                Text("Trash")
                Divider()
                Button {
                    // no-op
                } label: {
                    Label("Empty Trash", systemImage: "trash.slash")
                }
                Button {
                    // no-op
                } label: {
                    Label("Open", systemImage: "arrow.up.forward.app")
                }
            }
        }
        .highPriorityGesture(
            TapGesture().onEnded { bounceAndOpen() }
        )
    }

    // MARK: - macOS Style Icon

    @ViewBuilder
    private var macOSIcon: some View {
        if let app = app {
            appIcon(for: app)
        } else if let assetLabel = label,
                  let path = Bundle.main.path(forResource: assetLabel, ofType: "png", inDirectory: "Assets"),
                  let uiImage = UIImage(contentsOfFile: path) {
            // Dock item with asset icon (e.g. Launchpad)
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: baseSize, height: baseSize)
                .clipShape(RoundedRectangle(cornerRadius: baseSize * 0.22))
                .overlay(
                    RoundedRectangle(cornerRadius: baseSize * 0.22)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        } else {
            // Trash or other SF Symbol icon
            ZStack {
                squircleBackground(colors: [Color(white: 0.25), Color(white: 0.15)])
                Image(systemName: iconName ?? "trash.fill")
                    .font(.system(size: baseSize * 0.4))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    @ViewBuilder
    private func appIcon(for app: FakeApp) -> some View {
        // Use asset image if available
        if let assetName = app.iconAssetName,
           let path = Bundle.main.path(forResource: assetName, ofType: "png", inDirectory: "Assets"),
           let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: baseSize, height: baseSize)
                .clipShape(RoundedRectangle(cornerRadius: baseSize * 0.22))
                .overlay(
                    RoundedRectangle(cornerRadius: baseSize * 0.22)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        } else {
        // Fallback to SF Symbol icons
        switch app {
        case .finder:
            // Finder: blue face icon
            ZStack {
                squircleBackground(colors: [
                    Color(red: 0.3, green: 0.6, blue: 1.0),
                    Color(red: 0.1, green: 0.3, blue: 0.8)
                ])
                // Finder face
                VStack(spacing: 2) {
                    HStack(spacing: 6) {
                        Circle().fill(.white).frame(width: 5, height: 5) // left eye
                        Circle().fill(.white).frame(width: 5, height: 5) // right eye
                    }
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white)
                        .frame(width: 14, height: 3) // mouth
                }
                .offset(y: 2)
            }

        case .safari:
            // Safari: compass
            ZStack {
                squircleBackground(colors: [
                    Color(red: 0.3, green: 0.7, blue: 1.0),
                    Color(red: 0.2, green: 0.5, blue: 0.95)
                ])
                Image(systemName: "safari.fill")
                    .font(.system(size: baseSize * 0.5))
                    .foregroundStyle(.white)
            }

        case .calculator:
            // Calculator: dark with colored buttons
            ZStack {
                squircleBackground(colors: [Color(white: 0.2), Color(white: 0.1)])
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(white: 0.4))
                        .frame(width: 20, height: 6)
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color(white: 0.35))
                                .frame(width: 5, height: 4)
                        }
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.orange)
                            .frame(width: 5, height: 4)
                    }
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color(white: 0.35))
                                .frame(width: 5, height: 4)
                        }
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.orange)
                            .frame(width: 5, height: 4)
                    }
                }
            }

        case .notes:
            // Notes: yellow header with lines
            ZStack {
                squircleBackground(colors: [Color(white: 0.95), Color(white: 0.85)])
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(height: 10)
                    VStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { _ in
                            Rectangle()
                                .fill(Color(white: 0.7))
                                .frame(height: 1)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: baseSize * 0.22))
            }

        case .terminal:
            // Terminal: dark with prompt
            ZStack {
                squircleBackground(colors: [Color(white: 0.15), Color(white: 0.05)])
                VStack(alignment: .leading, spacing: 2) {
                    Text(">_")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                }
            }

        case .settings:
            // Settings: gray gear
            ZStack {
                squircleBackground(colors: [Color(white: 0.55), Color(white: 0.4)])
                Image(systemName: "gearshape.fill")
                    .font(.system(size: baseSize * 0.5))
                    .foregroundStyle(.white)
            }

        case .textEdit:
            // TextEdit: pen on paper
            ZStack {
                squircleBackground(colors: [Color(white: 0.95), Color(white: 0.85)])
                Image(systemName: "pencil.line")
                    .font(.system(size: baseSize * 0.4))
                    .foregroundStyle(.blue)
            }

        case .aboutMac:
            ZStack {
                squircleBackground(colors: [Color(white: 0.2), Color(white: 0.1)])
                Image(systemName: "apple.logo")
                    .font(.system(size: baseSize * 0.45))
                    .foregroundStyle(.white)
            }

        case .photos:
            ZStack {
                squircleBackground(colors: [Color.white, Color(white: 0.9)])
                Image(systemName: "photo.fill")
                    .font(.system(size: baseSize * 0.4))
                    .foregroundStyle(
                        LinearGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }

        case .music:
            ZStack {
                squircleBackground(colors: [Color(red: 1, green: 0.2, blue: 0.3), Color(red: 0.8, green: 0.1, blue: 0.2)])
                Image(systemName: "music.note")
                    .font(.system(size: baseSize * 0.45))
                    .foregroundStyle(.white)
            }

        case .maps:
            ZStack {
                squircleBackground(colors: [Color(red: 0.3, green: 0.8, blue: 0.4), Color(red: 0.2, green: 0.6, blue: 0.3)])
                Image(systemName: "map.fill")
                    .font(.system(size: baseSize * 0.4))
                    .foregroundStyle(.white)
            }

        case .calendar:
            ZStack {
                squircleBackground(colors: [.white, Color(white: 0.92)])
                VStack(spacing: 0) {
                    Rectangle().fill(.red).frame(height: 10)
                    Text("\(Calendar.current.component(.day, from: Date()))")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(.black)
                }
                .clipShape(RoundedRectangle(cornerRadius: baseSize * 0.22))
            }

        case .camera:
            ZStack {
                squircleBackground(colors: [Color(red: 0.3, green: 0.8, blue: 0.3), Color(red: 0.2, green: 0.6, blue: 0.2)])
                Image(systemName: "video.fill")
                    .font(.system(size: baseSize * 0.4))
                    .foregroundStyle(.white)
            }

        case .contacts:
            ZStack {
                squircleBackground(colors: [Color(white: 0.65), Color(white: 0.45)])
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: baseSize * 0.45))
                    .foregroundStyle(.white)
            }

        case .clock:
            ZStack {
                squircleBackground(colors: [Color(white: 0.1), Color.black])
                Image(systemName: "clock.fill")
                    .font(.system(size: baseSize * 0.45))
                    .foregroundStyle(.white)
            }

        case .xcode:
            ZStack {
                squircleBackground(colors: [
                    Color(red: 0.2, green: 0.5, blue: 1.0),
                    Color(red: 0.1, green: 0.3, blue: 0.9)
                ])
                Image(systemName: "hammer.fill")
                    .font(.system(size: baseSize * 0.4))
                    .foregroundStyle(.white)
            }

        case .vscode:
            ZStack {
                squircleBackground(colors: [
                    Color(red: 0.0, green: 0.47, blue: 0.84),
                    Color(red: 0.0, green: 0.35, blue: 0.72)
                ])
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: baseSize * 0.35, weight: .bold))
                    .foregroundStyle(.white)
            }

        case .androidStudio:
            ZStack {
                squircleBackground(colors: [
                    Color(red: 0.2, green: 0.7, blue: 0.3),
                    Color(red: 0.1, green: 0.5, blue: 0.2)
                ])
                Image(systemName: "ant.fill")
                    .font(.system(size: baseSize * 0.4))
                    .foregroundStyle(.white)
            }

        // Generic icon for all extra apps
        default:
            ZStack {
                squircleBackground(colors: gradientColors(for: app))
                Image(systemName: app.iconName)
                    .font(.system(size: baseSize * 0.4))
                    .foregroundStyle(.white)
            }
        }
        } // end else (SF Symbol fallback)
    }

    /// Gradient colors per extra app
    private func gradientColors(for app: FakeApp) -> [Color] {
        switch app {
        case .messages: [Color(red: 0.25, green: 0.85, blue: 0.35), Color(red: 0.15, green: 0.65, blue: 0.25)]
        case .mail: [Color(red: 0.2, green: 0.5, blue: 1.0), Color(red: 0.1, green: 0.3, blue: 0.85)]
        case .appStore: [Color(red: 0.15, green: 0.55, blue: 1.0), Color(red: 0.1, green: 0.35, blue: 0.9)]
        case .reminders: [Color(white: 0.95), Color(white: 0.85)]
        case .preview: [Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.15, green: 0.4, blue: 0.9)]
        case .keynote: [Color(red: 0.0, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.3, blue: 0.8)]
        case .pages: [Color(red: 1.0, green: 0.55, blue: 0.0), Color(red: 0.9, green: 0.4, blue: 0.0)]
        case .slack: [Color(red: 0.45, green: 0.15, blue: 0.55), Color(red: 0.35, green: 0.05, blue: 0.45)]
        case .discord: [Color(red: 0.34, green: 0.40, blue: 0.95), Color(red: 0.25, green: 0.30, blue: 0.85)]
        case .telegram: [Color(red: 0.16, green: 0.63, blue: 0.87), Color(red: 0.10, green: 0.50, blue: 0.75)]
        case .chrome: [Color(red: 0.95, green: 0.26, blue: 0.21), Color(red: 0.85, green: 0.18, blue: 0.15)]
        case .firefox: [Color(red: 1.0, green: 0.45, blue: 0.0), Color(red: 0.9, green: 0.30, blue: 0.0)]
        case .github: [Color(white: 0.2), Color(white: 0.1)]
        case .docker: [Color(red: 0.1, green: 0.55, blue: 0.85), Color(red: 0.05, green: 0.40, blue: 0.70)]
        case .figma: [Color(red: 0.63, green: 0.31, blue: 1.0), Color(red: 0.50, green: 0.20, blue: 0.90)]
        case .postman: [Color(red: 1.0, green: 0.42, blue: 0.16), Color(red: 0.9, green: 0.30, blue: 0.10)]
        default: [app.iconColor, app.iconColor.opacity(0.7)]
        }
    }

    // MARK: - Squircle Background

    private func squircleBackground(colors: [Color]) -> some View {
        RoundedRectangle(cornerRadius: baseSize * 0.22)
            .fill(
                LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
            )
            .frame(width: baseSize, height: baseSize)
            .overlay(
                RoundedRectangle(cornerRadius: baseSize * 0.22)
                    .stroke(.white.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
    }

    // MARK: - Bounce

    private func bounceAndOpen() {
        guard !isBouncing else { return }
        onTap()
        isBouncing = true
        withAnimation(.easeInOut(duration: 0.12)) { isBouncing = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeInOut(duration: 0.12)) { isBouncing = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.easeInOut(duration: 0.1)) { isBouncing = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) { isBouncing = false }
                }
            }
        }
    }
}
