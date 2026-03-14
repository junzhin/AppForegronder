import Foundation

enum Language: String {
    case zh = "zh"
    case en = "en"
}

struct L10n {
    let lang: Language

    var targetApp: String { lang == .zh ? "目标应用" : "Target App" }
    var selectApp: String { lang == .zh ? "请选择…" : "Select..." }
    var selectedApps: String { lang == .zh ? "个已选" : "selected" }
    var unlockToggle: String { lang == .zh ? "解锁时自动前置" : "Auto foreground on unlock" }
    var smartUnlock: String { lang == .zh ? "智能锁屏触发" : "Smart lock trigger" }
    var lockThreshold: String { lang == .zh ? "锁屏阈值" : "Lock threshold" }
    var minutes: String { lang == .zh ? "分钟" : "min" }
    var timerToggle: String { lang == .zh ? "定时前置" : "Timed foreground" }
    var interval: String { lang == .zh ? "间隔" : "Interval" }
    var hotkeyToggle: String { lang == .zh ? "全局快捷键 ⌘⇧F" : "Global Hotkey ⌘⇧F" }
    var start: String { lang == .zh ? "启动" : "Start" }
    var stop: String { lang == .zh ? "停止" : "Stop" }
    var foregroundNow: String { lang == .zh ? "立即前置" : "Foreground Now" }
    var launchAtLogin: String { lang == .zh ? "开机自启动" : "Launch at Login" }
    var refreshApps: String { lang == .zh ? "刷新应用列表" : "Refresh Apps" }
    var quit: String { lang == .zh ? "退出" : "Quit" }
    var accessibilityWarning: String { lang == .zh ? "需要辅助功能权限" : "Accessibility permission required" }
    var goToSettings: String { lang == .zh ? "前往设置" : "Open Settings" }
    var recentLogs: String { lang == .zh ? "最近记录" : "Recent Logs" }
    var noLogs: String { lang == .zh ? "暂无记录" : "No logs yet" }

    var helpUnlock: String {
        lang == .zh
            ? "每次屏幕解锁时，自动将目标应用前置一次。\n无论锁屏多久，解锁即触发。"
            : "Bring target app to front on every screen unlock.\nTriggers regardless of lock duration."
    }
    var helpSmartUnlock: String {
        lang == .zh
            ? "仅在锁屏时长超过设定阈值时才触发前置。\n适合午休、离开等长时间锁屏后使用。"
            : "Only triggers foreground when lock duration exceeds threshold.\nIdeal after lunch breaks or extended absences."
    }
    var helpTimer: String {
        lang == .zh
            ? "按固定时间间隔循环前置目标应用。\n与锁屏无关，即使一直在使用电脑也会定时触发。\n适合防止目标应用被其他窗口覆盖。"
            : "Periodically bring target app to front at fixed intervals.\nWorks independently of screen lock.\nPrevents target app from being buried under other windows."
    }
    var helpThreshold: String {
        lang == .zh ? "锁屏超过此时长（分钟）才会触发前置" : "Foreground only triggers after this lock duration (minutes)"
    }
    var helpHotkey: String {
        lang == .zh
            ? "按下 ⌘⇧F 立即前置目标应用，无需打开菜单。"
            : "Press ⌘⇧F to instantly foreground target apps without opening the menu."
    }
}
