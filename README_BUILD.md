# AppForegronder Build Guide

## 方式 1: Swift Package Manager

```bash
cd AppForegronder
swift build
swift run
```

或直接一步构建并运行:

```bash
swift build -c release && .build/release/AppForegronder
```

## 方式 2: Xcode

用 Xcode 打开 `Package.swift`，然后按 `Cmd+R` 构建运行。

## 注意事项

首次运行后，需要在系统设置中授权 Accessibility 权限:

系统设置 > 隐私与安全性 > 辅助功能，将 AppForegronder 添加并启用。

未授权时应用可以启动，但前台切换功能将无法正常工作。
