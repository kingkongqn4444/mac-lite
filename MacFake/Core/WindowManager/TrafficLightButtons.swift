import SwiftUI

struct TrafficLightButtons: View {
    let onClose: () -> Void
    let onMinimize: () -> Void
    let onMaximize: () -> Void

    private let dotSize: CGFloat = 11
    private let tapSize: CGFloat = 20

    var body: some View {
        HStack(spacing: 0) {
            trafficLight(color: MacColors.closeButton, symbol: "xmark", action: onClose)
            trafficLight(color: MacColors.minimizeButton, symbol: "minus", action: onMinimize)
            trafficLight(color: MacColors.maximizeButton, symbol: "plus", action: onMaximize)
        }
    }

    @ViewBuilder
    private func trafficLight(color: Color, symbol: String, action: @escaping () -> Void) -> some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: dotSize, height: dotSize)
                .shadow(color: .black.opacity(0.15), radius: 0.5, y: 0.5)

            Image(systemName: symbol)
                .font(.system(size: 6, weight: .bold))
                .foregroundStyle(.black.opacity(0.5))
        }
        .frame(width: tapSize, height: tapSize)
        .contentShape(Rectangle())
        .highPriorityGesture(
            TapGesture().onEnded { action() }
        )
    }
}
