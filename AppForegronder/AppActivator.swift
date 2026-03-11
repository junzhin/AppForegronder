import AppKit
import Foundation

final class AppActivator {

    // MARK: - Public Interface

    @discardableResult
    func activate(bundleID: String) -> Bool {
        guard !bundleID.isEmpty else { return false }

        if let app = runningApplication(bundleID: bundleID) {
            return bringToFront(app: app, identifier: app.localizedName ?? bundleID)
        }

        return launchViaAppleScript(identifier: bundleID)
    }

    @discardableResult
    func activate(appName: String) -> Bool {
        guard !appName.isEmpty else { return false }

        if let app = runningApplication(appName: appName) {
            return bringToFront(app: app, identifier: appName)
        }

        return launchViaAppleScript(identifier: appName)
    }

    func getRunningApps() -> [(name: String, bundleID: String)] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app in
                guard let name = app.localizedName,
                      let bundleID = app.bundleIdentifier else { return nil }
                return (name: name, bundleID: bundleID)
            }
    }

    // MARK: - Private Helpers

    private func runningApplication(bundleID: String) -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications
            .first { $0.bundleIdentifier == bundleID }
    }

    private func runningApplication(appName: String) -> NSRunningApplication? {
        let lowercased = appName.lowercased()
        return NSWorkspace.shared.runningApplications
            .first { ($0.localizedName ?? "").lowercased() == lowercased }
    }

    private func bringToFront(app: NSRunningApplication, identifier: String) -> Bool {
        if app.isHidden {
            app.unhide()
        }

        let scriptSuccess = appleScriptActivate(identifier: identifier)

        if !scriptSuccess {
            return app.activate(options: .activateIgnoringOtherApps)
        }

        return scriptSuccess
    }

    @discardableResult
    private func launchViaAppleScript(identifier: String) -> Bool {
        appleScriptActivate(identifier: identifier)
    }

    @discardableResult
    private func appleScriptActivate(identifier: String) -> Bool {
        let escaped = identifier.replacingOccurrences(of: "\"", with: "\\\"")
        let source = """
        tell application "\(escaped)"
            reopen
            activate
        end tell
        """
        var error: NSDictionary?
        let script = NSAppleScript(source: source)
        script?.executeAndReturnError(&error)

        if let err = error {
            NSLog("AppActivator: AppleScript error for '\(identifier)': %@", err)
            return false
        }
        return true
    }
}
