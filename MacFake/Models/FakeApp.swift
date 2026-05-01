import SwiftUI

enum FakeApp: String, CaseIterable, Identifiable {
    case finder
    case safari
    case calculator
    case notes
    case textEdit
    case terminal
    case settings
    case aboutMac
    // New real apps
    case photos
    case music
    case maps
    case calendar
    case camera
    case contacts
    case clock
    // IDE apps
    case xcode
    case vscode
    case androidStudio
    // Extra Dock apps (placeholder UI)
    case messages
    case mail
    case appStore
    case reminders
    case preview
    case keynote
    case pages
    case slack
    case discord
    case telegram
    case chrome
    case firefox
    case github
    case docker
    case figma
    case postman

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .finder: "Finder"
        case .safari: "Safari"
        case .calculator: "Calculator"
        case .notes: "Notes"
        case .textEdit: "TextEdit"
        case .terminal: "Terminal"
        case .settings: "System Settings"
        case .aboutMac: "About This Mac"
        case .photos: "Photos"
        case .music: "Music"
        case .maps: "Maps"
        case .calendar: "Calendar"
        case .camera: "FaceTime"
        case .contacts: "Contacts"
        case .clock: "Clock"
        case .xcode: "Xcode"
        case .vscode: "Visual Studio Code"
        case .androidStudio: "Android Studio"
        case .messages: "Messages"
        case .mail: "Mail"
        case .appStore: "App Store"
        case .reminders: "Reminders"
        case .preview: "Preview"
        case .keynote: "Keynote"
        case .pages: "Pages"
        case .slack: "Slack"
        case .discord: "Discord"
        case .telegram: "Telegram"
        case .chrome: "Google Chrome"
        case .firefox: "Firefox"
        case .github: "GitHub Desktop"
        case .docker: "Docker"
        case .figma: "Figma"
        case .postman: "Postman"
        }
    }

    var iconName: String {
        switch self {
        case .finder: "folder.fill"
        case .safari: "safari.fill"
        case .calculator: "plus.forwardslash.minus"
        case .notes: "note.text"
        case .textEdit: "doc.richtext.fill"
        case .terminal: "terminal.fill"
        case .settings: "gearshape.fill"
        case .aboutMac: "apple.logo"
        case .photos: "photo.fill"
        case .music: "music.note"
        case .maps: "map.fill"
        case .calendar: "calendar"
        case .camera: "video.fill"
        case .contacts: "person.crop.circle.fill"
        case .clock: "clock.fill"
        case .xcode: "hammer.fill"
        case .vscode: "chevron.left.forwardslash.chevron.right"
        case .androidStudio: "ant.fill"
        case .messages: "message.fill"
        case .mail: "envelope.fill"
        case .appStore: "bag.fill"
        case .reminders: "checklist"
        case .preview: "eye.fill"
        case .keynote: "play.rectangle.fill"
        case .pages: "doc.text.fill"
        case .slack: "number"
        case .discord: "headphones"
        case .telegram: "paperplane.fill"
        case .chrome: "globe"
        case .firefox: "flame.fill"
        case .github: "cat.fill"
        case .docker: "shippingbox.fill"
        case .figma: "pencil.and.ruler.fill"
        case .postman: "arrow.up.arrow.down"
        }
    }

    var iconColor: Color {
        switch self {
        case .finder: .blue
        case .safari: .cyan
        case .calculator: .gray
        case .notes: .yellow
        case .textEdit: .blue
        case .terminal: .black
        case .settings: .gray
        case .aboutMac: .primary
        case .photos: Color(red: 1, green: 0.4, blue: 0.3)
        case .music: .red
        case .maps: .green
        case .calendar: .red
        case .camera: .green
        case .contacts: Color(red: 0.4, green: 0.4, blue: 0.4)
        case .clock: .black
        case .xcode: .blue
        case .vscode: .blue
        case .androidStudio: Color(red: 0.2, green: 0.7, blue: 0.3)
        case .messages: .green
        case .mail: .blue
        case .appStore: .blue
        case .reminders: Color(red: 0.2, green: 0.5, blue: 1.0)
        case .preview: .blue
        case .keynote: .blue
        case .pages: .orange
        case .slack: Color(red: 0.4, green: 0.1, blue: 0.5)
        case .discord: Color(red: 0.34, green: 0.40, blue: 0.95)
        case .telegram: Color(red: 0.16, green: 0.63, blue: 0.87)
        case .chrome: Color(red: 0.95, green: 0.26, blue: 0.21)
        case .firefox: .orange
        case .github: .purple
        case .docker: .blue
        case .figma: Color(red: 0.63, green: 0.31, blue: 1.0)
        case .postman: .orange
        }
    }

    var defaultWindowSize: CGSize {
        switch self {
        case .finder: CGSize(width: 500, height: 300)
        case .safari: CGSize(width: 550, height: 340)
        case .calculator: CGSize(width: 180, height: 260)
        case .notes: CGSize(width: 450, height: 280)
        case .textEdit: CGSize(width: 420, height: 280)
        case .terminal: CGSize(width: 460, height: 260)
        case .settings: CGSize(width: 520, height: 320)
        case .aboutMac: CGSize(width: 280, height: 200)
        case .photos: CGSize(width: 520, height: 320)
        case .music: CGSize(width: 500, height: 300)
        case .maps: CGSize(width: 520, height: 320)
        case .calendar: CGSize(width: 480, height: 300)
        case .camera: CGSize(width: 400, height: 280)
        case .contacts: CGSize(width: 400, height: 280)
        case .clock: CGSize(width: 300, height: 240)
        case .xcode: CGSize(width: 580, height: 340)
        case .vscode: CGSize(width: 560, height: 340)
        case .androidStudio: CGSize(width: 580, height: 340)
        default: CGSize(width: 450, height: 280)
        }
    }

    var menuItems: [String] {
        switch self {
        case .finder: ["File", "Edit", "View", "Go", "Window", "Help"]
        case .safari: ["File", "Edit", "View", "History", "Bookmarks", "Window", "Help"]
        case .calculator: ["File", "Edit", "View", "Convert", "Window", "Help"]
        case .notes: ["File", "Edit", "Format", "View", "Window", "Help"]
        case .textEdit: ["File", "Edit", "Format", "View", "Window", "Help"]
        case .terminal: ["Shell", "Edit", "View", "Profiles", "Window", "Help"]
        case .settings: ["System Settings", "Edit", "View", "Window", "Help"]
        case .aboutMac: ["File", "Edit", "View", "Window", "Help"]
        case .photos: ["Photos", "File", "Edit", "Image", "View", "Window", "Help"]
        case .music: ["Music", "File", "Edit", "View", "Controls", "Window", "Help"]
        case .maps: ["Maps", "File", "Edit", "View", "Window", "Help"]
        case .calendar: ["Calendar", "File", "Edit", "View", "Window", "Help"]
        case .camera: ["FaceTime", "File", "Edit", "View", "Window", "Help"]
        case .contacts: ["Contacts", "File", "Edit", "View", "Window", "Help"]
        case .clock: ["Clock", "File", "Edit", "View", "Window", "Help"]
        case .xcode: ["Xcode", "File", "Edit", "View", "Navigate", "Editor", "Product", "Debug", "Window", "Help"]
        case .vscode: ["Code", "File", "Edit", "Selection", "View", "Go", "Run", "Terminal", "Help"]
        case .androidStudio: ["Android Studio", "File", "Edit", "View", "Navigate", "Code", "Build", "Run", "Help"]
        default: [displayName, "File", "Edit", "View", "Window", "Help"]
        }
    }

    static var dockApps: [FakeApp] {
        [.finder, .safari, .messages, .mail, .maps, .photos, .music, .notes, .calendar, .reminders, .settings, .terminal]
    }

    var isDesktopIcon: Bool { self == .finder }

    var resizable: Bool {
        self != .aboutMac && self != .calculator
    }

    var minWindowSize: CGSize {
        switch self {
        case .calculator, .aboutMac: defaultWindowSize
        default: CGSize(width: 250, height: 180)
        }
    }

    /// Asset filename for app icon (from Assets/ folder)
    var iconAssetName: String? {
        switch self {
        case .finder: "Finder"
        case .safari: "Safari"
        case .calculator: "Calculator"
        case .notes: "Notes"
        case .textEdit: "TextEdit"
        case .terminal: "Terminal"
        case .settings: "Settings"
        case .aboutMac: nil
        case .photos: "Photos"
        case .music: "Music"
        case .maps: "Maps"
        case .calendar: "Calendar"
        case .camera: "FaceTime"
        case .contacts: "Contacts"
        case .clock: "Clock"
        case .xcode: "Xcode"
        case .vscode: nil // No asset for VS Code
        case .androidStudio: nil // No asset for Android Studio
        case .messages: "Messages"
        case .mail: "Mail"
        case .appStore: "App Store"
        case .reminders: "Reminders"
        case .preview: "Preview"
        case .keynote: "Keynote"
        case .pages: "Pages"
        case .slack: nil
        case .discord: nil
        case .telegram: nil
        case .chrome: nil
        case .firefox: nil
        case .github: nil
        case .docker: nil
        case .figma: "Figma"
        case .postman: nil
        }
    }
}
