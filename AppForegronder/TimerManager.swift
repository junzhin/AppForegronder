import Foundation

final class TimerManager {

    private var timer: Timer?

    // MARK: - Public Interface

    func start(intervalMinutes: Double, action: @escaping () -> Void) {
        guard intervalMinutes > 0 else {
            NSLog("TimerManager: intervalMinutes must be positive, got %f", intervalMinutes)
            return
        }

        stop()

        let interval = intervalMinutes * 60.0
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            action()
        }

        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Lifecycle

    deinit {
        stop()
    }
}
