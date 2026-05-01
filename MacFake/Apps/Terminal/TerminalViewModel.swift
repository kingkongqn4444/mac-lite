import SwiftUI

@Observable
final class TerminalViewModel {
    var lines: [TerminalLine] = []
    var currentInput = ""
    var cwd = "/Users/admin"
    var commandHistory: [String] = []
    var historyIndex: Int = -1

    private let parser = CommandParser()

    struct TerminalLine: Identifiable {
        let id = UUID()
        let text: String
        let isCommand: Bool
    }

    var prompt: String {
        let dir = cwd == "/Users/admin" ? "~" : (cwd.components(separatedBy: "/").last ?? "~")
        return "admin@MacBook-Pro \(dir) % "
    }

    init() {
        lines.append(TerminalLine(
            text: "Last login: \(Date().formatted()) on ttys000",
            isCommand: false
        ))
    }

    func executeCommand() {
        let input = currentInput.trimmingCharacters(in: .whitespaces)

        // Add command line to output
        lines.append(TerminalLine(text: prompt + input, isCommand: true))

        if !input.isEmpty {
            commandHistory.append(input)
            historyIndex = commandHistory.count

            let result = parser.execute(input, cwd: cwd)

            if result.output == "__CLEAR__" {
                lines.removeAll()
            } else if !result.output.isEmpty {
                lines.append(TerminalLine(text: result.output, isCommand: false))
            }

            cwd = result.newCwd
        }

        currentInput = ""
    }

    func previousCommand() {
        guard !commandHistory.isEmpty, historyIndex > 0 else { return }
        historyIndex -= 1
        currentInput = commandHistory[historyIndex]
    }

    func nextCommand() {
        guard historyIndex < commandHistory.count - 1 else {
            currentInput = ""
            historyIndex = commandHistory.count
            return
        }
        historyIndex += 1
        currentInput = commandHistory[historyIndex]
    }
}
