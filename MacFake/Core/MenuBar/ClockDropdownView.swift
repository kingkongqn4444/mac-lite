import SwiftUI

struct ClockDropdownView: View {
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let calendar = Calendar.current

    private let notifications: [FakeNotification] = [
        FakeNotification(app: "iCloud", icon: "icloud.fill", iconColor: .blue,
                        title: "Some iCloud Data Isn't Syncing",
                        body: "Passwords and data from Health can't be accessed on this device.", time: "5m"),
        FakeNotification(app: "Finder", icon: "externaldrive.fill", iconColor: .orange,
                        title: "Disk Not Ejected Properly",
                        body: "Eject \"ssd\" before disconnecting or turning it off.", time: "9m"),
        FakeNotification(app: "Software Update", icon: "gear.badge", iconColor: .gray,
                        title: "macOS Update Available",
                        body: "macOS Sequoia 15.4.1 is available.", time: "1h"),
        FakeNotification(app: "Messages", icon: "message.fill", iconColor: .green,
                        title: "New message",
                        body: "Hey! Are you available for a call?", time: "2h"),
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                // Notification cards
                ForEach(notifications) { notif in
                    notificationCard(notif)
                }

                // Notification Center header
                HStack {
                    Text("Notification Center")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(notifications.count) Notifications")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 4)
                .padding(.top, 2)

                // Calendar + Clock widget
                calendarWidget
            }
            .padding(10)
        }
        .frame(width: 300)
        .frame(maxHeight: 340)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.4), radius: 16, y: 6)
        .onReceive(timer) { now = $0 }
    }

    // MARK: - Notification Card (dark style)

    @ViewBuilder
    private func notificationCard(_ notif: FakeNotification) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // App icon
            Image(systemName: notif.icon)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(RoundedRectangle(cornerRadius: 7).fill(notif.iconColor.gradient))

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .top) {
                    Text(notif.title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(notif.time)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Text(notif.body)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.12))
        )
    }

    // MARK: - Calendar Widget

    private var calendarWidget: some View {
        VStack(spacing: 6) {
            // Header: month + time
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(dayOfWeek)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.5))
                    Text(monthYear)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Text(timeString)
                    .font(.system(size: 22, weight: .light, design: .rounded))
                    .foregroundStyle(.white)
            }

            // Day headers
            HStack(spacing: 0) {
                ForEach(["S","M","T","W","T","F","S"], id: \.self) { d in
                    Text(d)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 2) {
                ForEach(daysInMonth(), id: \.self) { day in
                    if day == 0 {
                        Text("").frame(height: 18)
                    } else {
                        Text("\(day)")
                            .font(.system(size: 10))
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(isToday(day) ? .red : .clear))
                            .foregroundStyle(isToday(day) ? .white : .white.opacity(0.8))
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.12))
        )
    }

    // MARK: - Helpers

    private var dayOfWeek: String {
        let f = DateFormatter(); f.dateFormat = "EEEE"; return f.string(from: now)
    }
    private var monthYear: String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f.string(from: now)
    }
    private var timeString: String {
        let f = DateFormatter(); f.dateFormat = "h:mm a"; return f.string(from: now)
    }
    private func isToday(_ day: Int) -> Bool {
        calendar.component(.day, from: now) == day
    }
    private func daysInMonth() -> [Int] {
        let comps = calendar.dateComponents([.year, .month], from: now)
        guard let firstDay = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }
        let weekday = calendar.component(.weekday, from: firstDay) - 1
        return Array(repeating: 0, count: weekday) + Array(range)
    }
}

struct FakeNotification: Identifiable {
    let id = UUID()
    let app: String
    let icon: String
    let iconColor: Color
    let title: String
    let body: String
    let time: String
}
