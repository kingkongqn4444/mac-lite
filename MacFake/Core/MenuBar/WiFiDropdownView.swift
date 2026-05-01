import SwiftUI
import NetworkExtension

@Observable
final class WiFiManager {
    var currentSSID: String = "Loading..."
    var isWiFiOn = true

    // Fake nearby networks
    let fakeNetworks: [WiFiNetwork] = [
        WiFiNetwork(name: "VNPT_5G_Home", strength: 3, isSecured: true),
        WiFiNetwork(name: "FPT_Telecom", strength: 2, isSecured: true),
        WiFiNetwork(name: "Viettel_4F", strength: 2, isSecured: true),
        WiFiNetwork(name: "Coffee Shop Free WiFi", strength: 1, isSecured: false),
        WiFiNetwork(name: "iPhone của Thịnh", strength: 1, isSecured: true),
        WiFiNetwork(name: "Galaxy_Hotspot", strength: 1, isSecured: true),
    ]

    init() {
        fetchCurrentSSID()
    }

    func fetchCurrentSSID() {
        NEHotspotNetwork.fetchCurrent { network in
            DispatchQueue.main.async {
                self.currentSSID = network?.ssid ?? "MacFake_WiFi"
            }
        }
    }

    struct WiFiNetwork: Identifiable {
        let id = UUID()
        let name: String
        let strength: Int // 1-3 bars
        let isSecured: Bool
    }
}

struct WiFiDropdownView: View {
    @Binding var isShowing: Bool
    @State private var wifiManager = WiFiManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Wi-Fi")
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Toggle("", isOn: $wifiManager.isWiFiOn)
                    .labelsHidden()
                    .scaleEffect(0.7)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Divider().padding(.horizontal, 8)

            if wifiManager.isWiFiOn {
                // Connected network
                VStack(alignment: .leading, spacing: 0) {
                    Text("Known Networks")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.top, 6)
                        .padding(.bottom, 2)

                    wifiRow(
                        name: wifiManager.currentSSID,
                        strength: 3,
                        isSecured: true,
                        isConnected: true
                    )
                }

                Divider().padding(.horizontal, 8).padding(.vertical, 4)

                // Other networks
                VStack(alignment: .leading, spacing: 0) {
                    Text("Other Networks")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 2)

                    ForEach(wifiManager.fakeNetworks) { network in
                        wifiRow(
                            name: network.name,
                            strength: network.strength,
                            isSecured: network.isSecured,
                            isConnected: false
                        )
                    }
                }

                Divider().padding(.horizontal, 8).padding(.vertical, 4)

                // Footer
                Button {
                    isShowing = false
                } label: {
                    HStack {
                        Image(systemName: "gear")
                            .font(.system(size: 10))
                        Text("Network Settings...")
                            .font(.system(size: 11))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            } else {
                Text("Wi-Fi is turned off")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(12)
            }
        }
        .padding(.vertical, 6)
        .frame(width: 240)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private func wifiRow(name: String, strength: Int, isSecured: Bool, isConnected: Bool) -> some View {
        Button {
            if !isConnected {
                // Fake "connecting" — just dismiss
                isShowing = false
            }
        } label: {
            HStack(spacing: 6) {
                // Checkmark for connected
                Image(systemName: isConnected ? "checkmark" : "")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 14)
                    .foregroundStyle(.primary)

                Text(name)
                    .font(.system(size: 11))
                    .lineLimit(1)

                Spacer()

                if isSecured {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }

                // Signal strength icon
                Image(systemName: wifiIcon(strength: strength))
                    .font(.system(size: 11))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(MenuItemButtonStyle(isDisabled: false))
    }

    private func wifiIcon(strength: Int) -> String {
        switch strength {
        case 3: return "wifi"
        case 2: return "wifi"
        case 1: return "wifi"
        default: return "wifi.slash"
        }
    }
}
