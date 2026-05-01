import SwiftUI

@main
struct MacFakeApp: App {
    @State private var windowManager = WindowManager()
    @State private var wallpaperManager = WallpaperManager()
    @State private var bootComplete = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if bootComplete {
                    DesktopView()
                        .environment(windowManager)
                        .environment(wallpaperManager)
                        .transition(.opacity)
                } else {
                    BootScreen(bootComplete: $bootComplete)
                }
            }
            .persistentSystemOverlays(.hidden)
            .statusBarHidden(true)
            .preferredColorScheme(.light)
            .animation(.easeInOut(duration: 0.5), value: bootComplete)
        }
    }
}
