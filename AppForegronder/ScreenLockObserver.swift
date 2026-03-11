import Foundation

final class ScreenLockObserver {

    var onUnlock: ((TimeInterval) -> Void)?

    private var lockObserverToken: NSObjectProtocol?
    private var unlockObserverToken: NSObjectProtocol?
    private var pendingWorkItem: DispatchWorkItem?
    private let unlockDelay: TimeInterval = 1.5
    private var lockTime: Date?

    // MARK: - Lifecycle

    deinit {
        stop()
    }

    // MARK: - Public Interface

    func start() {
        guard unlockObserverToken == nil else { return }

        let center = DistributedNotificationCenter.default()

        lockObserverToken = center.addObserver(
            forName: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.lockTime = Date()
        }

        unlockObserverToken = center.addObserver(
            forName: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleUnlock()
        }
    }

    func stop() {
        let center = DistributedNotificationCenter.default()
        if let token = lockObserverToken {
            center.removeObserver(token)
            lockObserverToken = nil
        }
        if let token = unlockObserverToken {
            center.removeObserver(token)
            unlockObserverToken = nil
        }
        cancelPending()
        lockTime = nil
    }

    // MARK: - Private

    private func handleUnlock() {
        cancelPending()

        let duration: TimeInterval
        if let lockTime = lockTime {
            duration = Date().timeIntervalSince(lockTime)
        } else {
            duration = 0
        }
        lockTime = nil

        let workItem = DispatchWorkItem { [weak self] in
            self?.onUnlock?(duration)
        }
        pendingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + unlockDelay, execute: workItem)
    }

    private func cancelPending() {
        pendingWorkItem?.cancel()
        pendingWorkItem = nil
    }
}
