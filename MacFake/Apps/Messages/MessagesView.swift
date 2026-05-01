import SwiftUI

/// Fake iMessage app with conversation list and chat bubbles
struct MessagesView: View {
    let windowState: WindowState
    @State private var selectedChat = 0
    @State private var inputText = ""

    private let chats: [(String, String, String, [ChatMsg])] = [
        ("John", "J", "Hey, are you coming tonight?", [
            ChatMsg("Hey!", false), ChatMsg("What's up?", true),
            ChatMsg("Are you coming tonight?", false), ChatMsg("Party at my place 🎉", false),
            ChatMsg("Yeah for sure! What time?", true), ChatMsg("8pm, don't be late", false),
            ChatMsg("Got it 👍", true),
        ]),
        ("Mom", "M", "Love you sweetheart ❤️", [
            ChatMsg("Hi honey, how was your day?", false),
            ChatMsg("Good! Been working on a project", true),
            ChatMsg("That's great! Don't forget to eat", false),
            ChatMsg("I won't 😂", true), ChatMsg("Love you sweetheart ❤️", false),
        ]),
        ("Work Group", "W", "Alice: Meeting moved to 3pm", [
            ChatMsg("Team standup at 10am tomorrow", false),
            ChatMsg("I'll be there", true), ChatMsg("Meeting moved to 3pm", false),
        ]),
        ("David", "D", "Check this out!", [
            ChatMsg("Check this out!", false),
            ChatMsg("That's awesome!", true),
        ]),
    ]

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar — conversation list
            sidebar
                .frame(width: 140)
            Divider()
            // Chat content
            chatView
        }
        .onAppear { windowState.title = "Messages" }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 3) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 7))
                    .foregroundStyle(.secondary)
                Text("Search")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(5)
            .background(Color(white: 0.93))
            .cornerRadius(4)
            .padding(6)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(chats.enumerated()), id: \.offset) { i, chat in
                        Button { selectedChat = i } label: {
                            HStack(spacing: 5) {
                                // Avatar
                                Circle()
                                    .fill(avatarColor(i))
                                    .frame(width: 22, height: 22)
                                    .overlay(Text(chat.1).font(.system(size: 8, weight: .bold)).foregroundStyle(.white))

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(chat.0)
                                        .font(.system(size: 8, weight: .semibold))
                                        .lineLimit(1)
                                    Text(chat.2)
                                        .font(.system(size: 7))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(selectedChat == i ? Color.blue.opacity(0.15) : .clear)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .background(Color(white: 0.96))
    }

    // MARK: - Chat View

    private var chatView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Circle()
                    .fill(avatarColor(selectedChat))
                    .frame(width: 18, height: 18)
                    .overlay(Text(chats[selectedChat].1).font(.system(size: 7, weight: .bold)).foregroundStyle(.white))
                Text(chats[selectedChat].0)
                    .font(.system(size: 9, weight: .medium))
                Spacer()
                Image(systemName: "video.fill").font(.system(size: 9)).foregroundStyle(.secondary)
                Image(systemName: "phone.fill").font(.system(size: 9)).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(white: 0.97))

            Divider()

            // Messages
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(chats[selectedChat].3.enumerated()), id: \.offset) { _, msg in
                        HStack {
                            if msg.isMe { Spacer() }
                            Text(msg.text)
                                .font(.system(size: 8))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(msg.isMe ? Color.blue : Color(white: 0.9))
                                .foregroundStyle(msg.isMe ? .white : .primary)
                                .cornerRadius(8)
                            if !msg.isMe { Spacer() }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 6)
            }

            Divider()

            // Input bar
            HStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                TextField("iMessage", text: $inputText)
                    .font(.system(size: 8))
                    .textFieldStyle(.plain)
                    .padding(4)
                    .background(Color(white: 0.93))
                    .cornerRadius(10)
            }
            .padding(6)
        }
    }

    private func avatarColor(_ i: Int) -> Color {
        [Color.blue, .green, .orange, .purple, .red, .cyan][i % 6]
    }
}

private struct ChatMsg {
    let text: String
    let isMe: Bool
    init(_ text: String, _ isMe: Bool) { self.text = text; self.isMe = isMe }
}
