import SwiftUI

struct AboutMacView: View {
    let windowState: WindowState

    private var deviceName: String {
        UIDevice.current.name
    }

    private var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
        }
        // Map common identifiers
        if machine.contains("iPhone") { return "iPhone" }
        if machine.contains("iPad") { return "iPad" }
        if machine.contains("x86_64") || machine.contains("arm64") { return "MacBook Pro" }
        return machine
    }

    private var chipName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
        }
        if machine.contains("iPhone16") { return "Apple A17 Pro" }
        if machine.contains("iPhone15") { return "Apple A16 Bionic" }
        if machine.contains("iPhone14") { return "Apple A15 Bionic" }
        return "Apple M4 Pro"
    }

    private var memoryGB: String {
        let mem = ProcessInfo.processInfo.physicalMemory
        return "\(mem / (1024 * 1024 * 1024)) GB"
    }

    private var serialNumber: String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ0123456789"
        // Generate deterministic serial from device name
        var serial = "FVFXM"
        let seed = deviceName.hashValue
        var gen = seed
        for _ in 0..<5 {
            gen = gen &* 6364136223846793005 &+ 1
            let idx = abs(gen) % chars.count
            serial += String(chars[chars.index(chars.startIndex, offsetBy: idx)])
        }
        return serial
    }

    private var osVersion: String {
        UIDevice.current.systemVersion
    }

    private var storageInfo: String {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let total = attrs[.systemSize] as? Int64 else { return "Unknown" }
        return String(format: "%.0f GB", Double(total) / 1_073_741_824)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    Spacer().frame(height: 8)

                    // Device image
                    Image(systemName: "laptopcomputer")
                        .font(.system(size: 52))
                        .foregroundStyle(Color(white: 0.5))

                    // Device name
                    Text("MacBook Pro")
                        .font(.system(size: 18, weight: .semibold))

                    // macOS version
                    VStack(spacing: 2) {
                        Text("macOS Sequoia")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text("Version 15.4")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(white: 0.5))
                    }

                    Spacer().frame(height: 4)

                    // Specs table
                    VStack(spacing: 6) {
                        specRow("Chip", chipName)
                        specRow("Memory", memoryGB)
                        specRow("Startup disk", "Macintosh HD")
                        specRow("Serial number", serialNumber)
                        specRow("macOS Sequoia", "15.4 (24E248)")
                    }

                    Spacer().frame(height: 8)

                    // More Info button
                    Button("More Info...") { }
                        .font(.system(size: 11))
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .tint(.accentColor)

                    Spacer().frame(height: 4)

                    // Footer
                    VStack(spacing: 2) {
                        Text("Regulatory Certification")
                            .font(.system(size: 9))
                            .foregroundStyle(.blue)
                        Text("™ and © 1983-2025 Apple Inc.\nAll Rights Reserved.")
                            .font(.system(size: 8))
                            .foregroundStyle(Color(white: 0.5))
                            .multilineTextAlignment(.center)
                    }

                    Spacer().frame(height: 4)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(white: 0.14))
        .foregroundStyle(.white)
        .onAppear { windowState.title = "About This Mac" }
    }

    @ViewBuilder
    private func specRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color(white: 0.5))
                .frame(width: 90, alignment: .trailing)
                .padding(.trailing, 8)
            Text(value)
                .font(.system(size: 10))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }
}
