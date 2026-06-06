<p align="center">
  <img src="assets/website_screenshot.png" alt="AppUnlocker 官方网站" width="100%">
</p>

<p align="center">
  <a href="https://tsingke.github.io/AppUnlocker">🌐 官方网站</a> ·
  <a href="README.md">🇬🇧 English</a>
</p>

<br>

<p align="center">
  <img src="assets/app_screenshot.png" alt="AppUnlocker Screenshot" width="540">
</p>

<h1 align="center">
  AppUnlocker
</h1>

<p align="center">
  <b>优雅移除 macOS 应用的隔离属性</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-blue?logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Swift-5.0-orange?logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/Platform-Apple_Silicon_%7C_Intel-lightgrey" alt="Platform">
  <a href="https://tsingke.github.io/AppUnlocker"><img src="https://img.shields.io/badge/Website-tsingke.github.io/AppUnlocker-purple?logo=githubpages" alt="Website"></a>
</p>

<br>

## 📖 介绍

当你在 Mac 上下载并打开从互联网获取的应用时，可能会遇到这样的提示：

> **「"Example.app" 已损坏，无法打开，你应该将它移到废纸篓。」**

这是 macOS **Gatekeeper** 的安全机制。系统会给从网络下载的应用打上 `com.apple.quarantine` 扩展属性（隔离标记），当检测到该属性时便会阻止应用运行。

**AppUnlocker** 是一款原生 macOS 工具，可以移除这个隔离标记，让应用恢复正常运行——无需打开终端、无需记忆任何命令。

<br>

## ✨ 功能特点

| 功能 | 说明 |
|------|------|
| 🖱️ **拖拽修复** | 将任意 `.app` 拖入应用区域，自动开始修复 |
| 📁 **文件选择** | 通过原生文件选择面板浏览并选取应用 |
| ⚡ **两步解锁** | 先尝试普通权限移除；失败后自动请求管理员授权 |
| 📋 **修复记录** | 查看历史修复记录，支持重试和直接打开 |
| 🔁 **重试与打开** | 修复失败可重试，成功后一键打开应用 |
| 🧹 **清理管理** | 支持单条删除或一键清除全部记录 |
| 🎨 **原生界面** | 基于 SwiftUI + AppKit，完美融入 macOS 设计语言 |
| 🔒 **隐私优先** | 完全离线运行，不上传任何数据 |

<br>

## 🖼️ 截图

<p align="center">
  <img src="assets/app_screenshot.png" alt="主界面" width="360">
  &nbsp;&nbsp;
  <img src="assets/dmg_screenshot.png" alt="安装包" width="440">
</p>

<br>

## 📦 安装方式

### 方式一：下载 DMG（推荐）

从 [Releases 页面](https://github.com/tsingke/AppUnlocker/releases) 下载最新的 `AppUnlocker.dmg`，打开后将应用拖入 **Applications** 文件夹。

或者直接点击下载：

[⬇️ 下载 AppUnlocker.dmg](https://github.com/tsingke/AppUnlocker/releases/download/v1.0.0/AppUnlocker.dmg)

> **注意：** 应用使用 ad-hoc 签名（未购买 Apple Developer 付费账号），首次打开会触发 Gatekeeper 提示。请 **右键 → 打开** 以绕过，仅首次需要。

### 方式二：从源码构建

```bash
# 克隆仓库
git clone https://github.com/tsingke/AppUnlocker.git
cd AppUnlocker

# 用 Xcode 打开
open AppUnlocker.xcodeproj

# 选择 Scheme: AppUnlocker > My Mac
# 按 ⌘R 构建并运行
```

**环境要求：**
- macOS 13.0+
- Xcode 15+
- Swift 5.0

<br>

## 🔧 工作原理

### 技术背景

当 macOS 下载应用时，系统添加扩展属性：

```bash
$ xattr -l /Applications/Example.app
com.apple.quarantine: 0081;674e3c2c;Google Chrome;...
```

Gatekeeper 检测到此属性后阻止应用运行。

### 两步移除策略

**Step 1 — 直接移除**
尝试以当前用户身份执行 `xattr` 命令。当用户拥有应用所有权时成功。

```bash
xattr -r -d com.apple.quarantine /Applications/Example.app
```

**Step 2 — 提权移除**
若 Step 1 失败（如应用属于 system），通过 AppleScript 弹出系统级授权对话框，请求管理员密码后执行相同命令。

```bash
osascript -e 'do shell script "xattr -r -d com.apple.quarantine /Applications/Example.app" with administrator privileges'
```

两步均在后台线程（`Task.detached`）执行，UI 保持完全响应。

<br>

## 🏗️ 项目结构

```
AppUnlocker/
├── AppUnlockerApp.swift          # @main 应用入口
├── ContentView.swift             # 根视图（标题栏、拖拽区、历史列表）
├── AppUnlockerViewModel.swift    # 业务逻辑 + @MainActor 状态管理
├── AppItem.swift                 # 数据模型（AppItem + FixStatus）
├── DropZoneView.swift            # 拖拽交互界面（文件拖入识别）
├── HistoryRowView.swift          # 修复记录卡片（状态动画）
├── Assets.xcassets/              # 应用图标 + 强调色
│   └── AppIcon.appiconset/       # 10 种 PNG 尺寸 (16×16 → 1024×1024)
├── Info.plist                    # 包元信息
└── AppUnlocker.entitlements      # 授权配置（禁用沙盒）
```

**架构模式：** MVVM（Model-View-ViewModel）
**技术栈：** SwiftUI + AppKit

<br>

## 🌐 项目网站

访问 [tsingke.github.io/AppUnlocker](https://tsingke.github.io/AppUnlocker) 查看详细介绍。

<br>

## 📄 开源许可

本项目基于 [MIT License](LICENSE) 开源。

---

<p align="center">
  Made with ❤️ for the macOS 开源社区
</p>
