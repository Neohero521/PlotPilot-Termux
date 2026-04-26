# PlotPilot-Termux

专为安卓设备打造的 [PlotPilot](https://github.com/shenminglinyi/PlotPilot) 一站式部署与管理解决方案。

基于原生 Termux 环境，只需一条命令即可完成自动化安装、配置与管理，让您在手机上也能享受完整的 PlotPilot AI 创作体验。

---

## 📖 项目介绍

[PlotPilot](https://github.com/shenminglinyi/PlotPilot) 是一个强大的 AI 驱动的长篇创作平台：

- ✍️ **全托管自动驾驶写作** - 后台自动推进宏观规划→幕级节拍→章节生成→章末审阅
- 📚 **Story Bible** - 人物、地点、世界设定的结构化管理
- 🔗 **知识图谱** - 自动提取故事三元组，语义检索历史内容
- 🪝 **伏笔台账** - 追踪并自动闭合叙事钩子
- 🎨 **风格分析** - 作者声音漂移检测与文体指纹

---

## ✨ 功能特性

### 一键安装，全自动配置

- ✅ **零配置安装**：一条命令完成环境检测、依赖安装、主程序部署
- ✅ **智能依赖管理**：自动检测并安装 Python、Node.js、Git 等核心依赖
- ✅ **开箱即用**：安装完成后自动配置启动项，重启 Termux 即可进入管理菜单
- ✅ **容错机制**：网络中断自动重试，安装失败智能回退

### 7大功能模块，覆盖全生命周期管理

| 功能模块 | 核心功能 |
|---------|---------|
| 🚀 启动 PlotPilot | 一键启动前后端服务，智能检测依赖完整性 |
| 🔄 更新 PlotPilot | 智能检测远程更新，一键拉取最新代码并更新依赖 |
| 🔧 服务配置 | 局域网访问配置、API 密钥设置、端口配置 |
| 📊 查看状态 | 服务运行状态、实时日志查看 |
| 💾 数据维护 | 数据备份/恢复、依赖修复、日志清理 |
| 📦 脚本管理 | 脚本在线升级、版本信息、一键卸载 |
| ℹ️ 关于 | 作者信息、官方仓库、功能介绍 |

### 专为中文用户打造的友好界面

- 🎨 **全中文界面**：菜单、提示、帮助文档全面中文化
- 📱 **移动优化**：界面布局针对手机屏幕优化，操作流畅便捷
- 💾 **完善的备份机制**：支持数据备份到手机存储，一键恢复

---

## 🚀 快速开始

### 只需三步，即可在安卓设备上运行 PlotPilot！

#### 1️⃣ 安装 Termux

⚠️ **重要提示**：请务必使用官方渠道下载的 Termux，切勿使用 Google Play 商店版本（已停止维护）！

| 渠道 | 版本 | 推荐度 | 下载链接 |
|-----|------|--------|---------|
| GitHub | v0.118.3 (稳定版) | ⭐⭐⭐⭐⭐ | [下载 APK](https://github.com/termux/termux-app/releases/download/v0.118.3/termux-app_v0.118.3+github-debug_universal.apk) |
| F-Droid | v0.118.3 (稳定版) | ⭐⭐⭐⭐⭐ | [下载 APK](https://f-droid.org/repo/com.termux_1002.apk) |

#### 2️⃣ 一键安装

打开 Termux，粘贴并执行以下命令：

```bash
curl -O https://raw.githubusercontent.com/your-username/PlotPilot-Termux/main/Install.sh && bash Install.sh
```

安装过程自动完成以下操作：

- ✅ 环境检测与存储权限配置
- ✅ 更换清华镜像源加速
- ✅ 安装核心依赖（Git、Python、Node.js、SQLite 等）
- ✅ 克隆 PlotPilot 官方仓库
- ✅ 创建 Python 虚拟环境并安装依赖
- ✅ 安装前端依赖
- ✅ 创建启动/停止脚本
- ✅ 下载管理菜单脚本
- ✅ 配置菜单自启动

⏱️ **预计耗时**：首次安装约 10-20 分钟（视网络状况而定）

#### 3️⃣ 开始使用

安装完成后，**重启 Termux** 即可自动进入管理菜单：

```
📚 PlotPilot 管理菜单

  1. 🚀 启动 PlotPilot        - 一键启动前后端服务
  2. 🔄 更新 PlotPilot        - 拉取最新代码并更新依赖
  3. 🔧 服务配置              - 局域网访问/API密钥配置
  4. 📊 查看状态              - 查看服务运行状态和日志
  5. 💾 数据维护              - 备份/恢复/修复
  6. 📦 脚本管理              - 更新/卸载
  7. ℹ️  关于                - 作者信息/社群
  0. 🚪 退出                  - 退出菜单
```

🎉 **恭喜！现在您可以：**

- 选择 **1. 启动 PlotPilot** 开始使用
- 在浏览器中访问 `http://localhost:3000`

---

## ⚠️ 重要配置

### 配置 LLM API 密钥

**首次使用前必须配置 API 密钥！**

在管理菜单中选择 **3. 服务配置 → 1. 配置 API 密钥**，或手动编辑：

```bash
nano ~/PlotPilot/.env
```

至少配置以下其中一项：

```env
# Anthropic Claude API
ANTHROPIC_API_KEY=your_claude_api_key_here

# 或火山方舟/豆包 API
ARK_API_KEY=your_doubao_api_key_here

# 或 OpenAI API
OPENAI_API_KEY=your_openai_api_key_here
```

---

## 📱 访问方式

### 本机访问

```
http://localhost:3000
```

### 局域网访问（其他设备）

1. 确保手机和访问设备连接同一 WiFi
2. 在管理菜单中选择 **3. 服务配置 → 2. 配置局域网访问**
3. 查看显示的 IP 地址
4. 在其他设备浏览器访问：`http://手机IP:3000`

---

## 💾 数据备份与恢复

### 备份数据

在管理菜单中选择 **5. 数据维护 → 1. 备份数据**

备份文件将保存至手机存储的 `PlotPilot` 文件夹：
```
/storage/emulated/0/PlotPilot/plotpilot_backup_YYYYMMDD_HHMMSS.tar.gz
```

### 恢复数据

1. 将备份文件放入手机存储的 `PlotPilot` 文件夹
2. 在管理菜单中选择 **5. 数据维护 → 2. 恢复数据**
3. 选择要恢复的备份文件

---

## 🔧 故障排查

### Q1: 为什么不能使用 Google Play 的 Termux？

A: Google Play 版本的 Termux 已于 2020 年停止维护，缺失许多核心组件。请从 GitHub Releases 或 F-Droid 下载。

### Q2: 安装过程中出现网络错误？

A: 可尝试以下方案：
- 检查网络连接，建议切换至 WiFi
- 确认能否访问 GitHub
- 脚本已内置清华镜像，如仍失败请检查网络环境

### Q3: 如何查看运行日志？

A: 在管理菜单中选择 **4. 查看状态**，或手动查看：
```bash
tail -f ~/PlotPilot/logs/backend.log    # 后端日志
tail -f ~/PlotPilot/logs/frontend.log   # 前端日志
```

### Q4: 启动失败怎么办？

A: 在管理菜单中选择 **5. 数据维护 → 3. 修复依赖环境**，或尝试：
```bash
cd ~/PlotPilot
bash stop.sh  # 停止现有服务
bash start.sh # 重新启动
```

### Q5: 如何完全卸载？

A: 在管理菜单中选择 **6. 脚本管理 → 3. 完全卸载 PlotPilot**

---

## 📋 系统要求

- ✅ **操作系统**：Android 7.0 及以上
- ✅ **Termux 版本**：v0.118.3 或更高
- ✅ **存储空间**：至少 1GB 可用空间（推荐 2GB 以上）
- ✅ **内存**：推荐 4GB 及以上
- ✅ **网络**：首次安装需下载约 300MB 数据

---

## 🔗 相关链接

- 📦 **PlotPilot 官方仓库**: https://github.com/shenminglinyi/PlotPilot
- 📖 **PlotPilot 文档**: https://github.com/shenminglinyi/PlotPilot/blob/master/README.md
- 🎬 **直播间**: 抖音搜索 91472902104
- 💬 **参考项目**: https://github.com/print-yuhuan/SillyTavern-Termux

---

## 📜 开源协议

本项目部署的 [PlotPilot](https://github.com/shenminglinyi/PlotPilot) 采用 Apache License 2.0 协议。

PlotPilot-Termux 脚本采用 MIT 协议。

---

Made with ❤️ for PlotPilot
