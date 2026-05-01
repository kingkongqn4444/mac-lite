import SwiftUI

struct TextEditView: View {
    let windowState: WindowState
    @State private var text = "Welcome to TextEdit.\n\nStart typing here..."
    @State private var isBold = false
    @State private var isItalic = false
    @State private var fontSize: Double = 12

    var body: some View {
        VStack(spacing: 0) {
            // Formatting toolbar
            HStack(spacing: 8) {
                Toggle(isOn: $isBold) {
                    Text("B").fontWeight(.bold)
                }
                .toggleStyle(.button)
                .controlSize(.small)

                Toggle(isOn: $isItalic) {
                    Text("I").italic()
                }
                .toggleStyle(.button)
                .controlSize(.small)

                Divider().frame(height: 16)

                HStack(spacing: 4) {
                    Text("Size:")
                        .font(MacFonts.bodySmall)
                    Stepper(value: $fontSize, in: 8...36, step: 1) {
                        Text("\(Int(fontSize))")
                            .font(MacFonts.bodySmall)
                            .frame(width: 20)
                    }
                    .controlSize(.small)
                }

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(white: 0.97))

            Divider()

            // Text editor
            TextEditor(text: $text)
                .font(.system(
                    size: fontSize,
                    weight: isBold ? .bold : .regular
                )
                .italic(isItalic))
                .scrollContentBackground(.hidden)
                .padding(8)
        }
        .onAppear {
            windowState.title = "Untitled — TextEdit"
        }
    }
}

extension Font {
    func italic(_ isItalic: Bool) -> Font {
        isItalic ? self.italic() : self
    }
}
