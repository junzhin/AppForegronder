import Foundation
import Combine
import ServiceManagement

class AppState: ObservableObject {

    struct AppInfo: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let bundleID: String
    }

    // MARK: - Published Properties

    @Published var runningApps: [AppInfo] = []

    @Published var selectedBundleID: String? {
        didSet { UserDefaults.standard.set(selectedBundleID, forKey: Keys.selectedBundleID) }
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

    @Published var lockThresholdHours: Double {
        didSet { UserDefaults.standard.set(lockThresholdHours, forKey: Keys.lockThresholdHours) }
    }

    @Published var repeatCount: Int {
        didSet { UserDefaults.standard.set(repeatCount, forKey: Keys.repeatCount) }
    }

    @Published var launchAtLogin: Bool = false {
        didSet { updateLaunchAtLogin() }
    }

    @Published var language: Language = .zh {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Keys.language) }
    }

    var l10n: L10n { L10n(lang: language) }

    @Published var isActive: Bool = false

    // MARK: - Private

    private enum Keys {
        static let selectedBundleID   = "selectedBundleID"
        static let unlockEnabled      = "unlockEnabled"
        static let timerEnabled       = "timerEnabled"
        static let timerInterval      = "timerInterval"
        static let smartUnlockEnabled = "smartUnlockEnabled"
        static let lockThresholdHours = "lockThresholdHours"
        static let repeatCount        = "repeatCount"
        static let language           = "language"
    }

    private let activator = AppActivator()
    private var lockObserver: ScreenLockObserver?
    private var timerManager: TimerManager?

    // MARK: - Init

    init() {
        let defaults = UserDefaults.standard
        self.selectedBundleID   = defaults.string(forKey: Keys.selectedBundleID)
        self.unlockEnabled      = defaults.object(forKey: Keys.unlockEnabled) as? Bool ?? false
        self.timerEnabled       = defaults.object(forKey: Keys.timerEnabled)  as? Bool ?? false
        self.timerInterval      = defaults.object(forKey: Keys.timerInterval) as? Double ?? 5.0
        self.smartUnlockEnabled = defaults.object(forKey: Keys.smartUnlockEnabled) as? Bool ?? false
        self.lockThresholdHours = defaults.object(forKey: Keys.lockThresholdHours) as? Double ?? 1.0
        self.repeatCount        = defaults.object(forKey: Keys.repeatCount) as? Int ?? 5

        if let langStr = defaults.string(forKey: Keys.language),
           let lang = Language(rawValue: langStr) {
            self.language = lang
        }

        if #available(macOS 13.0, *) {
            self.launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }

        refreshRunningApps()
    }

    // MARK: - Public Methods

    func refreshRunningApps() {
        let raw = activator.getRunningApps()
        runningApps = raw.map { AppInfo(name: $0.name, bundleID: $0.bundleID) }
    }

    func start() {
        guard !isActive else { return }

        if unlockEnabled {
            let observer = ScreenLockObserver()
            observer.onUnlock = { [weak self] lockDuration in
                guard let self = self else { return }
                if self.smartUnlockEnabled {
                    let thresholdSeconds = self.lockThresholdHours * 3600
                    if lockDuration >= thresholdSeconds {
                        self.repeatBringToFront()
                    }
                } else {
                    self.bringToFront()
                }
            }
            observer.start()
            lockObserver = observer
        }

        if timerEnabled {
            let manager = TimerManager()
            manager.start(intervalMinutes: timerInterval) { [weak self] in
                self?.bringToFront()
            }
            timerManager = manager
        }

        isActive = true
    }

    func stop() {
        lockObserver?.stop()
        lockObserver = nil
        timerManager?.stop()
        timerManager = nil
        isActive = false
    }

    func bringToFront() {
        guard let bundleID = selectedBundleID else { return }
        activator.activate(bundleID: bundleID)
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

    // MARK: - Private Methods

    private func repeatBringToFront() {
        let count = repeatCount
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 2.0) { [weak self] in
                self?.bringToFront()
            }
        }
    }
}
