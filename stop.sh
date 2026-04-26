#!/data/data/com.termux/files/usr/bin/bash

# PlotPilot 停止脚本

INSTALL_DIR="$HOME/PlotPilot"

echo "🛑 正在停止 PlotPilot..."

# 停止后端
if [ -f "$INSTALL_DIR/logs/backend.pid" ]; then
    kill $(cat $INSTALL_DIR/logs/backend.pid) 2>/dev/null
    rm -f $INSTALL_DIR/logs/backend.pid
fi

# 停止前端
if [ -f "$INSTALL_DIR/logs/frontend.pid" ]; then
    kill $(cat $INSTALL_DIR/logs/frontend.pid) 2>/dev/null
    rm -f $INSTALL_DIR/logs/frontend.pid
fi

# 清理残留进程
pkill -f "uvicorn interfaces.main" 2>/dev/null
pkill -f "npm run dev" 2>/dev/null

echo "✅ PlotPilot 已停止"
