import SwiftUI

/// Xcode-style toolbar with Run/Stop, scheme and device selectors
struct XcodeToolbar: View {
    let theme: XcodeTheme
    var onRun: (() -> Void)?
    var onStop: (() -> Void)?

    @State private var buildStatus = "Build Succeeded"
    @State private var buildStatusColor: Color = .green
    @State private var isRunning = false

    var body: some View {
        HStack(spacing: 4) {
            // Run button
            Button {
                guard !isRunning else { return }
                isRunning = true
                buildStatus = "Building..."
                buildStatusColor = .white
                onRun?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    buildStatus = "Build Succeeded"
                    buildStatusColor = .green
                    isRunning = false
                }
            } label: {
                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(.white)
                    .frame(width: 14, height: 14)
                    .background(isRunning ? .orange : theme.accentColor, in: RoundedRectangle(cornerRadius: 2))
            }
            .buttonStyle(.plain)

            // Stop button
            Button {
                if isRunning {
                    isRunning = false
                    buildStatus = "Build Cancelled"
                    buildStatusColor = .orange
                    onStop?()
                }
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 5))
                    .foregroundStyle(isRunning ? .white : theme.textSecondary)
                    .frame(width: 14, height: 14)
                    .background(Color(white: 0.25), in: RoundedRectangle(cornerRadius: 2))
            }
            .buttonStyle(.plain)

            Divider().frame(height: 10)

            // Scheme selector
            HStack(spacing: 2) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 5))
                Text("MacFake")
                    .font(.system(size: 7, weight: .medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 4))
            }
            .foregroundStyle(theme.textPrimary)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color(white: 0.25), in: RoundedRectangle(cornerRadius: 2))

            // Device selector
            HStack(spacing: 2) {
                Image(systemName: "iphone")
                    .font(.system(size: 5))
                Text("iPhone 16 Pro")
                    .font(.system(size: 7))
                Image(systemName: "chevron.down")
                    .font(.system(size: 4))
            }
            .foregroundStyle(theme.textSecondary)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color(white: 0.22), in: RoundedRectangle(cornerRadius: 2))

            Spacer()

            // Build status
            HStack(spacing: 2) {
                Image(systemName: isRunning ? "progress.indicator" : "checkmark.circle.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(buildStatusColor)
                Text(buildStatus)
                    .font(.system(size: 6))
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(.horizontal, 4)
    }
}
