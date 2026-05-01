import SwiftUI

/// Android Studio Logcat panel with colored log entries
struct AndroidStudioLogcat: View {
    let theme: AndroidStudioTheme

    private let logEntries: [(String, LogLevel, String, String)] = [
        ("10:05:12.234", .debug, "MyApp", "Activity created"),
        ("10:05:12.456", .info, "System", "VM initialized"),
        ("10:05:12.567", .debug, "Compose", "Recomposition started"),
        ("10:05:12.789", .info, "MyApp", "Theme applied: Material3"),
        ("10:05:13.012", .debug, "OkHttp", "API call: GET /api/users"),
        ("10:05:13.234", .warning, "Compose", "Skipping recomposition: no changes"),
        ("10:05:13.456", .debug, "MyApp", "User list loaded: 12 items"),
        ("10:05:13.678", .info, "System", "GC freed 2.4MB"),
        ("10:05:14.123", .debug, "Navigation", "Navigate to HomeScreen"),
        ("10:05:14.345", .info, "Lifecycle", "ON_RESUME"),
    ]

    private enum LogLevel {
        case debug, info, warning

        var color: Color {
            switch self {
            case .debug: Color(red: 0.42, green: 0.58, blue: 0.78)   // Blue
            case .info: Color(red: 0.42, green: 0.68, blue: 0.42)    // Green
            case .warning: Color(red: 0.88, green: 0.75, blue: 0.30) // Yellow
            }
        }

        var label: String {
            switch self {
            case .debug: "D"
            case .info: "I"
            case .warning: "W"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Logcat header
            HStack(spacing: 6) {
                Text("Logcat")
                    .font(.system(size: 6, weight: .medium))
                    .foregroundStyle(theme.textPrimary)

                Divider().frame(height: 12)

                // Filter dropdown
                HStack(spacing: 2) {
                    Text("Debug")
                        .font(.system(size: 6))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 6))
                }
                .foregroundStyle(theme.textSecondary)

                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 5))
                    Text("Filter...")
                        .font(.system(size: 6))
                }
                .foregroundStyle(theme.textSecondary.opacity(0.5))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(white: 0.22), in: RoundedRectangle(cornerRadius: 3))

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(theme.toolbarBackground)

            theme.separatorColor.frame(height: 1)

            // Log entries
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(Array(logEntries.enumerated()), id: \.offset) { _, entry in
                        HStack(spacing: 4) {
                            Text(entry.0)
                                .foregroundStyle(theme.textSecondary)
                            Text(entry.1.label)
                                .foregroundStyle(entry.1.color)
                                .fontWeight(.bold)
                            Text("/\(entry.2):")
                                .foregroundStyle(entry.1.color)
                            Text(entry.3)
                                .foregroundStyle(theme.textPrimary)
                        }
                        .font(.system(size: 6, design: .monospaced))
                        .padding(.horizontal, 6)
                    }
                }
                .padding(.vertical, 4)
            }
            .background(theme.terminalBackground)
        }
    }
}
