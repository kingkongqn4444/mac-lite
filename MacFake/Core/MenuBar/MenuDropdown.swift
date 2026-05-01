import SwiftUI

struct MenuDropdown: View {
    let menuName: String
    let onAction: (MenuAction) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                if item.isSeparator {
                    Divider()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                } else {
                    MenuDropdownItem(item: item) {
                        if let action = item.action {
                            onAction(action)
                        }
                        onDismiss()
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .frame(minWidth: 200)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(white: 0.97).opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(white: 0.8), lineWidth: 0.5)
        )
    }

    private var items: [DropdownMenuItem] {
        menuItemsFor(menuName)
    }
}

// MARK: - Menu Action

enum MenuAction {
    case openApp(FakeApp)
    case closeWindow
    case minimizeWindow
    case zoomWindow
    case bringAllToFront
    case none
}

// MARK: - Menu Item Model

struct DropdownMenuItem: Identifiable {
    let id = UUID()
    let label: String
    let shortcut: String?
    let isSeparator: Bool
    let isDisabled: Bool
    let action: MenuAction?

    init(_ label: String, shortcut: String? = nil, disabled: Bool = false, action: MenuAction? = .none) {
        self.label = label
        self.shortcut = shortcut
        self.isSeparator = false
        self.isDisabled = disabled
        self.action = action
    }

    static var separator: DropdownMenuItem {
        DropdownMenuItem(label: "---", shortcut: nil, isSeparator: true, isDisabled: true, action: nil)
    }

    private init(label: String, shortcut: String?, isSeparator: Bool, isDisabled: Bool, action: MenuAction?) {
        self.label = label
        self.shortcut = shortcut
        self.isSeparator = isSeparator
        self.isDisabled = isDisabled
        self.action = action
    }
}

// MARK: - Menu Item View

struct MenuDropdownItem: View {
    let item: DropdownMenuItem
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                Text(item.label)
                    .font(MacFonts.dropdownItem)

                Spacer(minLength: 24)

                if let shortcut = item.shortcut, !shortcut.isEmpty {
                    Text(shortcut)
                        .font(MacFonts.dropdownShortcut)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(MenuItemButtonStyle(isDisabled: item.isDisabled))
        .disabled(item.isDisabled)
    }
}

struct MenuItemButtonStyle: ButtonStyle {
    let isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(configuration.isPressed ? Color.accentColor : .clear)
                    .padding(.horizontal, 4)
            )
            .foregroundStyle(
                isDisabled ? Color(white: 0.7) :
                (configuration.isPressed ? .white : Color(white: 0.15))
            )
    }
}

// MARK: - Menu Data

private func menuItemsFor(_ menu: String) -> [DropdownMenuItem] {
    switch menu {
    case "__apple":
        return [
            DropdownMenuItem("About This Mac", action: .openApp(.aboutMac)),
            .separator,
            DropdownMenuItem("System Settings...", action: .openApp(.settings)),
            DropdownMenuItem("App Store...", disabled: true),
            .separator,
            DropdownMenuItem("Recent Items", disabled: true),
            .separator,
            DropdownMenuItem("Force Quit...", shortcut: "⌥⌘Q", disabled: true),
            .separator,
            DropdownMenuItem("Sleep", disabled: true),
            DropdownMenuItem("Restart...", disabled: true),
            DropdownMenuItem("Shut Down...", disabled: true),
        ]
    case "File":
        return [
            DropdownMenuItem("New Finder Window", shortcut: "⌘N", action: .openApp(.finder)),
            DropdownMenuItem("New Terminal Window", action: .openApp(.terminal)),
            .separator,
            DropdownMenuItem("Close Window", shortcut: "⌘W", action: .closeWindow),
            .separator,
            DropdownMenuItem("Get Info", shortcut: "⌘I", disabled: true),
        ]
    case "Edit":
        return [
            DropdownMenuItem("Undo", shortcut: "⌘Z", disabled: true),
            DropdownMenuItem("Redo", shortcut: "⇧⌘Z", disabled: true),
            .separator,
            DropdownMenuItem("Cut", shortcut: "⌘X", disabled: true),
            DropdownMenuItem("Copy", shortcut: "⌘C", disabled: true),
            DropdownMenuItem("Paste", shortcut: "⌘V", disabled: true),
            DropdownMenuItem("Select All", shortcut: "⌘A", disabled: true),
        ]
    case "View":
        return [
            DropdownMenuItem("as Icons", shortcut: "⌘1", disabled: true),
            DropdownMenuItem("as List", shortcut: "⌘2", disabled: true),
            DropdownMenuItem("as Columns", shortcut: "⌘3", disabled: true),
            .separator,
            DropdownMenuItem("Show Sidebar", shortcut: "⌥⌘S", disabled: true),
            DropdownMenuItem("Show Path Bar", shortcut: "⌥⌘P", disabled: true),
        ]
    case "Go":
        return [
            DropdownMenuItem("Back", shortcut: "⌘[", disabled: true),
            DropdownMenuItem("Forward", shortcut: "⌘]", disabled: true),
            .separator,
            DropdownMenuItem("Desktop", shortcut: "⇧⌘D", action: .openApp(.finder)),
            DropdownMenuItem("Documents", shortcut: "⇧⌘O", action: .openApp(.finder)),
            DropdownMenuItem("Downloads", shortcut: "⌥⌘L", action: .openApp(.finder)),
            DropdownMenuItem("Home", shortcut: "⇧⌘H", action: .openApp(.finder)),
            .separator,
            DropdownMenuItem("Applications", shortcut: "⇧⌘A", action: .openApp(.finder)),
            DropdownMenuItem("Utilities", shortcut: "⇧⌘U", disabled: true),
        ]
    case "Window":
        return [
            DropdownMenuItem("Minimize", shortcut: "⌘M", action: .minimizeWindow),
            DropdownMenuItem("Zoom", action: .zoomWindow),
            .separator,
            DropdownMenuItem("Bring All to Front", action: .bringAllToFront),
        ]
    case "Help":
        return [
            DropdownMenuItem("macOS Help", disabled: true),
            DropdownMenuItem("About MacFake", action: .openApp(.aboutMac)),
        ]
    case "History":
        return [
            DropdownMenuItem("Show All History", shortcut: "⌘Y", disabled: true),
            .separator,
            DropdownMenuItem("apple.com", disabled: true),
        ]
    case "Bookmarks":
        return [
            DropdownMenuItem("Show Bookmarks", shortcut: "⌥⌘B", disabled: true),
            DropdownMenuItem("Edit Bookmarks", disabled: true),
            .separator,
            DropdownMenuItem("Favorites", disabled: true),
        ]
    case "Shell":
        return [
            DropdownMenuItem("New Window", shortcut: "⌘N", action: .openApp(.terminal)),
            DropdownMenuItem("New Tab", shortcut: "⌘T", disabled: true),
            .separator,
            DropdownMenuItem("Close Window", shortcut: "⌘W", action: .closeWindow),
        ]
    case "Format":
        return [
            DropdownMenuItem("Bold", shortcut: "⌘B", disabled: true),
            DropdownMenuItem("Italic", shortcut: "⌘I", disabled: true),
            DropdownMenuItem("Underline", shortcut: "⌘U", disabled: true),
            .separator,
            DropdownMenuItem("Bigger", shortcut: "⌘+", disabled: true),
            DropdownMenuItem("Smaller", shortcut: "⌘-", disabled: true),
        ]
    case "Profiles":
        return [
            DropdownMenuItem("Default", disabled: true),
            DropdownMenuItem("Homebrew", disabled: true),
            DropdownMenuItem("Pro", disabled: true),
        ]
    case "Convert":
        return [
            DropdownMenuItem("Decimal to Binary", disabled: true),
            DropdownMenuItem("Binary to Decimal", disabled: true),
        ]
    case "System Settings":
        return [
            DropdownMenuItem("About System Settings", action: .openApp(.aboutMac)),
        ]
    default:
        return [
            DropdownMenuItem("(No items)", disabled: true),
        ]
    }
}
