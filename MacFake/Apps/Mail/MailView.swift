import SwiftUI

/// Fake macOS Mail app with sidebar, message list, and preview
struct MailView: View {
    let windowState: WindowState
    @State private var selectedMailbox = "Inbox"
    @State private var selectedEmail = 0

    private let mailboxes = [
        ("Inbox", "tray.fill", 3), ("Drafts", "doc.fill", 0),
        ("Sent", "paperplane.fill", 0), ("Junk", "xmark.bin.fill", 12),
        ("Trash", "trash.fill", 0),
    ]

    private let emails: [FakeEmail] = [
        FakeEmail(from: "App Store", subject: "Your receipt from Apple", preview: "Thank you for your purchase. Your order #W12345...", time: "10:32 AM", unread: true),
        FakeEmail(from: "GitHub", subject: "[MacFake] Pull request merged", preview: "Your pull request #42 has been merged into main...", time: "9:15 AM", unread: true),
        FakeEmail(from: "John Smith", subject: "Re: Project update", preview: "Hey, I've reviewed the changes and everything looks good...", time: "Yesterday"),
        FakeEmail(from: "LinkedIn", subject: "5 new jobs match your preferences", preview: "Senior iOS Developer at Apple, SwiftUI Engineer at...", time: "Yesterday"),
        FakeEmail(from: "Apple Developer", subject: "WWDC26 tickets confirmed", preview: "Congratulations! You've been selected to attend WWDC26...", time: "Apr 28", unread: true),
        FakeEmail(from: "Notion", subject: "Weekly digest: 3 pages updated", preview: "Here's what happened in your workspace this week...", time: "Apr 27"),
        FakeEmail(from: "Stripe", subject: "Your April payout is on the way", preview: "We've initiated a transfer of $1,234.56 to your bank...", time: "Apr 25"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            sidebar.frame(width: 100)
            Divider()
            messageList.frame(width: 160)
            Divider()
            emailPreview
        }
        .onAppear { windowState.title = "Mail" }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Mailboxes")
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.top, 6)
                .padding(.bottom, 3)

            ForEach(mailboxes, id: \.0) { name, icon, badge in
                Button { selectedMailbox = name } label: {
                    HStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.system(size: 8))
                            .foregroundStyle(.blue)
                            .frame(width: 12)
                        Text(name)
                            .font(.system(size: 8))
                        Spacer()
                        if badge > 0 {
                            Text("\(badge)")
                                .font(.system(size: 7, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.blue, in: Capsule())
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(selectedMailbox == name ? Color.blue.opacity(0.15) : .clear)
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 4)
            }
            Spacer()
        }
        .background(Color(white: 0.96))
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(emails.enumerated()), id: \.offset) { i, email in
                    Button { selectedEmail = i } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                if email.unread {
                                    Circle().fill(.blue).frame(width: 4, height: 4)
                                }
                                Text(email.from)
                                    .font(.system(size: 8, weight: email.unread ? .bold : .regular))
                                Spacer()
                                Text(email.time)
                                    .font(.system(size: 6.5))
                                    .foregroundStyle(.secondary)
                            }
                            Text(email.subject)
                                .font(.system(size: 7.5, weight: .medium))
                                .lineLimit(1)
                            Text(email.preview)
                                .font(.system(size: 7))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .padding(6)
                        .background(selectedEmail == i ? Color.blue.opacity(0.1) : .clear)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 6)
                }
            }
        }
    }

    // MARK: - Email Preview

    private var emailPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 3) {
                Text(emails[selectedEmail].subject)
                    .font(.system(size: 10, weight: .semibold))
                HStack(spacing: 4) {
                    Text("From:")
                        .font(.system(size: 7))
                        .foregroundStyle(.secondary)
                    Text(emails[selectedEmail].from)
                        .font(.system(size: 7, weight: .medium))
                    Spacer()
                    Text(emails[selectedEmail].time)
                        .font(.system(size: 7))
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    Text("To:")
                        .font(.system(size: 7))
                        .foregroundStyle(.secondary)
                    Text("admin@macfake.com")
                        .font(.system(size: 7))
                }
            }
            .padding(8)

            Divider()

            // Body
            ScrollView {
                Text(emails[selectedEmail].preview + "\n\nBest regards,\n\(emails[selectedEmail].from)")
                    .font(.system(size: 8))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct FakeEmail {
    let from: String
    let subject: String
    let preview: String
    let time: String
    var unread = false
}
