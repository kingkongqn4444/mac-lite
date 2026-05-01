import SwiftUI

/// Supported languages for syntax highlighting
enum CodeLanguage {
    case swift, kotlin, java, typescript, xml

    var keywords: [String] {
        switch self {
        case .swift:
            return ["import", "struct", "class", "enum", "func", "var", "let", "if", "else",
                    "guard", "return", "switch", "case", "for", "in", "while", "do", "try",
                    "catch", "throw", "throws", "async", "await", "some", "private", "public",
                    "static", "final", "override", "init", "self", "super", "true", "false",
                    "nil", "protocol", "extension", "where", "typealias", "weak", "mutating"]
        case .kotlin:
            return ["package", "import", "class", "fun", "val", "var", "if", "else", "when",
                    "return", "for", "in", "while", "do", "try", "catch", "throw", "object",
                    "data", "sealed", "override", "private", "public", "internal", "open",
                    "abstract", "companion", "suspend", "super", "this", "true", "false", "null"]
        case .java:
            return ["package", "import", "class", "interface", "public", "private", "protected",
                    "static", "final", "void", "int", "boolean", "return", "if", "else", "for",
                    "while", "new", "this", "super", "try", "catch", "throw", "throws",
                    "extends", "implements", "abstract", "synchronized", "true", "false", "null"]
        case .typescript:
            return ["import", "export", "from", "const", "let", "var", "function", "return",
                    "if", "else", "for", "while", "do", "switch", "case", "break", "continue",
                    "class", "interface", "type", "extends", "implements", "new", "this",
                    "async", "await", "try", "catch", "throw", "typeof", "instanceof",
                    "true", "false", "null", "undefined", "default", "as", "readonly"]
        case .xml:
            return [] // XML uses tag-based highlighting
        }
    }

    var typeKeywords: [String] {
        switch self {
        case .swift:
            return ["String", "Int", "Double", "Bool", "Float", "Array", "Dictionary",
                    "Set", "Optional", "View", "Color", "Font", "CGFloat", "CGSize",
                    "State", "Binding", "Observable", "Published", "ObservedObject"]
        case .kotlin:
            return ["String", "Int", "Long", "Double", "Float", "Boolean", "List",
                    "Map", "Set", "Unit", "Any", "Nothing", "Array",
                    "Activity", "Fragment", "ViewModel", "LiveData", "Flow"]
        case .java:
            return ["String", "Integer", "Long", "Double", "Float", "Boolean",
                    "List", "Map", "Set", "Object", "Activity", "Bundle"]
        case .typescript:
            return ["string", "number", "boolean", "void", "any", "never", "unknown",
                    "Array", "Promise", "Record", "Partial", "Required", "React",
                    "FC", "ReactNode", "HTMLElement", "Event"]
        case .xml:
            return []
        }
    }
}

/// Keyword-based regex syntax highlighter using AttributedString
struct SyntaxHighlighter {
    let theme: any IDETheme
    let language: CodeLanguage

    func highlight(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        result.font = theme.editorFont
        result.foregroundColor = theme.textPrimary

        let nsText = text as NSString

        // Comments: // to end of line
        applyPattern(#"//.*$"#, color: theme.syntaxComment, to: &result, in: nsText, multiline: true)

        // Block comments: /* ... */
        applyPattern(#"/\*[\s\S]*?\*/"#, color: theme.syntaxComment, to: &result, in: nsText)

        // Strings: double-quoted and single-quoted
        applyPattern(#""[^"\\]*(?:\\.[^"\\]*)*""#, color: theme.syntaxString, to: &result, in: nsText)
        applyPattern(#"'[^'\\]*(?:\\.[^'\\]*)*'"#, color: theme.syntaxString, to: &result, in: nsText)

        // Template strings
        applyPattern("`[^`]*`", color: theme.syntaxString, to: &result, in: nsText)

        // Numbers
        applyPattern(#"\b\d+\.?\d*\b"#, color: theme.syntaxNumber, to: &result, in: nsText)

        // Type keywords
        for typeKw in language.typeKeywords {
            applyPattern("\\b\(typeKw)\\b", color: theme.syntaxType, to: &result, in: nsText)
        }

        // Language keywords
        for kw in language.keywords {
            applyPattern("\\b\(kw)\\b", color: theme.syntaxKeyword, to: &result, in: nsText)
        }

        // Function calls: word followed by (
        applyPattern(#"\b([a-zA-Z_]\w*)\s*\("#, color: theme.syntaxFunction, to: &result, in: nsText)

        // JSX/XML tags for TypeScript
        if language == .typescript {
            applyPattern(#"</?[A-Z][a-zA-Z]*"#, color: theme.syntaxType, to: &result, in: nsText)
            applyPattern(#"</?[a-z][a-zA-Z]*"#, color: theme.syntaxKeyword, to: &result, in: nsText)
        }

        // Decorators/annotations: @word
        applyPattern(#"@\w+"#, color: theme.syntaxFunction, to: &result, in: nsText)

        return result
    }

    private func applyPattern(
        _ pattern: String,
        color: Color,
        to result: inout AttributedString,
        in nsText: NSString,
        multiline: Bool = false
    ) {
        var options: NSRegularExpression.Options = []
        if multiline { options.insert(.anchorsMatchLines) }

        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
        let matches = regex.matches(in: nsText as String, range: NSRange(location: 0, length: nsText.length))

        let str = nsText as String
        for match in matches {
            guard let range = Range(match.range, in: str) else { continue }
            let lower = AttributedString.Index(range.lowerBound, within: result)
            let upper = AttributedString.Index(range.upperBound, within: result)
            guard let lower, let upper else { continue }
            result[lower..<upper].foregroundColor = color
        }
    }
}
