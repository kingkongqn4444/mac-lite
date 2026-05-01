import SwiftUI

/// Embedded terminal panel for IDE bottom area
struct IDETerminalView: View {
    let theme: any IDETheme
    let promptPrefix: String
    let commandResponses: [String: String]
    /// External trigger: set to a non-empty string to inject output into terminal
    @Binding var externalOutput: String

    @State private var lines: [TermLine] = []
    @State private var currentInput = ""
    @FocusState private var isInputFocused: Bool

    struct TermLine: Identifiable {
        let id = UUID()
        let text: String
        let isCommand: Bool
    }

    init(theme: any IDETheme, promptPrefix: String, commandResponses: [String: String], externalOutput: Binding<String> = .constant("")) {
        self.theme = theme
        self.promptPrefix = promptPrefix
        self.commandResponses = commandResponses
        self._externalOutput = externalOutput
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            HStack {
                Text("TERMINAL")
                    .font(.system(size: 6, weight: .medium))
                    .foregroundStyle(theme.textSecondary)
                Spacer()
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(theme.toolbarBackground)

            theme.separatorColor.frame(height: 1)

            // Terminal content
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(lines) { line in
                            Text(line.text)
                                .font(theme.terminalFont)
                                .foregroundStyle(line.isCommand ? theme.textPrimary : theme.textSecondary)
                                .textSelection(.enabled)
                                .id(line.id)
                        }

                        // Input line
                        HStack(spacing: 0) {
                            Text(promptPrefix + " ")
                                .font(theme.terminalFont)
                                .foregroundStyle(theme.accentColor)

                            TextField("", text: $currentInput)
                                .font(theme.terminalFont)
                                .foregroundStyle(theme.textPrimary)
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .focused($isInputFocused)
                                .onSubmit {
                                    executeCommand()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        proxy.scrollTo("input", anchor: .bottom)
                                        isInputFocused = true
                                    }
                                }
                        }
                        .id("input")
                    }
                    .padding(4)
                }
                .onChange(of: lines.count) {
                    proxy.scrollTo("input", anchor: .bottom)
                }
            }
        }
        .background(theme.terminalBackground)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded { isInputFocused = true }
        )
        .onChange(of: externalOutput) {
            if !externalOutput.isEmpty {
                lines.append(TermLine(text: externalOutput, isCommand: false))
                externalOutput = ""
            }
        }
    }

    private func executeCommand() {
        let input = currentInput.trimmingCharacters(in: .whitespaces)
        lines.append(TermLine(text: promptPrefix + " " + input, isCommand: true))

        if !input.isEmpty {
            if input == "clear" {
                lines.removeAll()
            } else if let response = commandResponses[input] {
                lines.append(TermLine(text: response, isCommand: false))
            } else {
                lines.append(TermLine(text: "zsh: command not found: \(input.components(separatedBy: " ").first ?? input)", isCommand: false))
            }
        }

        currentInput = ""
    }
}
