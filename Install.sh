#!/data/data/com.termux/files/usr/bin/bash

# PlotPilot-Termux 一键安装脚本
# 适配：https://github.com/shenminglinyi/PlotPilot
# 参考：https://github.com/print-yuhuan/SillyTavern-Termux

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 版本信息
SCRIPT_VERSION="1.0.0"
PLOTPILOT_REPO="https://github.com/shenminglinyi/PlotPilot.git"
INSTALL_DIR="$HOME/PlotPilot"
MENU_SCRIPT="$HOME/Menu.sh"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 打印横幅
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║              📚 PlotPilot-Termux 一键安装器                  ║"
    echo "║                                                              ║"
    echo "║         【墨枢】作者的领航员 · 安卓一站式部署                ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# 检测 Termux 环境
check_termux() {
    if [ -z "$TERMUX_VERSION" ]; then
        log_error "未检测到 Termux 环境！"
        echo "请确保您在 Termux 应用中运行此脚本。"
        exit 1
    fi

    # 检测是否为 Google Play 版本
    if [ "$TERMUX_APK_RELEASE" = "UNKNOWN" ] || [ -z "$TERMUX_APK_RELEASE" ]; then
        log_warn "可能使用的是非官方渠道 Termux"
        echo "建议从 F-Droid 或 GitHub Releases 下载官方版本"
    fi

    log_success "Termux 版本: $TERMUX_VERSION"
}

# 申请存储权限
request_storage_permission() {
    log_info "正在申请存储权限..."

    if [ ! -d "/storage/emulated/0" ]; then
        termux-setup-storage
        sleep 2

        # 等待用户授权
        for i in {1..30}; do
            if [ -d "/storage/emulated/0" ]; then
                log_success "存储权限已获取"
                return 0
            fi
            sleep 1
        done

        log_error "存储权限申请超时或未授权"
        echo "请在弹窗中点击'允许'，然后重新运行脚本"
        exit 1
    else
        log_success "存储权限已存在"
    fi
}

# 更新包管理器
update_packages() {
    log_info "正在更新软件包列表..."

    # 更换清华镜像源
    if [ ! -f "$PREFIX/etc/apt/sources.list.bak" ]; then
        cp $PREFIX/etc/apt/sources.list $PREFIX/etc/apt/sources.list.bak
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main" > $PREFIX/etc/apt/sources.list
        log_info "已更换为清华镜像源"
    fi

    apt update -y && apt upgrade -y
    log_success "软件包列表更新完成"
}

# 安装核心依赖
install_dependencies() {
    log_info "正在安装核心依赖..."

    local deps="git curl wget python nodejs-lts sqlite tmux"

    for dep in $deps; do
        if ! command -v $(echo $dep | cut -d'-' -f1) &> /dev/null; then
            log_info "正在安装 $dep..."
            apt install -y $dep || {
                log_error "$dep 安装失败，正在重试..."
                apt install -y $dep
            }
        else
            log_success "$dep 已安装"
        fi
    done

    # 安装 Python pip (Termux 不需要，pkg 已经提供)
    if ! command -v pip &> /dev/null; then
        if [ "$IS_TERMUX" = true ]; then
            pkg install -y python-pip
        else
            python -m ensurepip --upgrade
        fi
    fi

    # 升级 pip (排除 Termux，避免与系统包冲突)
    if [ "$IS_TERMUX" != true ]; then
        pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
    fi

    log_success "核心依赖安装完成"
}

# 配置终端字体
setup_font() {
    log_info "正在配置终端字体..."

    # 安装 Maple Mono 字体
    if [ ! -f "$HOME/.termux/font.ttf" ]; then
        mkdir -p $HOME/.termux

        # 下载 Maple Mono 字体
        curl -L -o $HOME/.termux/font.ttf \
            "https://github.com/subframe7536/maple-font/releases/download/v6.4/MapleMono-CN-Regular.ttf" 2>/dev/null || {
            log_warn "字体下载失败，使用默认字体"
            return
        }

        # 重载配置
        termux-reload-settings
        log_success "Maple Mono 字体配置完成"
    else
        log_success "字体已配置"
    fi
}

# 克隆 PlotPilot 仓库
clone_repository() {
    log_info "正在克隆 PlotPilot 仓库..."

    if [ -d "$INSTALL_DIR" ]; then
        log_warn "检测到已存在的安装目录"
        read -p "是否删除并重新安装? [y/N]: " choice
        if [[ $choice =~ ^[Yy]$ ]]; then
            rm -rf $INSTALL_DIR
        else
            log_info "保留现有安装，跳过克隆"
            return
        fi
    fi

    git clone --depth 1 $PLOTPILOT_REPO $INSTALL_DIR || {
        log_error "仓库克隆失败，请检查网络连接"
        exit 1
    }

    log_success "仓库克隆完成"
}

# 安装 Python 依赖
install_python_deps() {
    log_info "正在安装 Python 依赖..."

    cd $INSTALL_DIR

    # 创建虚拟环境
    if [ ! -d ".venv" ]; then
        python -m venv .venv
        log_success "Python 虚拟环境创建完成"
    fi

    # 激活虚拟环境
    source .venv/bin/activate

    # 安装依赖
    pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple || {
        log_warn "部分依赖安装失败，尝试单独安装关键依赖..."
        pip install fastapi uvicorn sqlalchemy python-multipart python-jose -i https://pypi.tuna.tsinghua.edu.cn/simple
    }

    # 安装 faiss-cpu（如果失败则跳过）
    pip install faiss-cpu -i https://pypi.tuna.tsinghua.edu.cn/simple 2>/dev/null || {
        log_warn "FAISS 安装失败，向量检索功能将不可用"
    }

    log_success "Python 依赖安装完成"
}

# 安装前端依赖
install_frontend_deps() {
    log_info "正在安装前端依赖..."

    cd $INSTALL_DIR/frontend

    # 使用淘宝镜像加速
    npm install --registry=https://registry.npmmirror.com --legacy-peer-deps || {
        log_warn "npm install 失败，尝试使用 yarn..."
        npm install -g yarn
        yarn install
    }

    log_success "前端依赖安装完成"
}

# 配置环境变量
setup_environment() {
    log_info "正在配置环境..."

    cd $INSTALL_DIR

    # 复制示例配置
    if [ ! -f ".env" ]; then
        cp .env.example .env

        # 修改配置
        sed -i 's/DISABLE_AUTO_DAEMON=.*/DISABLE_AUTO_DAEMON=1/' .env
        sed -i 's/CORS_ORIGINS=.*/CORS_ORIGINS=*/' .env
        sed -i 's/HOST=.*/HOST=0.0.0.0/' .env 2>/dev/null || true
        sed -i 's/PORT=.*/PORT=8005/' .env 2>/dev/null || true

        log_warn "请手动编辑 .env 文件配置 LLM API 密钥"
        echo "    nano $INSTALL_DIR/.env"
    fi

    # 创建前端环境配置
    if [ ! -f "frontend/.env.local" ]; then
        echo "VITE_API_BASE_URL=http://localhost:8005" > frontend/.env.local
    fi

    log_success "环境配置完成"
}

# 创建启动脚本
create_start_script() {
    log_info "正在创建启动脚本..."

    cat > $INSTALL_DIR/start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# PlotPilot 启动脚本

INSTALL_DIR="$HOME/PlotPilot"
LOG_DIR="$INSTALL_DIR/logs"

mkdir -p $LOG_DIR

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}正在启动 PlotPilot...${NC}"

# 检查虚拟环境
if [ ! -d "$INSTALL_DIR/.venv" ]; then
    echo "错误：未找到 Python 虚拟环境"
    exit 1
fi

# 启动后端
cd $INSTALL_DIR
source .venv/bin/activate
echo -e "${GREEN}启动后端服务...${NC}"
nohup uvicorn interfaces.main:app --host 0.0.0.0 --port 8005 --reload > $LOG_DIR/backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > $LOG_DIR/backend.pid

# 等待后端启动
sleep 3

# 启动前端
cd $INSTALL_DIR/frontend
echo -e "${GREEN}启动前端服务...${NC}"
nohup npm run dev -- --host 0.0.0.0 > $LOG_DIR/frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > $LOG_DIR/frontend.pid

echo ""
echo -e "${GREEN}✅ PlotPilot 已启动！${NC}"
echo ""
echo "📱 本地访问: http://localhost:3000"
echo "🌐 局域网访问: http://$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1):3000"
echo ""
echo "📊 后端 PID: $BACKEND_PID"
echo "🎨 前端 PID: $FRONTEND_PID"
echo ""
echo "查看日志: tail -f $LOG_DIR/backend.log"
EOF

    chmod +x $INSTALL_DIR/start.sh

    # 创建停止脚本
    cat > $INSTALL_DIR/stop.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

INSTALL_DIR="$HOME/PlotPilot"
LOG_DIR="$INSTALL_DIR/logs"

if [ -f "$LOG_DIR/backend.pid" ]; then
    kill $(cat $LOG_DIR/backend.pid) 2>/dev/null
    rm -f $LOG_DIR/backend.pid
fi

if [ -f "$LOG_DIR/frontend.pid" ]; then
    kill $(cat $LOG_DIR/frontend.pid) 2>/dev/null
    rm -f $LOG_DIR/frontend.pid
fi

pkill -f "uvicorn interfaces.main" 2>/dev/null
pkill -f "npm run dev" 2>/dev/null

echo "PlotPilot 已停止"
EOF

    chmod +x $INSTALL_DIR/stop.sh

    log_success "启动脚本创建完成"
}

# 下载管理菜单脚本
download_menu() {
    log_info "正在下载管理菜单..."

    cat > $MENU_SCRIPT << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# PlotPilot-Termux 管理菜单

INSTALL_DIR="$HOME/PlotPilot"
MENU_VERSION="1.0.0"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 清屏并打印横幅
clear
print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                 📚 PlotPilot 管理菜单                        ║"
    echo "║                                                              ║"
    echo "║              版本: $MENU_VERSION                                  ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 主菜单
main_menu() {
    while true; do
        print_banner
        echo ""
        echo "  1. 🚀 启动 PlotPilot        - 一键启动前后端服务"
        echo "  2. 🔄 更新 PlotPilot        - 拉取最新代码并更新依赖"
        echo "  3. 🔧 服务配置              - 局域网访问/API密钥配置"
        echo "  4. 📊 查看状态              - 查看服务运行状态和日志"
        echo "  5. 💾 数据维护              - 备份/恢复/修复"
        echo "  6. 📦 脚本管理              - 更新/卸载"
        echo "  7. ℹ️  关于                - 作者信息/社群"
        echo "  0. 🚪 退出                  - 退出菜单"
        echo ""
        read -p "请选择功能 [0-7]: " choice

        case $choice in
            1) start_plotpilot ;;
            2) update_plotpilot ;;
            3) configure_plotpilot ;;
            4) check_status ;;
            5) data_maintenance ;;
            6) script_management ;;
            7) about_info ;;
            0) echo "再见！"; exit 0 ;;
            *) echo "无效选项"; sleep 1 ;;
        esac
    done
}

# 启动服务
start_plotpilot() {
    clear
    echo -e "${BLUE}🚀 启动 PlotPilot...${NC}"
    echo ""

    if [ -f "$INSTALL_DIR/start.sh" ]; then
        bash $INSTALL_DIR/start.sh
    else
        echo "启动脚本不存在，尝试直接启动..."
        cd $INSTALL_DIR
        source .venv/bin/activate
        nohup uvicorn interfaces.main:app --host 0.0.0.0 --port 8005 > logs/backend.log 2>&1 &
        cd frontend && nohup npm run dev -- --host 0.0.0.0 > ../logs/frontend.log 2>&1 &
    fi

    echo ""
    read -p "按回车键返回菜单..."
}

# 更新服务
update_plotpilot() {
    clear
    echo -e "${BLUE}🔄 更新 PlotPilot...${NC}"
    echo ""

    cd $INSTALL_DIR

    # 保存当前修改
    git stash

    # 拉取最新代码
    git pull origin main || git pull origin master

    # 恢复修改
    git stash pop 2>/dev/null || true

    # 更新后端依赖
    source .venv/bin/activate
    pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

    # 更新前端依赖
    cd frontend
    npm install --registry=https://registry.npmmirror.com

    echo -e "${GREEN}✅ 更新完成！${NC}"
    read -p "按回车键返回菜单..."
}

# 配置服务
configure_plotpilot() {
    clear
    echo -e "${BLUE}🔧 服务配置${NC}"
    echo ""
    echo "  1. 配置 API 密钥 (编辑 .env)"
    echo "  2. 配置局域网访问"
    echo "  3. 配置前后端口"
    echo "  0. 返回"
    echo ""
    read -p "请选择: " cfg_choice

    case $cfg_choice in
        1)
            nano $INSTALL_DIR/.env
            ;;
        2)
            echo ""
            echo "局域网访问已默认启用"
            echo "访问地址: http://$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1):3000"
            read -p "按回车键继续..."
            ;;
        3)
            read -p "后端端口 [8005]: " backend_port
            read -p "前端端口 [3000]: " frontend_port
            echo "端口配置已保存"
            ;;
    esac
}

# 查看状态
check_status() {
    clear
    echo -e "${BLUE}📊 服务状态${NC}"
    echo ""

    # 检查后端
    if pgrep -f "uvicorn interfaces.main" > /dev/null; then
        echo -e "${GREEN}✅ 后端服务: 运行中${NC}"
        echo "   PID: $(pgrep -f "uvicorn interfaces.main")"
        echo "   日志: $INSTALL_DIR/logs/backend.log"
    else
        echo -e "${RED}❌ 后端服务: 未运行${NC}"
    fi

    echo ""

    # 检查前端
    if pgrep -f "npm run dev" > /dev/null; then
        echo -e "${GREEN}✅ 前端服务: 运行中${NC}"
        echo "   PID: $(pgrep -f "npm run dev")"
        echo "   日志: $INSTALL_DIR/logs/frontend.log"
    else
        echo -e "${RED}❌ 前端服务: 未运行${NC}"
    fi

    echo ""
    echo "最近日志:"
    if [ -f "$INSTALL_DIR/logs/backend.log" ]; then
        tail -n 5 $INSTALL_DIR/logs/backend.log
    fi

    echo ""
    read -p "按回车键返回菜单..."
}

# 数据维护
data_maintenance() {
    clear
    echo -e "${BLUE}💾 数据维护${NC}"
    echo ""
    echo "  1. 备份数据"
    echo "  2. 恢复数据"
    echo "  3. 修复依赖环境"
    echo "  4. 清理日志"
    echo "  0. 返回"
    echo ""
    read -p "请选择: " maint_choice

    case $maint_choice in
        1)
            BACKUP_DIR="/storage/emulated/0/PlotPilot"
            mkdir -p $BACKUP_DIR
            timestamp=$(date +%Y%m%d_%H%M%S)
            tar -czf "$BACKUP_DIR/plotpilot_backup_$timestamp.tar.gz" -C $INSTALL_DIR data .env
            echo -e "${GREEN}✅ 备份完成: $BACKUP_DIR/plotpilot_backup_$timestamp.tar.gz${NC}"
            ;;
        2)
            echo "请将备份文件放入 /storage/emulated/0/PlotPilot/"
            ls /storage/emulated/0/PlotPilot/*.tar.gz 2>/dev/null || echo "未找到备份文件"
            read -p "输入备份文件名: " backup_file
            if [ -f "/storage/emulated/0/PlotPilot/$backup_file" ]; then
                tar -xzf "/storage/emulated/0/PlotPilot/$backup_file" -C $INSTALL_DIR
                echo -e "${GREEN}✅ 恢复完成${NC}"
            else
                echo "备份文件不存在"
            fi
            ;;
        3)
            cd $INSTALL_DIR
            source .venv/bin/activate
            pip install -r requirements.txt --force-reinstall
            cd frontend && npm install
            echo -e "${GREEN}✅ 依赖修复完成${NC}"
            ;;
        4)
            rm -f $INSTALL_DIR/logs/*.log
            echo -e "${GREEN}✅ 日志已清理${NC}"
            ;;
    esac

    read -p "按回车键返回菜单..."
}

# 脚本管理
script_management() {
    clear
    echo -e "${BLUE}📦 脚本管理${NC}"
    echo ""
    echo "  1. 更新本脚本"
    echo "  2. 查看版本信息"
    echo "  3. 完全卸载 PlotPilot"
    echo "  0. 返回"
    echo ""
    read -p "请选择: " script_choice

    case $script_choice in
        1)
            curl -O https://raw.githubusercontent.com/kaku5/PlotPilot-Termux/main/Install.sh && bash Install.sh
            ;;
        2)
            echo "脚本版本: $MENU_VERSION"
            cd $INSTALL_DIR && git log -1 --oneline 2>/dev/null || echo "未检测到 Git 版本"
            ;;
        3)
            read -p "确定要卸载 PlotPilot? 此操作不可恢复 [y/N]: " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                bash $INSTALL_DIR/stop.sh 2>/dev/null
                rm -rf $INSTALL_DIR
                rm -f $HOME/Menu.sh
                echo -e "${GREEN}✅ PlotPilot 已卸载${NC}"
                exit 0
            fi
            ;;
    esac

    read -p "按回车键返回菜单..."
}

# 关于信息
about_info() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     ℹ️  关于 PlotPilot                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "PlotPilot 【墨枢】作者的领航员"
    echo "AI 驱动的长篇创作平台"
    echo ""
    echo "📦 官方仓库: https://github.com/shenminglinyi/PlotPilot"
    echo "📖 部署脚本: https://github.com/your-username/PlotPilot-Termux"
    echo ""
    echo "功能特色:"
    echo "  • 全托管自动驾驶写作"
    echo "  • 知识图谱管理"
    echo "  • Story Bible 设定管理"
    echo "  • 伏笔追踪"
    echo "  • 风格分析"
    echo ""
    read -p "按回车键返回菜单..."
}

# 运行主菜单
main_menu
EOF

    chmod +x $MENU_SCRIPT

    # 添加到 bashrc
    if ! grep -q "Menu.sh" "$HOME/.bashrc"; then
        echo "" >> $HOME/.bashrc
        echo "# PlotPilot 管理菜单" >> $HOME/.bashrc
        echo "if [ -f \"$MENU_SCRIPT\" ]; then" >> $HOME/.bashrc
        echo "    bash $MENU_SCRIPT" >> $HOME/.bashrc
        echo "fi" >> $HOME/.bashrc
    fi

    log_success "管理菜单配置完成"
}

# 完成安装
finish_install() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    ✅ 安装完成！${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}🎉 PlotPilot-Termux 已成功安装！${NC}"
    echo ""
    echo "📁 安装目录: $INSTALL_DIR"
    echo "📜 管理菜单: $MENU_SCRIPT"
    echo ""
    echo "⚠️  重要: 请先配置 API 密钥！"
    echo "    nano $INSTALL_DIR/.env"
    echo ""
    echo "🚀 启动方式:"
    echo "   1. 重启 Termux 自动进入管理菜单"
    echo "   2. 或手动运行: bash $MENU_SCRIPT"
    echo ""
    echo "📖 使用说明:"
    echo "   • 启动服务: 选择菜单 1"
    echo "   • 局域网访问: http://$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1):3000"
    echo "   • 查看日志: tail -f $INSTALL_DIR/logs/backend.log"
    echo ""
    echo -e "${YELLOW}请重启 Termux 开始使用 PlotPilot！${NC}"
    echo ""
}

# 主函数
main() {
    print_banner
    check_termux
    request_storage_permission
    update_packages
    install_dependencies
    setup_font
    clone_repository
    install_python_deps
    install_frontend_deps
    setup_environment
    create_start_script
    download_menu
    finish_install
}

# 错误处理
trap 'log_error "安装过程中发生错误！"; exit 1' ERR

# 运行
main
