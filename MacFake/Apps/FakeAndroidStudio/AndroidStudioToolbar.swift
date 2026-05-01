import SwiftUI

/// Android Studio toolbar with Run/Debug, device and module selectors
struct AndroidStudioToolbar: View {
    let theme: AndroidStudioTheme
    var onRun: (() -> Void)?
    var onStop: (() -> Void)?

    @State private var buildStatus = "Gradle sync finished"
    @State private var isRunning = false

    var body: some View {
        HStack(spacing: 4) {
            // Module selector
            HStack(spacing: 2) {
                Image(systemName: "cube")
                    .font(.system(size: 5))
                Text("app")
                    .font(.system(size: 7, weight: .medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 4))
            }
            .foregroundStyle(theme.textPrimary)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color(white: 0.28), in: RoundedRectangle(cornerRadius: 2))

            Divider().frame(height: 10)

            // Device selector
            HStack(spacing: 2) {
                Image(systemName: "iphone.gen3")
                    .font(.system(size: 5))
                Text("Pixel 8 API 35")
                    .font(.system(size: 7))
                Image(systemName: "chevron.down")
                    .font(.system(size: 4))
            }
            .foregroundStyle(theme.textSecondary)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color(white: 0.25), in: RoundedRectangle(cornerRadius: 2))

            Divider().frame(height: 10)

            // Run button
            Button {
                guard !isRunning else { return }
                isRunning = true
                buildStatus = "Gradle Build Running..."
                onRun?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    buildStatus = "Gradle sync finished"
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

            // Debug button
            Button {} label: {
                Image(systemName: "ant.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(theme.textSecondary)
                    .frame(width: 14, height: 14)
                    .background(Color(white: 0.28), in: RoundedRectangle(cornerRadius: 2))
            }
            .buttonStyle(.plain)

            Spacer()

            // Build status
            HStack(spacing: 2) {
                Image(systemName: isRunning ? "progress.indicator" : "checkmark.circle.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(isRunning ? .white : theme.accentColor)
                Text(buildStatus)
                    .font(.system(size: 6))
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(.horizontal, 4)
    }
}
