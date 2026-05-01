import SwiftUI

struct ResizableWindow<Content: View>: View {
    @Environment(WindowManager.self) private var windowManager
    let window: WindowState
    let screenSize: CGSize
    @ViewBuilder let content: () -> Content

    private var isFocused: Bool {
        windowManager.focusedWindowId == window.id
    }

    var body: some View {
        // Window chrome + content
        VStack(spacing: 0) {
            // Title bar with native UIKit pan gesture for smooth dragging
            DraggableTitleBar(
                title: window.title,
                isFocused: isFocused,
                onDrag: { translation in
                    windowManager.updatePosition(window.id, CGPoint(
                        x: window.position.x + translation.x,
                        y: window.position.y + translation.y
                    ))
                },
                onDragStart: {
                    windowManager.bringToFront(window.id)
                },
                onClose: {
                    HapticManager.windowAction()
                    withAnimation(.easeOut(duration: 0.15)) {
                        windowManager.closeWindow(window.id)
                    }
                },
                onMinimize: {
                    HapticManager.windowAction()
                    withAnimation(.easeOut(duration: 0.2)) {
                        windowManager.minimizeWindow(window.id)
                    }
                },
                onMaximize: {
                    HapticManager.windowAction()
                    withAnimation(.spring(response: 0.3)) {
                        windowManager.maximizeWindow(window.id, screenSize: screenSize)
                    }
                }
            )
            .frame(height: 28)
            .fixedSize(horizontal: false, vertical: true)

            Rectangle().fill(MacColors.windowBorder).frame(height: 0.5)

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(MacColors.windowBackground)
        }
        .frame(width: window.size.width, height: window.size.height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(MacColors.windowBorder, lineWidth: 0.5)
        )
        .compositingGroup()
        .shadow(
            color: .black.opacity(isFocused ? 0.2 : 0.1),
            radius: isFocused ? 6 : 3,
            x: 0, y: isFocused ? 2 : 1
        )
        .overlay(alignment: .bottomTrailing) {
            if window.app.resizable && !window.isMaximized {
                resizeHandle
            }
        }
        .position(x: window.position.x, y: window.position.y)
        .zIndex(Double(window.zIndex))
    }

    private var resizeHandle: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 8))
            .foregroundStyle(MacColors.tertiaryText)
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        let minSize = window.app.minWindowSize
                        windowManager.updateSize(window.id, CGSize(
                            width: max(minSize.width, window.size.width + value.translation.width),
                            height: max(minSize.height, window.size.height + value.translation.height)
                        ))
                    }
            )
    }
}

// MARK: - UIKit-based Draggable Title Bar (no SwiftUI gesture lag)

struct DraggableTitleBar: UIViewRepresentable {
    let title: String
    let isFocused: Bool
    let onDrag: (CGPoint) -> Void
    let onDragStart: () -> Void
    let onClose: () -> Void
    let onMinimize: () -> Void
    let onMaximize: () -> Void

    func makeUIView(context: Context) -> DraggableTitleBarUIView {
        let view = DraggableTitleBarUIView()
        view.onDrag = onDrag
        view.onDragStart = onDragStart
        view.updateContent(title: title, isFocused: isFocused,
                          onClose: onClose, onMinimize: onMinimize, onMaximize: onMaximize)
        return view
    }

    func updateUIView(_ view: DraggableTitleBarUIView, context: Context) {
        view.onDrag = onDrag
        view.onDragStart = onDragStart
        view.updateContent(title: title, isFocused: isFocused,
                          onClose: onClose, onMinimize: onMinimize, onMaximize: onMaximize)
    }
}

final class DraggableTitleBarUIView: UIView {
    var onDrag: ((CGPoint) -> Void)?
    var onDragStart: (() -> Void)?

    private let titleLabel = UILabel()
    private let closeBtn = UIButton(type: .system)
    private let minBtn = UIButton(type: .system)
    private let maxBtn = UIButton(type: .system)
    private var lastTranslation: CGPoint = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupPanGesture()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        // Title label
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Traffic light buttons
        let dots = [closeBtn, minBtn, maxBtn]
        let colors: [UIColor] = [
            UIColor(red: 1, green: 0.38, blue: 0.34, alpha: 1),
            UIColor(red: 1, green: 0.74, blue: 0.02, alpha: 1),
            UIColor(red: 0.15, green: 0.78, blue: 0.25, alpha: 1)
        ]
        let symbols = ["xmark", "minus", "plus"]

        let stack = UIStackView(arrangedSubviews: dots)
        stack.axis = .horizontal
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        for (i, btn) in dots.enumerated() {
            let dot = UIView()
            dot.backgroundColor = colors[i]
            dot.layer.cornerRadius = 5.5
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.isUserInteractionEnabled = false
            btn.addSubview(dot)

            let img = UIImageView(image: UIImage(systemName: symbols[i],
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 6, weight: .bold)))
            img.tintColor = UIColor.black.withAlphaComponent(0.5)
            img.translatesAutoresizingMaskIntoConstraints = false
            btn.addSubview(img)

            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 22),
                btn.heightAnchor.constraint(equalToConstant: 28),
                dot.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
                dot.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
                dot.widthAnchor.constraint(equalToConstant: 11),
                dot.heightAnchor.constraint(equalToConstant: 11),
                img.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
                img.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            ])
        }

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: stack.trailingAnchor, constant: 4),
            heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            lastTranslation = .zero
            onDragStart?()
        case .changed:
            let translation = gesture.translation(in: self)
            let delta = CGPoint(
                x: translation.x - lastTranslation.x,
                y: translation.y - lastTranslation.y
            )
            lastTranslation = CGPoint(x: translation.x, y: translation.y)
            onDrag?(delta)
        default:
            break
        }
    }

    func updateContent(title: String, isFocused: Bool,
                      onClose: @escaping () -> Void, onMinimize: @escaping () -> Void, onMaximize: @escaping () -> Void) {
        titleLabel.text = title
        titleLabel.textColor = isFocused ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.6, alpha: 1)
        backgroundColor = isFocused ? UIColor(white: 0.93, alpha: 1) : UIColor(white: 0.96, alpha: 1)

        closeBtn.removeTarget(nil, action: nil, for: .touchUpInside)
        minBtn.removeTarget(nil, action: nil, for: .touchUpInside)
        maxBtn.removeTarget(nil, action: nil, for: .touchUpInside)

        closeBtn.addAction(UIAction { _ in onClose() }, for: .touchUpInside)
        minBtn.addAction(UIAction { _ in onMinimize() }, for: .touchUpInside)
        maxBtn.addAction(UIAction { _ in onMaximize() }, for: .touchUpInside)
    }
}
