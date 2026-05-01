import SwiftUI

struct NotesView: View {
    let windowState: WindowState
    @State private var viewModel = NotesViewModel()

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Notes")
                        .font(MacFonts.sidebarHeader)
                        .foregroundStyle(MacColors.secondaryText)
                    Spacer()
                    Button { viewModel.createNote() } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

                Divider()

                // Note list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.notes) { note in
                            noteRow(note)
                        }
                    }
                }
            }
            .frame(width: 160)
            .background(MacColors.sidebarBackground)

            Divider()

            // Editor
            if let noteId = viewModel.selectedNoteId,
               let noteIndex = viewModel.notes.firstIndex(where: { $0.id == noteId }) {
                TextEditor(text: Binding(
                    get: { viewModel.notes[noteIndex].body },
                    set: { viewModel.updateBody(noteId, $0) }
                ))
                .font(MacFonts.body)
                .scrollContentBackground(.hidden)
                .padding(8)
            } else {
                Text("No Note Selected")
                    .font(MacFonts.body)
                    .foregroundStyle(MacColors.tertiaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            windowState.title = "Notes"
        }
    }

    @ViewBuilder
    private func noteRow(_ note: NotesViewModel.Note) -> some View {
        Button {
            viewModel.selectedNoteId = note.id
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(note.title)
                    .font(MacFonts.sidebar)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(note.modifiedAt, style: .date)
                    .font(.system(size: 9))
                    .foregroundStyle(MacColors.tertiaryText)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(viewModel.selectedNoteId == note.id ? MacColors.sidebarSelection : .clear)
                    .padding(.horizontal, 4)
            )
        }
        .buttonStyle(.plain)
    }
}
