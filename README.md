<p align="center">
  <img src="AppForegronder/AppIcon.icns" width="128" height="128" alt="AppForegronder Icon">
</p>

<h1 align="center">AppForegronder</h1>

<p align="center">
  <b>macOS 菜单栏工具，自动将指定应用前置到最前面</b><br>
  <sub>A lightweight macOS menu bar utility that automatically brings your target app to the foreground</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-blue" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5-orange" alt="Swift">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
</p>

---

## Features

| Feature | Description |
|---------|-------------|
| **Auto Foreground on Unlock** | Automatically brings the target app to the foreground every time you unlock your Mac |
| **Smart Lock Trigger** | Only activates when lock duration exceeds a configurable threshold (e.g., 1 hour), with repeated foreground attempts |
| **Timed Foreground** | Periodically brings the target app to the foreground at a fixed interval, regardless of lock state |
| **Launch at Login** | Optionally start the app when you log in |
| **Bilingual UI** | Supports both Chinese and English, switchable at runtime |

## How It Works

```
Screen Lock ──► Record Lock Time
                    │
Screen Unlock ──► Calculate Duration
                    │
          ┌─────────┴─────────┐
          │                   │
    Duration < Threshold   Duration >= Threshold
          │                   │
    Single Foreground    Repeated Foreground
                         (N times, 2s apart)
```

## Installation

### Option 1: Build from Source

```bash
git clone <repo-url> && cd AppForegronder
bash build.sh
cp -r .build/release/AppForegronder.app /Applications/
open /Applications/AppForegronder.app
```

### Option 2: Download Release

Download the latest `.app` from [Releases](../../releases) and drag it to `/Applications`.

## Build Requirements

- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools

> **Note:** Due to a known CLT toolchain issue, this project uses `swiftc` directly instead of `swift build`. The `build.sh` script handles everything automatically.

## Usage

1. Launch the app. A small icon appears in the **menu bar** (top-right of screen)
2. Click the icon to open the settings panel
3. Select your **target application** from the dropdown
4. Enable the desired trigger mode(s)
5. Click **Start**

### Trigger Modes Explained

**Auto Foreground on Unlock**
> Fires once every time you unlock the screen. No conditions, no delay.

**Smart Lock Trigger** (sub-option of Unlock)
> Only fires when the screen was locked for longer than a threshold you set (e.g., 1 hour). When triggered, it foregrounds the target app multiple times in a row (configurable, default 5 times at 2-second intervals) to ensure it stays on top.

**Timed Foreground**
> Fires at a fixed interval (1-60 minutes) regardless of whether you lock/unlock. Useful to prevent the target app from being buried under other windows.

## Permissions

On first run, macOS may ask for **Accessibility** permissions. Grant them at:

**System Settings > Privacy & Security > Accessibility**

This is required for the app to activate and foreground other applications via AppleScript.

## Project Structure

```
AppForegronder/
├── AppForegronderApp.swift    # @main entry, MenuBarExtra
├── AppState.swift             # State management, UserDefaults persistence
├── AppActivator.swift         # AppleScript reopen+activate logic
├── ScreenLockObserver.swift   # Lock/unlock event listener
├── TimerManager.swift         # Timer wrapper
├── MenuBarView.swift          # SwiftUI menu bar popover UI
├── Localization.swift         # Bilingual string definitions
├── AppIcon.icns               # App icon
├── Info.plist                 # LSUIElement=true (no Dock icon)
└── AppForegronder.entitlements
```

## License

MIT
