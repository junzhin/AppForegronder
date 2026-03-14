import SwiftUI

struct MenuBarView: View {

    @ObservedObject var appState: AppState

    private var t: L10n { appState.l10n }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            accessibilityWarning
            appPickerSection
            Divider()
            toggleSection
            Divider()
            actionSection
            Divider()
            logSection
            Divider()
            footerSection
        }
        .padding(16)
        .frame(width: 320)
    }

    // MARK: - Accessibility Warning

    @ViewBuilder
    private var accessibilityWarning: some View {
        if !appState.accessibilityGranted {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text(t.accessibilityWarning)
                    .font(.caption)
                Spacer()
                Button(t.goToSettings) {
                    AccessibilityChecker.openSettings()
                }
                .controlSize(.small)
                .buttonStyle(.bordered)
            }
            .padding(8)
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(6)

            Divider()
        }
    }

    // MARK: - Sections

    private var appPickerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(t.targetApp)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if !appState.selectedBundleIDs.isEmpty {
                    Text("\(appState.selectedBundleIDs.count) \(t.selectedApps)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            VStack(spacing: 2) {
                ForEach(appState.runningApps) { app in
                    let isSelected = appState.selectedBundleIDs.contains(app.bundleID)
                    Button(action: {
                        appState.toggleApp(app.bundleID)
                    }) {
                        HStack {
                            Image(systemName: isSelected
                                  ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? .accentColor : .secondary)
                                .font(.system(size: 14))
                            Text(app.name)
                                .font(.system(size: 13))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            isSelected
                                ? Color.accentColor.opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var toggleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Toggle(t.unlockToggle, isOn: $appState.unlockEnabled)
                helpButton(t.helpUnlock)
            }

            if appState.unlockEnabled {
                HStack {
                    Toggle(t.smartUnlock, isOn: $appState.smartUnlockEnabled)
                    helpButton(t.helpSmartUnlock)
                }
                .padding(.leading, 16)

                if appState.smartUnlockEnabled {
                    HStack {
                        Text(t.lockThreshold)
                            .foregroundColor(.secondary)
                        helpButton(t.helpThreshold)
                        Spacer()
                        Stepper(
                            "\(Int(appState.lockThresholdMinutes)) \(t.minutes)",
                            value: $appState.lockThresholdMinutes,
                            in: 1...120,
                            step: 1
                        )
                    }
                    .padding(.leading, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            HStack {
                Toggle(t.timerToggle, isOn: $appState.timerEnabled)
                helpButton(t.helpTimer)
            }

            if appState.timerEnabled {
                HStack {
                    Text(t.interval)
                        .foregroundColor(.secondary)
                    Spacer()
                    Stepper(
                        "\(Int(appState.timerInterval)) \(t.minutes)",
                        value: $appState.timerInterval,
                        in: 1...999,
                        step: 1
                    )
                }
                .padding(.leading, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            HStack {
                Toggle(t.hotkeyToggle, isOn: $appState.hotkeyEnabled)
                helpButton(t.helpHotkey)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appState.timerEnabled)
        .animation(.easeInOut(duration: 0.2), value: appState.unlockEnabled)
        .animation(.easeInOut(duration: 0.2), value: appState.smartUnlockEnabled)
    }

    private var actionSection: some View {
        VStack(spacing: 8) {
            Button(action: toggleActive) {
                Text(appState.isActive ? t.stop : t.start)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(appState.isActive ? .red : .accentColor)
            .disabled(appState.selectedBundleIDs.isEmpty)

            Button(action: { appState.bringToFront() }) {
                Text(t.foregroundNow)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.bordered)
            .disabled(appState.selectedBundleIDs.isEmpty)
        }
    }

    private var logSection: some View {
        DisclosureGroup(t.recentLogs) {
            if appState.recentLogs.isEmpty {
                Text(t.noLogs)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 4) {
                    ForEach(appState.recentLogs.prefix(10)) { log in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(log.success ? Color.green : Color.red)
                                .frame(width: 6, height: 6)
                            Text(log.appName)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text(triggerLabel(log.trigger))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(formatTime(log.timestamp))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .font(.caption)
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Toggle(t.launchAtLogin, isOn: $appState.launchAtLogin)
                    .font(.caption)
                Spacer()
                Button(appState.language == .zh ? "EN" : "中") {
                    appState.language = appState.language == .zh ? .en : .zh
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            HStack {
                Button(t.refreshApps) {
                    appState.refreshRunningApps()
                    appState.checkAccessibility()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Spacer()

                Button(t.quit) {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .font(.caption)
        }
    }

    // MARK: - Helpers

    private func helpButton(_ text: String) -> some View {
        HelpBadge(text: text)
    }

    private func toggleActive() {
        if appState.isActive {
            appState.stop()
        } else {
            appState.start()
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private func triggerLabel(_ trigger: String) -> String {
        let lang = appState.language
        switch trigger {
        case "unlock": return lang == .zh ? "解锁" : "unlock"
        case "timer": return lang == .zh ? "定时" : "timer"
        case "hotkey": return lang == .zh ? "快捷键" : "hotkey"
        case "manual": return lang == .zh ? "手动" : "manual"
        default: return trigger
        }
    }
}

struct HelpBadge: View {
    let text: String
    @State private var showing = false

    var body: some View {
        Text("?")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 16, height: 16)
            .background(Color.secondary.opacity(0.6))
            .clipShape(Circle())
            .onTapGesture { showing.toggle() }
            .popover(isPresented: $showing, arrowEdge: .trailing) {
                Text(text)
                    .font(.caption)
                    .padding(10)
                    .frame(width: 200)
                    .fixedSize(horizontal: false, vertical: true)
            }
    }
}
