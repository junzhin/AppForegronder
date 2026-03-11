import SwiftUI

@main
struct AppForegronderApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("AppForegronder", systemImage: "arrow.up.forward.app") {
            MenuBarView(appState: appState)
        }
        .menuBarExtraStyle(.window)
    }
}
