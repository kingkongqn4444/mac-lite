import SwiftUI

struct ClockView: View {
    let windowState: WindowState
    @State private var selectedTab = "World Clock"
    @State private var currentTime = Date()
    @State private var stopwatchRunning = false
    @State private var stopwatchTime: TimeInterval = 0
    @State private var timerValue: TimeInterval = 300 // 5 min default
    @State private var timerRunning = false

    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(["World Clock", "Stopwatch", "Timer"], id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Text(tab)
                            .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(selectedTab == tab ? Color.accentColor.opacity(0.15) : .clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(white: 0.97))

            Divider()

            switch selectedTab {
            case "World Clock": worldClockView
            case "Stopwatch": stopwatchView
            case "Timer": timerView
            default: EmptyView()
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
            if stopwatchRunning { stopwatchTime += 0.01 }
            if timerRunning {
                timerValue = max(0, timerValue - 0.01)
                if timerValue <= 0 { timerRunning = false }
            }
        }
        .onAppear { windowState.title = "Clock" }
    }

    // MARK: - World Clock

    private var worldClockView: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(worldClocks, id: \.city) { clock in
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(clock.city)
                                .font(.system(size: 11, weight: .medium))
                            Text(clock.offset)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(timeIn(zone: clock.timezone))
                            .font(.system(size: 20, weight: .light, design: .rounded))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
            .padding(.top, 8)
        }
    }

    private struct WorldClock {
        let city: String
        let timezone: String
        let offset: String
    }

    private var worldClocks: [WorldClock] {
        [
            WorldClock(city: "Ho Chi Minh City", timezone: "Asia/Ho_Chi_Minh", offset: "ICT (UTC+7)"),
            WorldClock(city: "Tokyo", timezone: "Asia/Tokyo", offset: "JST (UTC+9)"),
            WorldClock(city: "London", timezone: "Europe/London", offset: "GMT (UTC+0)"),
            WorldClock(city: "New York", timezone: "America/New_York", offset: "EST (UTC-5)"),
            WorldClock(city: "San Francisco", timezone: "America/Los_Angeles", offset: "PST (UTC-8)"),
        ]
    }

    private func timeIn(zone: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = TimeZone(identifier: zone)
        return f.string(from: currentTime)
    }

    // MARK: - Stopwatch

    private var stopwatchView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(formatStopwatch(stopwatchTime))
                .font(.system(size: 36, weight: .light, design: .monospaced))

            HStack(spacing: 20) {
                Button {
                    stopwatchTime = 0
                    stopwatchRunning = false
                } label: {
                    Text("Reset")
                        .font(.system(size: 11))
                        .frame(width: 60, height: 28)
                        .background(Circle().fill(Color(white: 0.9)))
                }

                Button {
                    stopwatchRunning.toggle()
                } label: {
                    Text(stopwatchRunning ? "Stop" : "Start")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 28)
                        .background(Circle().fill(stopwatchRunning ? .red : .green))
                }
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    private func formatStopwatch(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        let cents = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", mins, secs, cents)
    }

    // MARK: - Timer

    private var timerView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(formatTimer(timerValue))
                .font(.system(size: 36, weight: .light, design: .monospaced))
                .foregroundStyle(timerValue <= 10 && timerRunning ? .red : .primary)

            HStack(spacing: 20) {
                Button {
                    timerValue = 300
                    timerRunning = false
                } label: {
                    Text("Reset")
                        .font(.system(size: 11))
                        .frame(width: 60, height: 28)
                        .background(Circle().fill(Color(white: 0.9)))
                }

                Button {
                    timerRunning.toggle()
                } label: {
                    Text(timerRunning ? "Pause" : "Start")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 28)
                        .background(Circle().fill(timerRunning ? .orange : .green))
                }
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    private func formatTimer(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
