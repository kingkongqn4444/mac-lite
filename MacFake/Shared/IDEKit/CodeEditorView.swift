import SwiftUI

/// Editable code editor with line numbers and syntax highlighting
struct CodeEditorView: View {
    let theme: any IDETheme
    let language: CodeLanguage
    @Binding var text: String

    @State private var highlightedText: AttributedString = AttributedString("")
    @State private var debounceTask: Task<Void, Never>?

    private var lineCount: Int {
        max(text.components(separatedBy: "\n").count, 1)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Line numbers gutter
            lineNumbersView
                .frame(width: 22)
                .background(theme.editorBackground.opacity(0.8))

            // Separator
            theme.separatorColor.frame(width: 1)

            // Code editor area
            editorArea
        }
        .background(theme.editorBackground)
        .onAppear { updateHighlight() }
        .onChange(of: text) { debounceHighlight() }
    }

    // MARK: - Line Numbers
    private var lineNumbersView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(1...lineCount, id: \.self) { line in
                    Text("\(line)")
                        .font(theme.editorFont)
                        .foregroundStyle(theme.lineNumberColor)
                        .frame(height: 10)
                }
            }
            .padding(.top, 4)
            .padding(.trailing, 3)
        }
    }

    // MARK: - Editor
    private var editorArea: some View {
        ZStack(alignment: .topLeading) {
            // Highlighted text overlay (read-only display)
            ScrollView {
                Text(highlightedText)
                    .font(theme.editorFont)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Invisible TextEditor for input
            TextEditor(text: $text)
                .font(theme.editorFont)
                .foregroundStyle(.clear)
                .scrollContentBackground(.hidden)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 3)
                .padding(.top, 2)
                .opacity(0.01) // Nearly invisible but captures input
        }
    }

    // MARK: - Highlighting
    private func debounceHighlight() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
            guard !Task.isCancelled else { return }
            await MainActor.run { updateHighlight() }
        }
    }

    private func updateHighlight() {
        let highlighter = SyntaxHighlighter(theme: theme, language: language)
        highlightedText = highlighter.highlight(text)
    }
}
