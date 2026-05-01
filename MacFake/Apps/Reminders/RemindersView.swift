import SwiftUI

/// Fake macOS Reminders app with sidebar lists and reminder items
struct RemindersView: View {
    let windowState: WindowState
    @State private var selectedList = 0

    private let lists: [(String, Color, String, [ReminderItem])] = [
        ("Today", .blue, "calendar", [
            ReminderItem("Review pull request", false, "10:00 AM"),
            ReminderItem("Call dentist", false, "2:00 PM"),
            ReminderItem("Buy groceries", false, "6:00 PM"),
        ]),
        ("Scheduled", .red, "calendar.badge.clock", [
            ReminderItem("WWDC session", false, "Jun 10"),
            ReminderItem("Team lunch", false, "Tomorrow"),
            ReminderItem("Pay rent", false, "May 5"),
        ]),
        ("All", .gray, "tray.fill", [
            ReminderItem("Fix login bug", true, nil),
            ReminderItem("Update README", false, nil),
            ReminderItem("Design review", false, nil),
            ReminderItem("Write unit tests", false, nil),
            ReminderItem("Deploy v2.0", false, nil),
        ]),
        ("Flagged", .orange, "flag.fill", [
            ReminderItem("Submit tax return", false, "May 15"),
            ReminderItem("Renew passport", false, "Jun 1"),
        ]),
        ("Personal", .cyan, "person.fill", [
            ReminderItem("Clean apartment", true, nil),
            ReminderItem("Read 'Swift in Depth'", false, nil),
            ReminderItem("Plan weekend trip", false, nil),
        ]),
        ("Work", .green, "briefcase.fill", [
            ReminderItem("Sprint planning", false, "Monday"),
            ReminderItem("Code review for PR #42", true, nil),
            ReminderItem("Update Jira tickets", false, nil),
            ReminderItem("Prepare demo", false, "Friday"),
        ]),
    ]

    var body: some View {
        HStack(spacing: 0) {
            sidebar.frame(width: 130)
            Divider()
            reminderContent
        }
        .onAppear { windowState.title = "Reminders" }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 0) {
            // Smart lists (top cards)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    smartListCard(i)
                }
            }
            .padding(6)

            Divider()

            // My Lists
            VStack(alignment: .leading, spacing: 0) {
                Text("My Lists")
                    .font(.system(size: 7, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)

                ForEach(4..<lists.count, id: \.self) { i in
                    listRow(i)
                }
            }
            Spacer()
        }
        .background(Color(white: 0.96))
    }

    private func smartListCard(_ i: Int) -> some View {
        Button { selectedList = i } label: {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: lists[i].2)
                        .font(.system(size: 10))
                        .foregroundStyle(lists[i].1)
                    Spacer()
                    Text("\(lists[i].3.count)")
                        .font(.system(size: 10, weight: .bold))
                }
                Text(lists[i].0)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(5)
            .background(selectedList == i ? lists[i].1.opacity(0.1) : Color(white: 0.99))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(white: 0.88), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func listRow(_ i: Int) -> some View {
        Button { selectedList = i } label: {
            HStack(spacing: 4) {
                Circle()
                    .fill(lists[i].1)
                    .frame(width: 8, height: 8)
                Text(lists[i].0)
                    .font(.system(size: 8))
                Spacer()
                Text("\(lists[i].3.count)")
                    .font(.system(size: 7))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(selectedList == i ? Color.blue.opacity(0.1) : .clear)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
    }

    // MARK: - Content

    private var reminderContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(lists[selectedList].0)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(lists[selectedList].1)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)

            Divider()

            // Reminder items
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(lists[selectedList].3.enumerated()), id: \.offset) { _, item in
                        reminderRow(item)
                    }
                }
            }

            Spacer()

            // Add button
            HStack(spacing: 3) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(lists[selectedList].1)
                Text("Add Reminder")
                    .font(.system(size: 8))
                    .foregroundStyle(lists[selectedList].1)
            }
            .padding(8)
        }
    }

    private func reminderRow(_ item: ReminderItem) -> some View {
        HStack(spacing: 5) {
            Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 10))
                .foregroundStyle(item.done ? .blue : Color(white: 0.7))

            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .font(.system(size: 8))
                    .strikethrough(item.done)
                    .foregroundStyle(item.done ? .secondary : .primary)
                if let time = item.time {
                    Text(time)
                        .font(.system(size: 6.5))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
    }
}

private struct ReminderItem {
    let title: String
    let done: Bool
    let time: String?
    init(_ title: String, _ done: Bool, _ time: String?) {
        self.title = title; self.done = done; self.time = time
    }
}
