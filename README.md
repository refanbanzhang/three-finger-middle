# ThreeFingerMiddle

我很喜欢 Windows 上三指轻触触控板来模拟鼠标中键点击的功能——关闭浏览器标签页、打开链接到新标签页都非常方便。切换到 macOS 后，这个便利的手势却消失了。于是，ThreeFingerMiddle 诞生了：将这个好用的手势带到 macOS 触控板。

I loved Windows' three-finger light tap that simulates a middle mouse click—so handy for closing browser tabs, opening links in new tabs. When I switched to macOS, I missed that convenient gesture. So ThreeFingerMiddle was born: bringing that useful gesture to the macOS trackpad.

## 🌐 官方网站 / Official Website

**[https://refanbanzhang.github.io/three-finger-middle/](https://refanbanzhang.github.io/three-finger-middle/)**

## 📦 下载 / Download

**[点击下载最新版本 / Download Latest Release](https://github.com/refanbanzhang/three-finger-middle/releases/latest/download/ThreeFingerMiddle.dmg)**

或访问 [Releases 页面](https://github.com/refanbanzhang/three-finger-middle/releases) 查看所有版本。

Or visit the [Releases page](https://github.com/refanbanzhang/three-finger-middle/releases) to view all versions.

## ✨ 功能特点 / Features

- ✨ 简单直观：三指轻点触控板，自动模拟中键点击
- 🪶 轻量高效：纯本地运行，不占用系统资源
- 🔒 隐私安全：不联网，不收集任何数据
- 🎯 精准定位：在当前光标位置触发中键事件

## 📋 系统要求 / Requirements

- macOS 13.0 或更高版本 / macOS 13.0 or later

## 🚀 如何安装 / How to Install

1. 下载 DMG 文件 / Download the DMG file
2. 打开 DMG 并将应用拖入「应用程序」文件夹 / Open the DMG and drag the app to Applications
3. 首次运行时授予「辅助功能」权限 / Grant Accessibility permission on first launch
4. 前往「系统偏好设置 → 隐私与安全性 → 辅助功能」勾选 ThreeFingerMiddle
   / Go to System Preferences → Privacy & Security → Accessibility and enable ThreeFingerMiddle

## 🛠 开发 / Development

### Build

```bash
./build.sh
```

### Package DMG

```bash
./package-dmg.sh
```

### Run

```bash
open build/ThreeFingerMiddle.app
```

## 📄 许可证 / License

MIT

---

Made with ❤️ by [refanbanzhang](https://github.com/refanbanzhang)
