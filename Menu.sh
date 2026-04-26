#!/data/data/com.termux/files/usr/bin/bash

# PlotPilot-Termux 管理菜单 (简化演示版)
# 完整功能请运行 Install.sh 安装

INSTALL_DIR="$HOME/PlotPilot"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║              📚 PlotPilot-Termux 管理菜单                    ║"
echo "║                                                              ║"
echo "║         请先运行 Install.sh 完成完整安装                     ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  PlotPilot 尚未安装${NC}"
    echo ""
    echo "请运行以下命令安装："
    echo "  curl -O https://raw.githubusercontent.com/your-username/PlotPilot-Termux/main/Install.sh"
    echo "  bash Install.sh"
    echo ""
fi

echo "功能预览："
echo ""
echo "  1. 🚀 启动 PlotPilot        - 一键启动前后端服务"
echo "  2. 🔄 更新 PlotPilot        - 拉取最新代码并更新依赖"
echo "  3. 🔧 服务配置              - 局域网访问/API密钥配置"
echo "  4. 📊 查看状态              - 查看服务运行状态和日志"
echo "  5. 💾 数据维护              - 备份/恢复/修复"
echo "  6. 📦 脚本管理              - 更新/卸载"
echo "  7. ℹ️  关于                - 作者信息/社群"
echo "  0. 🚪 退出"
echo ""
echo -e "${CYAN}完整安装后将提供交互式菜单${NC}"
echo ""
