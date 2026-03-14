import SwiftUI

@main
struct AppForegronderApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("AppForegronder", systemImage: menuBarIcon) {
            MenuBarView(appState: appState)
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarIcon: String {
        if !appState.accessibilityGranted {
            return "exclamationmark.triangle"
        }
        return appState.isActive ? "arrow.up.forward.app.fill" : "arrow.up.forward.app"
    }
}
