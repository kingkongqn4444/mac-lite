import SwiftUI

struct TerminalView: View {
    let windowState: WindowState
    @State private var viewModel = TerminalViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(viewModel.lines) { line in
                            Text(line.text)
                                .font(MacFonts.terminal)
                                .foregroundStyle(line.isCommand ? Color.white : Color(white: 0.85))
                                .textSelection(.enabled)
                                .id(line.id)
                        }

                        // Input line
                        HStack(spacing: 0) {
                            Text(viewModel.prompt)
                                .font(MacFonts.terminal)
                                .foregroundStyle(.green)

                            TextField("", text: $viewModel.currentInput)
                                .font(MacFonts.terminal)
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .focused($isInputFocused)
                                .onSubmit {
                                    viewModel.executeCommand()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        proxy.scrollTo("input", anchor: .bottom)
                                        isInputFocused = true // Re-focus after submit
                                    }
                                }
                        }
                        .id("input")
                    }
                    .padding(8)
                }
                .onChange(of: viewModel.lines.count) {
                    proxy.scrollTo("input", anchor: .bottom)
                }
            }
        }
        .background(Color(white: 0.1))
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                isInputFocused = true
            }
        )
        .onAppear {
            windowState.title = "admin — zsh"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isInputFocused = true
            }
        }
    }
}
