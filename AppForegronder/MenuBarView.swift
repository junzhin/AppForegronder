import SwiftUI

struct MenuBarView: View {

    @ObservedObject var appState: AppState

    private var t: L10n { appState.l10n }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            appPickerSection
            Divider()
            toggleSection
            Divider()
            actionSection
            Divider()
            footerSection
        }
        .padding(16)
        .frame(width: 300)
    }

    // MARK: - Sections

    private var appPickerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(t.targetApp)
                .font(.caption)
                .foregroundColor(.secondary)

            Picker(t.selectApp, selection: $appState.selectedBundleID) {
                Text(t.selectApp).tag(String?.none)
                ForEach(appState.runningApps) { app in
                    Text(app.name).tag(Optional(app.bundleID))
                }
            }
            .labelsHidden()
            .frame(maxWidth: .infinity)
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
                    VStack(spacing: 4) {
                        HStack {
                            Text(t.lockThreshold)
                                .foregroundColor(.secondary)
                            helpButton(t.helpThreshold)
                            Spacer()
                            Stepper(
                                String(format: "%.1f \(t.hours)", appState.lockThresholdHours),
                                value: $appState.lockThresholdHours,
                                in: 0.5...4.0,
                                step: 0.5
                            )
                        }
                        HStack {
                            Text(t.repeatForeground)
                                .foregroundColor(.secondary)
                            helpButton(t.helpRepeat)
                            Spacer()
                            Stepper(
                                "\(appState.repeatCount) \(t.times)",
                                value: $appState.repeatCount,
                                in: 1...10,
                                step: 1
                            )
                        }
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
                        in: 1...60,
                        step: 1
                    )
                }
                .padding(.leading, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
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
            .disabled(appState.selectedBundleID == nil)

            Button(action: { appState.bringToFront() }) {
                Text(t.foregroundNow)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.bordered)
            .disabled(appState.selectedBundleID == nil)
        }
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
