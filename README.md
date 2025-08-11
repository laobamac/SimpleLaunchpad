# SimpleLaunchpad
Fucking Apple😡Give me LaunchPad back!

This project is in developing....

# SimpleLaunchpad - macOS Tahoe 启动台替代方案
#### 该死的苹果😡把LaunchPad还给我！
#### 这个项目正在开发中...... 仍然很多不稳定因素！

![Swift](https://img.shields.io/badge/Swift-5.5-orange.svg)
![Platform](https://img.shields.io/badge/macOS-15+-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-green.svg)
![GitHub all releases](https://img.shields.io/github/downloads/laobamac/SimpleLaunchpad/total?color=white&style=plastic)

## 项目简介

SimpleLaunchpad 是为 macOS Tahoe 设计的启动台替代应用。由于 Tahoe Beta5 开始 Apple 移除了原生的启动台功能，这个开源项目旨在为用户提供类似的应用程序启动体验。

**许可证**: AGPL-3.0  
**作者**: laobamac  
**GitHub**: [项目链接](https://github.com/laobamac/SimpleLaunchpad)

## 功能特性

- 🚀 类 macOS 启动台的应用程序网格视图
- 🔍 支持应用搜索功能
- 📁 自动扫描系统应用和自定义目录
- 🗂️ 应用自动分类（网络、实用工具、创意等）
- ⚙️ 支持两种排序方式：按名称或自定义顺序
- 🎨 精美的启动动画和过渡效果
- ⌨️ 支持快捷键操作（Cmd+Shift+L 呼出启动台）
- 🌙 毛玻璃背景效果

## 安装方法

1. 从 Releases 页面下载最新版本
2. 打开下载的磁盘映像
3. 将 SimpleLaunchpad 拖拽到 Applications 文件夹
4. 在应用程序文件夹中启动 SimpleLaunchpad

## 使用说明

- **基本使用**:
  - 点击应用图标启动应用程序
  - 使用搜索框快速查找应用
  - 左右滑动或使用滚轮切换分页
  - 按 ESC 键或点击空白处退出启动台

- **快捷键**:
  - `Cmd + Shift + L`: 显示/隐藏启动台
  - `Cmd + ,`: 打开偏好设置
  - `Cmd + ↑/↓`: 在手动排序模式下移动应用位置

- **偏好设置**:
  - 通用设置: 更改排序方式、登录启动等
  - 应用管理: 自定义应用顺序、添加扫描目录
  - 高级设置: 恢复默认设置

## 开发与贡献

欢迎贡献代码！项目使用 SwiftUI 开发，需要 Xcode 和 macOS Tahoe 或更高版本。

1. Fork 本项目
2. 创建你的分支 (`git checkout -b feature/新功能`)
3. 提交更改 (`git commit -am '添加了新功能'`)
4. 推送到分支 (`git push origin feature/新功能`)
5. 创建 Pull Request

## 已知问题

- [ ] 文件夹分组功能尚未实现
- [ ] 某些系统应用的图标可能无法正确显示
- [ ] 有概率快捷键失效

## 未来计划

- [ ] 实现应用分组功能
- [ ] 添加自定义主题支持
- [ ] 支持触控板手势操作
- [ ] 增加应用快捷操作菜单

## 许可证

本项目采用 AGPL-3.0 许可证开源。详情请见 LICENSE 文件。

---

*提示：本项目是 macOS 原生启动台的替代方案，并非 Apple 官方产品。*
