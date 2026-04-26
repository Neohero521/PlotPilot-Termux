# 上传到 GitHub 指南

## 方式一：命令行上传 (推荐)

### 1. 在 GitHub 创建仓库

访问 https://github.com/new 创建新仓库：
- 仓库名：`PlotPilot-Termux`
- 描述：`PlotPilot 安卓 Termux 一键部署方案`
- 选择 Public 或 Private
- **不要**勾选 "Initialize this repository with a README"

### 2. 关联并推送

在 Termux 或本地运行以下命令：

```bash
# 进入项目目录
cd /home/kaku5/.openclaw/workspace/PlotPilot-Termux

# 添加你的 GitHub 仓库地址 (替换 your-username 为你的用户名)
git remote add origin https://github.com/your-username/PlotPilot-Termux.git

# 推送到 GitHub
git push -u origin master
```

### 3. 输入凭据

如果提示输入用户名密码：
- **用户名**: 你的 GitHub 用户名
- **密码**: 使用 Personal Access Token (不是登录密码!)

获取 Token: https://github.com/settings/tokens

---

## 方式二：GitHub CLI 上传

```bash
# 安装 gh
pkg install gh

# 登录
ght auth login

# 创建仓库并推送
cd /home/kaku5/.openclaw/workspace/PlotPilot-Termux
gh repo create PlotPilot-Termux --public --source=. --push
```

---

## 方式三：手动上传 (最简单)

1. 访问 https://github.com/new
2. 创建仓库 `PlotPilot-Termux`
3. 在仓库页面点击 "uploading an existing file"
4. 将以下文件拖拽上传：
   - `Install.sh`
   - `Menu.sh`
   - `start.sh`
   - `stop.sh`
   - `README.md`

---

## 验证上传

上传成功后访问：
```
https://github.com/your-username/PlotPilot-Termux
```

---

## 一键安装命令 (上传后使用)

上传完成后，用户可以使用以下命令安装：

```bash
curl -O https://raw.githubusercontent.com/your-username/PlotPilot-Termux/main/Install.sh && bash Install.sh
```

记得将 README.md 和 Install.sh 中的 `your-username` 替换为你的实际 GitHub 用户名！
