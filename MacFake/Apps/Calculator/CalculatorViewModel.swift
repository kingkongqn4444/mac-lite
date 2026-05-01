import SwiftUI

@Observable
final class CalculatorViewModel {
    var displayText = "0"

    private var currentNumber: Double = 0
    private var storedNumber: Double?
    private var pendingOperation: Operation?
    private var shouldResetDisplay = false
    private var hasDecimal = false

    enum Operation {
        case add, subtract, multiply, divide
    }

    func inputDigit(_ digit: String) {
        if shouldResetDisplay {
            displayText = digit
            shouldResetDisplay = false
            hasDecimal = false
        } else if displayText == "0" && digit != "." {
            displayText = digit
        } else {
            displayText += digit
        }
        currentNumber = Double(displayText) ?? 0
    }

    func inputDecimal() {
        guard !hasDecimal else { return }
        hasDecimal = true
        if shouldResetDisplay {
            displayText = "0."
            shouldResetDisplay = false
        } else {
            displayText += "."
        }
    }

    func setOperation(_ op: Operation) {
        if let pending = pendingOperation, storedNumber != nil {
            calculate()
        }
        storedNumber = currentNumber
        pendingOperation = op
        shouldResetDisplay = true
        hasDecimal = false
    }

    func calculate() {
        guard let stored = storedNumber, let op = pendingOperation else { return }
        let result: Double
        switch op {
        case .add: result = stored + currentNumber
        case .subtract: result = stored - currentNumber
        case .multiply: result = stored * currentNumber
        case .divide:
            if currentNumber == 0 {
                displayText = "Error"
                storedNumber = nil
                pendingOperation = nil
                shouldResetDisplay = true
                return
            }
            result = stored / currentNumber
        }
        currentNumber = result
        displayText = formatNumber(result)
        storedNumber = nil
        pendingOperation = nil
        shouldResetDisplay = true
        hasDecimal = false
    }

    func clear() {
        displayText = "0"
        currentNumber = 0
        storedNumber = nil
        pendingOperation = nil
        shouldResetDisplay = false
        hasDecimal = false
    }

    func toggleSign() {
        currentNumber = -currentNumber
        displayText = formatNumber(currentNumber)
    }

    func percentage() {
        currentNumber = currentNumber / 100
        displayText = formatNumber(currentNumber)
    }

    func isActiveOperation(_ op: Operation) -> Bool {
        pendingOperation == op && shouldResetDisplay
    }

    private func formatNumber(_ number: Double) -> String {
        if number == floor(number) && !number.isInfinite {
            return String(format: "%.0f", number)
        }
        let formatted = String(format: "%.8f", number)
        // Remove trailing zeros
        var result = formatted
        while result.hasSuffix("0") { result.removeLast() }
        if result.hasSuffix(".") { result.removeLast() }
        return result
    }
}
