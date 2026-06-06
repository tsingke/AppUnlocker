<p align="center">
  <img src="assets/app_screenshot.png" alt="AppUnlocker Screenshot" width="540">
</p>

<h1 align="center">
  AppUnlocker
</h1>

<p align="center">
  <b>Remove macOS quarantine attributes with ease</b><br>
  <b>优雅移除 macOS 应用的隔离属性</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-blue?logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Swift-5.0-orange?logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/Platform-Apple_Silicon_%7C_Intel-lightgrey" alt="Platform">
</p>

<br>

<p align="center">
  <a href="#english">🇬🇧 English</a> ·
  <a href="#chinese">🇨🇳 中文</a>
</p>

---

<h2 id="english">🇬🇧 Overview</h2>

**AppUnlocker** is a native macOS utility that removes the `com.apple.quarantine` extended attribute from downloaded applications. When macOS Gatekeeper blocks an app downloaded from the internet, AppUnlocker provides a clean, native interface to strip the quarantine flag — no terminal commands needed.

<br>

### ✨ Features

| Feature | Description |
|---------|-------------|
| 🖱️ **Drag & Drop** | Drag any `.app` bundle onto the drop zone |
| 📁 **File Picker** | Browse and select apps via native `NSOpenPanel` |
| ⚡ **Two‑Step Unlock** | Attempts direct `xattr` removal first; falls back to admin‑authorized AppleScript if needed |
| 📋 **History** | View previously unlocked apps with fix status and timestamps |
| 🔁 **Retry & Open** | Re‑attempt a failed fix or launch a successfully unlocked app |
| 🧹 **Clean Up** | Remove individual records or clear the entire history |

<br>

### 🖼️ Screenshots

<p align="center">
  <img src="assets/app_screenshot.png" alt="AppUnlocker Main Window" width="360">
  &nbsp;&nbsp;&nbsp;
  <img src="assets/dmg_screenshot.png" alt="DMG Installer" width="440">
</p>

<br>

### 📦 Installation

**Option 1 — Download DMG**  
Download the latest `AppUnlocker.dmg` from the [Releases](https://github.com/your-username/AppUnlocker/releases) page, open it, and drag the app into your `Applications` folder.

> **Note:** Since the app is ad‑hoc signed (no paid Apple Developer ID), the first launch will show a Gatekeeper warning. **Right‑click → Open** to bypass it. This happens once only.

**Option 2 — Build from source**  

```bash
# Clone the repository
git clone https://github.com/your-username/AppUnlocker.git
cd AppUnlocker

# Open in Xcode
open AppUnlocker.xcodeproj

# Build & run (⌘R)
```

Requirements: **Xcode 15+**, **macOS 13.0+**, **Swift 5.0**.

<br>

### 🔧 How It Works

When macOS downloads an app from the internet, it stamps the file with a `com.apple.quarantine` extended attribute. Gatekeeper checks this attribute and blocks execution if it suspects the app is unsafe.

AppUnlocker removes this attribute in two steps:

1. **Direct** — runs `/usr/bin/xattr -r -d com.apple.quarantine` under the current user (works when the user owns the app).
2. **Elevated** — if Step 1 fails, the app presents a system dialog requesting administrator privileges and runs the same command via `osascript` + `do shell script with administrator privileges`.

Both operations are handled in a background thread so the UI stays responsive.

<br>

### 🏗️ Architecture

```
AppUnlocker/
├── AppUnlockerApp.swift          # @main app entry point
├── ContentView.swift             # Root view (title bar, drop zone, history)
├── AppUnlockerViewModel.swift    # Business logic + observable state
├── AppItem.swift                 # Data model
├── DropZoneView.swift            # Drag‑and‑drop interface
├── HistoryRowView.swift          # Per‑app history card
├── Assets.xcassets/              # App icon + accent color
│   └── AppIcon.appiconset/       # 10 PNG sizes (16×16 → 1024×1024)
├── Info.plist                    # Bundle metadata
└── AppUnlocker.entitlements      # Entitlements (sandbox disabled)
```

Built with **SwiftUI** + **AppKit** on the **MVVM** pattern.

<br>

### 📄 License

This project is open source under the [MIT License](LICENSE).

---

<br>

<h2 id="chinese">🇨🇳 中文介绍</h2>

**AppUnlocker** 是一款原生 macOS 工具，用于移除应用的 `com.apple.quarantine` 扩展属性。当 macOS Gatekeeper 阻止你打开从网络下载的应用时，AppUnlocker 提供了简洁的原生界面来移除隔离标记——不需要敲任何终端命令。

<br>

### ✨ 功能特点

| 功能 | 说明 |
|------|------|
| 🖱️ **拖拽修复** | 将任意 `.app` 拖入修复区域即可 |
| 📁 **文件选择** | 通过原生 `NSOpenPanel` 浏览并选取应用 |
| ⚡ **两步解锁** | 先尝试普通权限移除；无权限时自动请求管理员密码执行 AppleScript |
| 📋 **修复记录** | 查看历史修复记录，包括状态和时间 |
| 🔁 **重试与打开** | 修复失败可重试，成功后可直接打开应用 |
| 🧹 **清理管理** | 支持单条删除或一键清除全部记录 |

<br>

### 🖼️ 截图预览

<p align="center">
  <img src="assets/app_screenshot.png" alt="主界面截图" width="360">
  &nbsp;&nbsp;&nbsp;
  <img src="assets/dmg_screenshot.png" alt="安装包截图" width="440">
</p>

<br>

### 📦 安装方式

**方式一 — 下载 DMG**  
从 [Releases](https://github.com/your-username/AppUnlocker/releases) 页面下载最新的 `AppUnlocker.dmg`，打开后把应用拖入 `Applications` 文件夹即可。

> **注意：** 应用使用 ad‑hoc 签名（无付费 Apple Developer ID），首次打开会触发 Gatekeeper 提示。**右键 → 打开** 即可绕过，仅需一次。

**方式二 — 从源码构建**  

```bash
# 克隆仓库
git clone https://github.com/your-username/AppUnlocker.git
cd AppUnlocker

# 用 Xcode 打开
open AppUnlocker.xcodeproj

# 构建并运行 (⌘R)
```

环境要求：**Xcode 15+**、**macOS 13.0+**、**Swift 5.0**。

<br>

### 🔧 工作原理

当 macOS 从网络下载应用时，系统会给文件打上 `com.apple.quarantine` 扩展属性。Gatekeeper 检测到这个属性后会阻止应用运行。

AppUnlocker 分两步移除该属性：

1. **直接移除** — 以当前用户身份执行 `/usr/bin/xattr -r -d com.apple.quarantine`（用户拥有应用所有权时有效）。
2. **提权移除** — 若第一步失败，弹出系统级授权对话框，通过 `osascript` + `do shell script with administrator privileges` 执行相同命令。

所有操作在后台线程执行，UI 保持响应。

<br>

### 🏗️ 项目结构

```
AppUnlocker/
├── AppUnlockerApp.swift          # @main 应用入口
├── ContentView.swift             # 根视图（标题栏、拖拽区、历史列表）
├── AppUnlockerViewModel.swift    # 业务逻辑 + 可观察状态
├── AppItem.swift                 # 数据模型
├── DropZoneView.swift            # 拖拽交互界面
├── HistoryRowView.swift          # 单条记录卡片
├── Assets.xcassets/              # 应用图标 + 强调色
│   └── AppIcon.appiconset/       # 10 种 PNG 尺寸 (16×16 → 1024×1024)
├── Info.plist                    # 包元信息
└── AppUnlocker.entitlements      # 授权配置（已禁用沙盒）
```

基于 **SwiftUI** + **AppKit** 构建，采用 **MVVM** 架构。

<br>

### 📄 开源许可

本项目基于 [MIT 许可证](LICENSE) 开源。

---

<br>

<p align="center">
  <sub>Made with ❤️ for the macOS open‑source community</sub><br>
  <sub>为 macOS 开源社区贡献 ❤️</sub>
</p>
