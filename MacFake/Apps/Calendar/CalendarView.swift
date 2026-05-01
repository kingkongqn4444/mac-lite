import SwiftUI
import EventKit

struct CalendarAppView: View {
    let windowState: WindowState
    @State private var selectedDate = Date()
    @State private var events: [EKEvent] = []
    @State private var authorized = false
    private let store = EKEventStore()
    private let calendar = Calendar.current

    var body: some View {
        HStack(spacing: 0) {
            // Mini calendar (left)
            VStack(spacing: 8) {
                // Month header
                HStack {
                    Button { changeMonth(-1) } label: {
                        Image(systemName: "chevron.left").font(.system(size: 9))
                    }
                    Spacer()
                    Text(monthYearString)
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Button { changeMonth(1) } label: {
                        Image(systemName: "chevron.right").font(.system(size: 9))
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)

                // Day headers
                HStack(spacing: 0) {
                    ForEach(["S","M","T","W","T","F","S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Day grid
                let days = daysInMonth()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 2) {
                    ForEach(days, id: \.self) { day in
                        if day == 0 {
                            Text("").frame(height: 18)
                        } else {
                            Text("\(day)")
                                .font(.system(size: 9))
                                .frame(width: 18, height: 18)
                                .background(
                                    Circle()
                                        .fill(isToday(day) ? .red : .clear)
                                )
                                .foregroundStyle(isToday(day) ? .white : .primary)
                                .onTapGesture {
                                    selectDay(day)
                                }
                        }
                    }
                }

                Spacer()
            }
            .frame(width: 160)
            .padding(.top, 8)
            .background(MacColors.sidebarBackground)

            Divider()

            // Events list (right)
            VStack(alignment: .leading, spacing: 0) {
                Text(dateString)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(8)

                Divider()

                if !authorized {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                        Text("Calendar Access Required")
                            .font(.system(size: 11))
                        Button("Allow") { requestAccess() }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if events.isEmpty {
                    VStack {
                        Spacer()
                        Text("No Events")
                            .font(MacFonts.body)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(events, id: \.eventIdentifier) { event in
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(cgColor: event.calendar.cgColor))
                                        .frame(width: 3, height: 24)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(event.title)
                                            .font(.system(size: 10, weight: .medium))
                                            .lineLimit(1)
                                        Text(eventTimeString(event))
                                            .font(.system(size: 8))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            windowState.title = "Calendar"
            requestAccess()
        }
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: selectedDate)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: selectedDate)
    }

    private func eventTimeString(_ event: EKEvent) -> String {
        if event.isAllDay { return "All Day" }
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return "\(f.string(from: event.startDate)) - \(f.string(from: event.endDate))"
    }

    private func isToday(_ day: Int) -> Bool {
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let todayComps = calendar.dateComponents([.year, .month, .day], from: Date())
        return comps.year == todayComps.year && comps.month == todayComps.month && day == todayComps.day
    }

    private func daysInMonth() -> [Int] {
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let firstDay = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }
        let weekday = calendar.component(.weekday, from: firstDay) - 1
        return Array(repeating: 0, count: weekday) + Array(range)
    }

    private func selectDay(_ day: Int) {
        var comps = calendar.dateComponents([.year, .month], from: selectedDate)
        comps.day = day
        if let date = calendar.date(from: comps) {
            selectedDate = date
            loadEvents()
        }
    }

    private func changeMonth(_ delta: Int) {
        if let date = calendar.date(byAdding: .month, value: delta, to: selectedDate) {
            selectedDate = date
            loadEvents()
        }
    }

    private func requestAccess() {
        store.requestFullAccessToEvents { granted, _ in
            DispatchQueue.main.async {
                authorized = granted
                if granted { loadEvents() }
            }
        }
    }

    private func loadEvents() {
        let start = calendar.startOfDay(for: selectedDate)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        events = store.events(matching: predicate).sorted { $0.startDate < $1.startDate }
    }
}
