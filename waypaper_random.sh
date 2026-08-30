#!/run/current-system/sw/bin/bash

# waypaper_random.sh - 每隔10分钟随机更换壁纸的脚本
# 通过systemd定时器或cron定时执行

# 设置日志文件路径
LOG_DIR="$HOME/.local/log/waypaper"
LOG_FILE="$LOG_DIR/waypaper_random.log"

# 创建日志目录（如果不存在）
mkdir -p "$LOG_DIR"

# 日志函数
log_message() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# 检查waypaper命令是否存在
if ! command -v waypaper &> /dev/null; then
    log_message "错误: waypaper命令未找到"
    exit 1
fi

# 记录脚本开始执行
log_message "开始执行waypaper --random"

# 执行waypaper命令
if waypaper --random; then
    log_message "成功: 壁纸已随机更换"
else
    log_message "错误: waypaper命令执行失败，退出码: $?"
    exit 1
fi

log_message "脚本执行完成"