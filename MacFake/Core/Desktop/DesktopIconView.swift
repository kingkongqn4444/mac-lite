import SwiftUI

struct DesktopIconView: View {
    let name: String
    let iconName: String
    let iconColor: Color
    let onDoubleTap: () -> Void

    @State private var isSelected = false
    @State private var position: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.gradient)
                    .frame(width: 48, height: 48)

                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
            }

            Text(name)
                .font(MacFonts.desktopIcon)
                .foregroundStyle(MacColors.desktopIconLabel)
                .shadow(color: MacColors.desktopIconLabelShadow, radius: 2, x: 0, y: 1)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? MacColors.selectionHighlight.opacity(0.4) : .clear)
        )
        .frame(width: 72)
        .offset(x: position.width + dragOffset.width,
                y: position.height + dragOffset.height)
        .gesture(
            LongPressGesture(minimumDuration: 0.2)
                .sequenced(before: DragGesture())
                .updating($dragOffset) { value, state, _ in
                    switch value {
                    case .second(true, let drag):
                        state = drag?.translation ?? .zero
                    default:
                        break
                    }
                }
                .onEnded { value in
                    switch value {
                    case .second(true, let drag):
                        let translation = drag?.translation ?? .zero
                        position.width += translation.width
                        position.height += translation.height
                    default:
                        break
                    }
                }
        )
        .contextMenu {
            Button {
                onDoubleTap()
            } label: {
                Label("Open", systemImage: "arrow.up.forward.app")
            }
            Button { } label: {
                Label("Get Info", systemImage: "info.circle")
            }
            Divider()
            Button { } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            Button { } label: {
                Label("Rename", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive) { } label: {
                Label("Move to Trash", systemImage: "trash")
            }
        }
        .simultaneousGesture(
            TapGesture(count: 2).onEnded { onDoubleTap() }
        )
        .simultaneousGesture(
            TapGesture(count: 1).onEnded { isSelected.toggle() }
        )
        .animation(.interactiveSpring(response: 0.2), value: dragOffset)
    }
}
