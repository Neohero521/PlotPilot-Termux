#!/data/data/com.termux/files/usr/bin/bash

# PlotPilot 快速启动脚本

INSTALL_DIR="$HOME/PlotPilot"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "错误：PlotPilot 未安装"
    echo "请先运行 Install.sh 安装"
    exit 1
fi

cd $INSTALL_DIR

# 检查虚拟环境
if [ ! -d ".venv" ]; then
    echo "错误：未找到 Python 虚拟环境"
    exit 1
fi

# 启动后端
echo "🚀 启动 PlotPilot 后端..."
source .venv/bin/activate
nohup uvicorn interfaces.main:app --host 0.0.0.0 --port 8005 > logs/backend.log 2>&1 &
echo $! > logs/backend.pid

# 等待后端启动
sleep 3

# 启动前端
echo "🎨 启动 PlotPilot 前端..."
cd frontend
nohup npm run dev -- --host 0.0.0.0 > ../logs/frontend.log 2>&1 &
echo $! > ../logs/frontend.pid

echo ""
echo "✅ PlotPilot 已启动！"
echo ""
echo "📱 本地访问: http://localhost:3000"
echo ""

# 获取 IP
IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
if [ ! -z "$IP" ]; then
    echo "🌐 局域网访问: http://$IP:3000"
    echo ""
fi

echo "查看日志:"
echo "  后端: tail -f ~/PlotPilot/logs/backend.log"
echo "  前端: tail -f ~/PlotPilot/logs/frontend.log"
echo ""
echo "停止服务: bash ~/PlotPilot/stop.sh"
