import Foundation
import Combine
import ServiceManagement

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let appName: String
    let trigger: String
    let success: Bool
}

class AppState: ObservableObject {

    struct AppInfo: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let bundleID: String
    }

    // MARK: - Published Properties

    @Published var runningApps: [AppInfo] = []

    @Published var selectedBundleIDs: [String] {
        didSet { UserDefaults.standard.set(selectedBundleIDs, forKey: Keys.selectedBundleIDs) }
    }

    @Published var unlockEnabled: Bool {
        didSet { UserDefaults.standard.set(unlockEnabled, forKey: Keys.unlockEnabled) }
    }

    @Published var timerEnabled: Bool {
        didSet { UserDefaults.standard.set(timerEnabled, forKey: Keys.timerEnabled) }
    }

    @Published var timerInterval: Double {
        didSet { UserDefaults.standard.set(timerInterval, forKey: Keys.timerInterval) }
    }

    @Published var smartUnlockEnabled: Bool {
        didSet { UserDefaults.standard.set(smartUnlockEnabled, forKey: Keys.smartUnlockEnabled) }
    }

    @Published var lockThresholdMinutes: Double {
        didSet { UserDefaults.standard.set(lockThresholdMinutes, forKey: Keys.lockThresholdMinutes) }
    }

    @Published var hotkeyEnabled: Bool {
        didSet { UserDefaults.standard.set(hotkeyEnabled, forKey: Keys.hotkeyEnabled) }
    }

    @Published var launchAtLogin: Bool = false {
        didSet { updateLaunchAtLogin() }
    }

    @Published var language: Language = .zh {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Keys.language) }
    }

    var l10n: L10n { L10n(lang: language) }

    @Published var isActive: Bool = false
    @Published var accessibilityGranted: Bool = false
    @Published var recentLogs: [LogEntry] = []

    // MARK: - Private

    private enum Keys {
        static let selectedBundleIDs    = "selectedBundleIDs"
        static let unlockEnabled        = "unlockEnabled"
        static let timerEnabled         = "timerEnabled"
        static let timerInterval        = "timerInterval"
        static let smartUnlockEnabled   = "smartUnlockEnabled"
        static let lockThresholdMinutes = "lockThresholdMinutes"
        static let hotkeyEnabled        = "hotkeyEnabled"
        static let language             = "language"
    }

    private let activator = AppActivator()
    private var lockObserver: ScreenLockObserver?
    private var timerManager: TimerManager?
    private var hotkeyManager: HotkeyManager?
    private let maxLogCount = 50

    // MARK: - Init

    init() {
        let defaults = UserDefaults.standard
        self.selectedBundleIDs    = defaults.object(forKey: Keys.selectedBundleIDs) as? [String] ?? []
        self.unlockEnabled        = defaults.object(forKey: Keys.unlockEnabled) as? Bool ?? false
        self.timerEnabled         = defaults.object(forKey: Keys.timerEnabled)  as? Bool ?? false
        self.timerInterval        = defaults.object(forKey: Keys.timerInterval) as? Double ?? 5.0
        self.smartUnlockEnabled   = defaults.object(forKey: Keys.smartUnlockEnabled) as? Bool ?? false
        self.lockThresholdMinutes = defaults.object(forKey: Keys.lockThresholdMinutes) as? Double ?? 30.0
        self.hotkeyEnabled        = defaults.object(forKey: Keys.hotkeyEnabled) as? Bool ?? false

        if let langStr = defaults.string(forKey: Keys.language),
           let lang = Language(rawValue: langStr) {
            self.language = lang
        }

        if #available(macOS 13.0, *) {
            self.launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }

        self.accessibilityGranted = AccessibilityChecker.isTrusted
        refreshRunningApps()
    }

    // MARK: - Public Methods

    func refreshRunningApps() {
        let raw = activator.getRunningApps()
        runningApps = raw.map { AppInfo(name: $0.name, bundleID: $0.bundleID) }
    }

    func toggleApp(_ bundleID: String) {
        if let idx = selectedBundleIDs.firstIndex(of: bundleID) {
            selectedBundleIDs.remove(at: idx)
        } else {
            selectedBundleIDs.append(bundleID)
        }
    }

    func start() {
        guard !isActive else { return }

        accessibilityGranted = AccessibilityChecker.isTrusted

        if unlockEnabled {
            let observer = ScreenLockObserver()
            observer.onUnlock = { [weak self] lockDuration in
                guard let self = self else { return }
                if self.smartUnlockEnabled {
                    let thresholdSeconds = self.lockThresholdMinutes * 60
                    if lockDuration >= thresholdSeconds {
                        self.bringToFront(trigger: "unlock")
                    }
                } else {
                    self.bringToFront(trigger: "unlock")
                }
            }
            observer.start()
            lockObserver = observer
        }

        if timerEnabled {
            let manager = TimerManager()
            manager.start(intervalMinutes: timerInterval) { [weak self] in
                self?.bringToFront(trigger: "timer")
            }
            timerManager = manager
        }

        if hotkeyEnabled {
            let hk = HotkeyManager()
            hk.onTrigger = { [weak self] in
                self?.bringToFront(trigger: "hotkey")
            }
            hk.start()
            hotkeyManager = hk
        }

        isActive = true
    }

    func stop() {
        lockObserver?.stop()
        lockObserver = nil
        timerManager?.stop()
        timerManager = nil
        hotkeyManager?.stop()
        hotkeyManager = nil
        isActive = false
    }

    func bringToFront(trigger: String = "manual") {
        for bundleID in selectedBundleIDs {
            let success = activator.activate(bundleID: bundleID)
            let appName = runningApps.first { $0.bundleID == bundleID }?.name ?? bundleID
            let entry = LogEntry(timestamp: Date(), appName: appName, trigger: trigger, success: success)
            recentLogs.insert(entry, at: 0)
            if recentLogs.count > maxLogCount { recentLogs.removeLast() }
        }
    }

    func checkAccessibility() {
        accessibilityGranted = AccessibilityChecker.isTrusted
    }

    // MARK: - Launch At Login

    private func updateLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                NSLog("LaunchAtLogin error: %@", error.localizedDescription)
            }
        }
    }
}
