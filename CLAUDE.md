# AppForegronder

macOS 菜单栏应用，自动将指定应用前置到最前面。

## 构建

由于当前 CLT 的 `swift-package`/`llbuild` 存在符号不匹配问题，**不要使用** `swift build` 或 `swift run`。

编译命令：
```bash
swiftc -parse-as-library -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk -target arm64-apple-macosx13.0 -framework AppKit -framework SwiftUI -framework ServiceManagement -o .build/arm64-apple-macosx/debug/AppForegronder AppForegronder/*.swift
```

运行：
```bash
.build/arm64-apple-macosx/debug/AppForegronder
```

发布构建（含 App Bundle 打包）：
```bash
./build.sh
```

## 项目结构

```
AppForegronder/
├── AppForegronderApp.swift       # @main 入口, MenuBarExtra, 动态图标
├── AppState.swift                # 状态管理, UserDefaults 持久化, 操作日志
├── AppActivator.swift            # AppleScript reopen+activate 激活逻辑
├── ScreenLockObserver.swift      # 锁屏/解锁事件监听, 记录锁屏时长
├── TimerManager.swift            # 定时器
├── HotkeyManager.swift           # 全局快捷键 (⌘⇧F) 监听
├── AccessibilityChecker.swift    # 辅助功能权限检测与引导
├── MenuBarView.swift             # SwiftUI 菜单栏 UI
├── Localization.swift            # 中英文本地化
├── Info.plist                    # LSUIElement=true
└── AppForegronder.entitlements
```

## 功能

- 多应用选择，从运行中的应用列表勾选多个目标
- 解锁时自动前置（每次解锁触发一次）
- 智能锁屏触发（锁屏超过阈值分钟数后解锁时才前置）
- 定时前置（按设定间隔循环触发，支持 1-999 分钟）
- 全局快捷键 ⌘⇧F 立即前置
- 辅助功能权限检测与引导
- 操作日志（最近 50 条记录）
- 菜单栏图标状态指示（激活/未激活/未授权）

## 技术要点

- 激活最小化窗口必须用 AppleScript `reopen + activate`，`NSRunningApplication.activate()` 无法恢复最小化窗口
- 锁屏/解锁监听通过 `DistributedNotificationCenter` 的 `com.apple.screenIsLocked` / `com.apple.screenIsUnlocked`
- 解锁后延迟 1.5s 再执行激活，等系统动画完成
- 关闭 App Sandbox，否则无法通过 AppleScript 激活其他应用
- 全局快捷键通过 `NSEvent.addGlobalMonitorForEvents` 实现，需要辅助功能权限
- 权限检测使用 `AXIsProcessTrusted()` API
- 首次运行可能需要在 系统设置 > 隐私与安全 > 辅助功能 中授权

## 编码规范

- Swift 5 语法，最低部署目标 macOS 13
- 使用 `final class` 标注不被继承的类
- UserDefaults key 集中在 `AppState.Keys` enum 中管理
- UI 中文本使用中文
