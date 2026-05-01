import SwiftUI

struct CalculatorView: View {
    let windowState: WindowState
    @State private var viewModel = CalculatorViewModel()

    private let buttonSpacing: CGFloat = 1

    var body: some View {
        VStack(spacing: 0) {
            // Display
            HStack {
                Spacer()
                Text(viewModel.displayText)
                    .font(MacFonts.calculatorDisplay)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .background(Color(white: 0.15))
            .foregroundStyle(.white)

            // Buttons grid
            VStack(spacing: buttonSpacing) {
                HStack(spacing: buttonSpacing) {
                    funcButton("AC") { viewModel.clear() }
                    funcButton("±") { viewModel.toggleSign() }
                    funcButton("%") { viewModel.percentage() }
                    opButton("÷", .divide)
                }
                HStack(spacing: buttonSpacing) {
                    digitButton("7")
                    digitButton("8")
                    digitButton("9")
                    opButton("×", .multiply)
                }
                HStack(spacing: buttonSpacing) {
                    digitButton("4")
                    digitButton("5")
                    digitButton("6")
                    opButton("−", .subtract)
                }
                HStack(spacing: buttonSpacing) {
                    digitButton("1")
                    digitButton("2")
                    digitButton("3")
                    opButton("+", .add)
                }
                HStack(spacing: buttonSpacing) {
                    digitButton("0", wide: true)
                    digitButton(".")
                    equalsButton()
                }
            }
        }
        .background(Color(white: 0.25))
    }

    @ViewBuilder
    private func digitButton(_ label: String, wide: Bool = false) -> some View {
        Button {
            if label == "." {
                viewModel.inputDecimal()
            } else {
                viewModel.inputDigit(label)
            }
        } label: {
            Text(label)
                .font(MacFonts.calculatorButton)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 32)
                .background(Color(white: 0.35))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: wide ? .infinity : nil)
    }

    @ViewBuilder
    private func funcButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(MacFonts.calculatorButton)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 32)
                .background(Color(white: 0.7))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func opButton(_ label: String, _ op: CalculatorViewModel.Operation) -> some View {
        Button { viewModel.setOperation(op) } label: {
            Text(label)
                .font(MacFonts.calculatorButton)
                .foregroundStyle(viewModel.isActiveOperation(op) ? .orange : .white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 32)
                .background(viewModel.isActiveOperation(op) ? Color.white : Color.orange)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func equalsButton() -> some View {
        Button { viewModel.calculate() } label: {
            Text("=")
                .font(MacFonts.calculatorButton)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 32)
                .background(Color.orange)
        }
        .buttonStyle(.plain)
    }
}
