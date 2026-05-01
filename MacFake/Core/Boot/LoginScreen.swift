import SwiftUI

struct LoginScreen: View {
    let onLogin: () -> Void
    @State private var password = ""
    @State private var isUnlocking = false
    @State private var showHint = false
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // macOS Sequoia wallpaper background (blurred)
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.22, blue: 0.42),
                    Color(red: 0.25, green: 0.45, blue: 0.65),
                    Color(red: 0.55, green: 0.60, blue: 0.55),
                    Color(red: 0.85, green: 0.65, blue: 0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .blur(radius: 30)
            .overlay(Color.black.opacity(0.15).ignoresSafeArea())

            VStack(spacing: 0) {
                Spacer()

                // User avatar — large circle like macOS
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.6, blue: 0.9),
                                    Color(red: 0.6, green: 0.4, blue: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)

                    Text("A")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer().frame(height: 12)

                // User name
                Text("Admin")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)

                Spacer().frame(height: 14)

                // Password field — pill shape like macOS
                HStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))

                        SecureField("Enter Password", text: $password)
                            .font(.system(size: 13))
                            .foregroundStyle(.white)
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .onSubmit { attemptLogin() }
                    }
                    .padding(.leading, 14)

                    Spacer()

                    Button { attemptLogin() } label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(.white.opacity(0.15)))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 4)
                }
                .frame(width: 220, height: 36)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.12))
                        .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5))
                )

                Spacer().frame(height: 8)

                // Hint
                if showHint {
                    Text("Hint: any password works")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                }

                // Loading
                if isUnlocking {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.6)
                        .padding(.top, 8)
                }

                Spacer()

                // Bottom buttons
                HStack(spacing: 32) {
                    loginBottomButton("Restart", icon: "arrow.clockwise")
                    loginBottomButton("Sleep", icon: "moon.fill")
                    loginBottomButton("Shut Down", icon: "power")
                }
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { showHint = true }
            }
        }
    }

    @ViewBuilder
    private func loginBottomButton(_ label: String, icon: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(label)
                .font(.system(size: 9))
        }
        .foregroundStyle(.white.opacity(0.4))
    }

    private func attemptLogin() {
        isUnlocking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isUnlocking = false
            onLogin()
        }
    }
}
