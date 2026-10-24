# ThreeFingerMiddle

一个轻量级的 macOS 应用，将三指轻点触控板的手势转换为鼠标中键点击。

A lightweight macOS app that converts a three-finger tap on the trackpad into a middle mouse click.

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
