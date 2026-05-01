import SwiftUI

struct DockView: View {
    @Environment(WindowManager.self) private var windowManager
    let screenSize: CGSize
    @Binding var showLaunchpad: Bool
    @State private var hoverX: CGFloat? = nil
    @State private var isHovering = false

    private let iconSize: CGFloat = 30
    private let maxScale: CGFloat = 1.8
    private let influenceRange: CGFloat = 80 // How far the magnification reaches

    private var allItems: [DockItem] {
        var items = FakeApp.dockApps.map { DockItem.app($0) }
        items.append(.launchpad)
        items.append(.separator)
        items.append(.trash)
        return items
    }

    var body: some View {
        // Use GeometryReader to track positions
        GeometryReader { dockGeo in
            HStack(alignment: .bottom, spacing: 0) {
                Spacer()
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(Array(allItems.enumerated()), id: \.offset) { index, item in
                        switch item {
                        case .app(let app):
                            let scale = magnification(for: index, in: dockGeo)
                            DockIconView(
                                app: app,
                                isRunning: windowManager.isRunning(app),
                                scale: scale
                            ) {
                                HapticManager.dock()
                                windowManager.openApp(app, screenSize: screenSize)
                            }
                            .zIndex(scale > 1.1 ? 1 : 0) // Magnified icons render on top

                        case .launchpad:
                            let scale = magnification(for: index, in: dockGeo)
                            DockIconView(
                                app: nil,
                                iconName: "square.grid.3x3.fill",
                                label: "Launchpad",
                                isRunning: false,
                                scale: scale
                            ) {
                                HapticManager.dock()
                                withAnimation(.easeOut(duration: 0.2)) { showLaunchpad = true }
                            }
                            .zIndex(scale > 1.1 ? 1 : 0)

                        case .separator:
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 1, height: iconSize * 0.5)
                                .padding(.horizontal, 4)
                                .padding(.bottom, 6)

                        case .trash:
                            let scale = magnification(for: index, in: dockGeo)
                            DockIconView(
                                app: nil,
                                iconName: "trash.fill",
                                label: "Trash",
                                isRunning: false,
                                scale: scale
                            ) { }
                            .zIndex(scale > 1.1 ? 1 : 0)
                        }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial.opacity(0.7))
                        .macShadow(MacShadows.dock)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                )
                // Touch tracking — simultaneousGesture so tap still works on icons
                .simultaneousGesture(
                    DragGesture(minimumDistance: 3)
                        .onChanged { value in
                            isHovering = true
                            hoverX = value.location.x
                        }
                        .onEnded { _ in
                            withAnimation(.easeOut(duration: 0.25)) {
                                isHovering = false
                                hoverX = nil
                            }
                        }
                )
                Spacer()
            }
        }
        .frame(height: isHovering ? 60 : 42) // Expand when magnifying
        .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.7), value: isHovering)
    }

    // MARK: - Magnification Calculation

    private func magnification(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        guard isHovering, let hover = hoverX else { return 1.0 }

        // Calculate icon center position
        let spacing: CGFloat = 2
        let itemWidth = iconSize + 6 + spacing
        let totalItems = allItems.count
        let dockWidth = CGFloat(totalItems) * itemWidth
        let startX: CGFloat = 6 // left padding

        let iconCenter = startX + CGFloat(index) * itemWidth + itemWidth / 2

        // Gaussian magnification
        let distance = abs(hover - iconCenter)
        if distance > influenceRange { return 1.0 }

        let normalized = distance / influenceRange
        let gaussian = cos(normalized * .pi / 2) // Cosine falloff (smoother than gaussian)
        let scale = 1.0 + (maxScale - 1.0) * gaussian * gaussian

        return scale
    }
}

// MARK: - Dock Item

private enum DockItem {
    case app(FakeApp)
    case launchpad
    case separator
    case trash
}
