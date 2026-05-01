import SwiftUI

enum BootPhase {
    case booting
    case login
    case desktop
}

struct BootScreen: View {
    @State private var progress: CGFloat = 0
    @State private var phase: BootPhase = .booting
    @Binding var bootComplete: Bool

    var body: some View {
        switch phase {
        case .booting:
            bootView
        case .login:
            LoginScreen(onLogin: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    phase = .desktop
                    bootComplete = true
                }
            })
            .transition(.opacity)
        case .desktop:
            EmptyView()
        }
    }

    // MARK: - Boot View (Apple logo + progress bar)

    private var bootView: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                // Apple logo
                Image(systemName: "apple.logo")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(white: 0.25))
                        .frame(width: 180, height: 5)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white)
                        .frame(width: 180 * progress, height: 5)
                }
            }
        }
        .onAppear {
            startBoot()
        }
    }

    private func startBoot() {
        // Animate progress bar over ~2.5 seconds
        withAnimation(.easeInOut(duration: 0.8)) {
            progress = 0.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.7)) {
                progress = 0.65
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                progress = 0.9
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                progress = 1.0
            }
        }
        // Transition to login
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .login
            }
        }
    }
}
