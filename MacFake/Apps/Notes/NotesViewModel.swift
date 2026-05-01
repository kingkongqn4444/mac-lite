import SwiftUI

@Observable
final class NotesViewModel {
    var notes: [Note] = [
        Note(title: "Welcome to Notes", body: "This is a sample note.\nYou can create, edit, and delete notes."),
        Note(title: "Shopping List", body: "- Apples\n- Bread\n- Milk\n- Coffee"),
    ]
    var selectedNoteId: UUID?

    var selectedNote: Note? {
        notes.first { $0.id == selectedNoteId }
    }

    struct Note: Identifiable {
        let id = UUID()
        var title: String
        var body: String
        var modifiedAt = Date()
    }

    init() {
        selectedNoteId = notes.first?.id
    }

    func createNote() {
        let note = Note(title: "New Note", body: "")
        notes.insert(note, at: 0)
        selectedNoteId = note.id
    }

    func deleteNote(_ id: UUID) {
        notes.removeAll { $0.id == id }
        if selectedNoteId == id {
            selectedNoteId = notes.first?.id
        }
    }

    func updateBody(_ id: UUID, _ newBody: String) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[index].body = newBody
        notes[index].modifiedAt = Date()
        // Update title from first line
        let firstLine = newBody.components(separatedBy: .newlines).first ?? "New Note"
        notes[index].title = firstLine.isEmpty ? "New Note" : String(firstLine.prefix(40))
    }
}
