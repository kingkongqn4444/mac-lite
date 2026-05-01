import SwiftUI

struct SafariView: View {
    let windowState: WindowState
    @State private var urlString = "https://www.apple.com"
    @State private var pageTitle = "Safari"
    @State private var canGoBack = false
    @State private var canGoForward = false

    private var url: URL {
        if let url = URL(string: urlString), url.scheme != nil {
            return url
        }
        return URL(string: "https://\(urlString)") ?? URL(string: "https://www.apple.com")!
    }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 8) {
                Button { } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10))
                }
                .disabled(true)
                .buttonStyle(.plain)

                Button { } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                }
                .disabled(true)
                .buttonStyle(.plain)

                // URL bar
                HStack {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.green)

                    TextField("Search or enter website", text: $urlString)
                        .font(MacFonts.body)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            windowState.title = pageTitle
                        }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(white: 0.92))
                )

                Button { } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(white: 0.97))

            Divider()

            // Web content
            SafariWebView(url: url, pageTitle: $pageTitle)
                .onChange(of: pageTitle) {
                    windowState.title = pageTitle.isEmpty ? "Safari" : pageTitle
                }
        }
        .onAppear {
            windowState.title = "Safari"
        }
    }
}
