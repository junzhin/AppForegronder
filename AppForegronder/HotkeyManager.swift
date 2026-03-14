import AppKit

final class HotkeyManager {

    private var globalMonitor: Any?
    private var localMonitor: Any?
    var onTrigger: (() -> Void)?

    // 默认快捷键：⌘⇧F
    var modifiers: NSEvent.ModifierFlags = [.command, .shift]
    var keyCode: UInt16 = 3  // 'F' key

    // MARK: - Public Interface

    func start() {
        stop()

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleEvent(event)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleEvent(event)
            return event
        }
    }

    func stop() {
        if let m = globalMonitor { NSEvent.removeMonitor(m) }
        if let m = localMonitor { NSEvent.removeMonitor(m) }
        globalMonitor = nil
        localMonitor = nil
    }

    // MARK: - Private

    private func handleEvent(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags == modifiers && event.keyCode == keyCode {
            onTrigger?()
        }
    }

    deinit {
        stop()
    }
}
