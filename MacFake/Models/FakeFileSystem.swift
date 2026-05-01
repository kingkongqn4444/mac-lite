import SwiftUI
import Foundation

@Observable
final class FakeFileSystem {
    static let shared = FakeFileSystem()

    let root: FakeNode

    init() {
        // Build tree from real iPhone filesystem + simulated macOS structure
        let fm = FileManager.default
        let homeDir = NSHomeDirectory()

        root = FakeNode.folder("Macintosh HD", children: [
            .folder("Applications", children: Self.applicationsFolder()),
            .folder("Users", children: [
                .folder("admin", children: [
                    Self.buildRealFolder(path: homeDir + "/Documents", name: "Documents"),
                    Self.buildRealFolder(path: homeDir + "/Library", name: "Library"),
                    Self.buildRealFolder(path: homeDir + "/tmp", name: "Downloads"),
                    .folder("Desktop", children: [
                        .file("readme.txt", icon: "doc.text", size: 1024),
                    ]),
                    .folder("Pictures", children: [
                        .file("Use Photos app to view images", icon: "photo", size: 0),
                    ]),
                    .folder("Music", children: [
                        .file("Use Music app to play songs", icon: "music.note", size: 0),
                    ]),
                ]),
            ]),
            .folder("System", children: [
                Self.buildRealFolder(path: "/System/Library/Fonts", name: "Fonts"),
                .folder("Library", children: [
                    .file("SystemVersion.plist", icon: "doc.text", size: 800),
                ]),
            ]),
            Self.buildDeviceInfoFolder(),
        ])
    }

    // MARK: - Build real directory tree from filesystem

    private static func buildRealFolder(path: String, name: String) -> FakeNode {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(atPath: path) else {
            return .folder(name, children: [])
        }

        let children: [FakeNode] = contents
            .filter { !$0.hasPrefix(".") } // Hide hidden files
            .prefix(50) // Limit to prevent performance issues
            .compactMap { itemName in
                let fullPath = (path as NSString).appendingPathComponent(itemName)
                var isDir: ObjCBool = false
                fm.fileExists(atPath: fullPath, isDirectory: &isDir)

                if isDir.boolValue {
                    // Only go 1 level deep for performance
                    let subCount = (try? fm.contentsOfDirectory(atPath: fullPath).count) ?? 0
                    return FakeNode.folder(itemName, children: subCount > 0 ?
                        [.file("\(subCount) items", icon: "doc", size: 0)] : [])
                } else {
                    let attrs = try? fm.attributesOfItem(atPath: fullPath)
                    let size = attrs?[.size] as? Int ?? 0
                    let modified = attrs?[.modificationDate] as? Date ?? Date()
                    let icon = iconForFile(itemName)
                    return FakeNode(name: itemName, isFolder: false, icon: icon,
                                   children: nil, fileSize: size, modifiedDate: modified)
                }
            }
            .sorted { $0.isFolder && !$1.isFolder } // Folders first

        return .folder(name, children: children)
    }

    // MARK: - Applications folder (fake macOS apps)

    private static func applicationsFolder() -> [FakeNode] {
        FakeApp.allCases
            .filter { $0 != .aboutMac }
            .map { .app($0) }
            .sorted { $0.name < $1.name }
    }

    // MARK: - Device info folder

    private static func buildDeviceInfoFolder() -> FakeNode {
        let device = UIDevice.current
        return .folder("Device Info", children: [
            .file("Model: \(device.model)", icon: "iphone", size: 0),
            .file("Name: \(device.name)", icon: "person.fill", size: 0),
            .file("iOS \(device.systemVersion)", icon: "info.circle", size: 0),
            .file("Storage: \(diskSpace())", icon: "internaldrive.fill", size: 0),
        ])
    }

    private static func diskSpace() -> String {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let total = attrs[.systemSize] as? Int64,
              let free = attrs[.systemFreeSize] as? Int64 else { return "Unknown" }
        let totalGB = Double(total) / 1_073_741_824
        let freeGB = Double(free) / 1_073_741_824
        return String(format: "%.0f GB total, %.0f GB free", totalGB, freeGB)
    }

    // MARK: - File icon mapping

    private static func iconForFile(_ name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "txt", "md", "log": return "doc.text"
        case "pdf": return "doc.fill"
        case "jpg", "jpeg", "png", "heic", "gif", "webp": return "photo"
        case "mp4", "mov", "m4v": return "video"
        case "mp3", "m4a", "aac", "wav": return "music.note"
        case "zip", "gz", "tar": return "doc.zipper"
        case "json", "xml", "plist": return "doc.text"
        case "swift", "h", "m", "c", "py", "js": return "chevron.left.forwardslash.chevron.right"
        case "app": return "app.fill"
        case "framework", "dylib": return "shippingbox"
        case "ttf", "otf": return "textformat"
        case "db", "sqlite": return "cylinder"
        default: return "doc"
        }
    }
}

struct FakeNode: Identifiable {
    let id = UUID()
    let name: String
    let isFolder: Bool
    let icon: String
    var children: [FakeNode]?
    let fileSize: Int?
    let modifiedDate: Date
    let fakeApp: FakeApp? // If this node represents a launchable app

    init(name: String, isFolder: Bool, icon: String, children: [FakeNode]? = nil,
         fileSize: Int? = nil, modifiedDate: Date = Date(), fakeApp: FakeApp? = nil) {
        self.name = name
        self.isFolder = isFolder
        self.icon = icon
        self.children = children
        self.fileSize = fileSize
        self.modifiedDate = modifiedDate
        self.fakeApp = fakeApp
    }

    static func folder(_ name: String, children: [FakeNode]) -> FakeNode {
        FakeNode(name: name, isFolder: true, icon: "folder.fill", children: children)
    }

    static func file(_ name: String, icon: String, size: Int) -> FakeNode {
        FakeNode(name: name, isFolder: false, icon: icon, fileSize: size,
                 modifiedDate: Date().addingTimeInterval(-Double.random(in: 0...86400 * 30)))
    }

    /// Create a launchable app node
    static func app(_ fakeApp: FakeApp) -> FakeNode {
        FakeNode(name: "\(fakeApp.displayName).app", isFolder: false, icon: "app.fill",
                 fileSize: Int.random(in: 2_000_000...50_000_000),
                 modifiedDate: Date().addingTimeInterval(-Double.random(in: 0...86400 * 60)),
                 fakeApp: fakeApp)
    }

    var formattedSize: String {
        guard let size = fileSize, size > 0 else { return "--" }
        if size < 1024 { return "\(size) B" }
        if size < 1_048_576 { return "\(size / 1024) KB" }
        return String(format: "%.1f MB", Double(size) / 1_048_576)
    }
}
