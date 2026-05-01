import SwiftUI

struct BatteryDropdownView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Battery")
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 12).padding(.vertical, 6)

            Divider().padding(.horizontal, 8)

            // Battery info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "battery.100.bolt")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("\(batteryPercent)%")
                            .font(.system(size: 14, weight: .medium))
                        Text(batteryStatus)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }

                // Battery bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(white: 0.85))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.green)
                            .frame(width: geo.size.width * CGFloat(batteryLevel))
                    }
                }
                .frame(height: 6)

                Divider()

                HStack {
                    Text("Power Source")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(powerSource)
                        .font(.system(size: 10))
                }
            }
            .padding(12)
        }
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
        .onAppear { UIDevice.current.isBatteryMonitoringEnabled = true }
    }

    private var batteryLevel: Float {
        let level = UIDevice.current.batteryLevel
        return level >= 0 ? level : 1.0
    }

    private var batteryPercent: Int {
        Int(batteryLevel * 100)
    }

    private var batteryStatus: String {
        switch UIDevice.current.batteryState {
        case .charging: return "Charging"
        case .full: return "Fully Charged"
        case .unplugged: return "On Battery"
        default: return "Unknown"
        }
    }

    private var powerSource: String {
        switch UIDevice.current.batteryState {
        case .charging, .full: return "Power Adapter"
        case .unplugged: return "Battery"
        default: return "Unknown"
        }
    }
}
