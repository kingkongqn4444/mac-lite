import SwiftUI

struct WindowsLayerView: View {
    @Environment(WindowManager.self) private var windowManager
    let screenSize: CGSize

    var body: some View {
        ZStack {
            ForEach(windowManager.visibleWindows) { window in
                ResizableWindow(window: window, screenSize: screenSize) {
                    AppContentView(window: window)
                }
                .id(window.id)
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: windowManager.visibleWindows.count)
    }
}

/// Routes window.app to the correct app view
struct AppContentView: View {
    let window: WindowState

    var body: some View {
        switch window.app {
        case .aboutMac: AboutMacView(windowState: window)
        case .calculator: CalculatorView(windowState: window)
        case .notes: NotesView(windowState: window)
        case .finder: FinderView(windowState: window)
        case .textEdit: TextEditView(windowState: window)
        case .terminal: TerminalView(windowState: window)
        case .safari: SafariView(windowState: window)
        case .settings: SettingsView(windowState: window)
        case .photos: PhotosView(windowState: window)
        case .music: MusicView(windowState: window)
        case .maps: MapsView(windowState: window)
        case .calendar: CalendarAppView(windowState: window)
        case .camera: CameraView(windowState: window)
        case .contacts: ContactsView(windowState: window)
        case .clock: ClockView(windowState: window)
        case .messages: MessagesView(windowState: window)
        case .mail: MailView(windowState: window)
        case .reminders: RemindersView(windowState: window)
        case .xcode: XcodeAppView(windowState: window)
        case .vscode: VSCodeAppView(windowState: window)
        case .androidStudio: AndroidStudioAppView(windowState: window)
        default: PlaceholderView(app: window.app)
        }
    }
}
