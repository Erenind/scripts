# 随机壁纸更换脚本

这个项目包含一个shell脚本和systemd定时器，用于每隔10分钟随机更换壁纸。

## 文件说明

1. **waypaper_random.sh** - 主脚本文件
   - 执行 `waypaper --random` 命令
   - 记录日志到 `~/.local/log/waypaper/waypaper_random.log`
   - 包含错误检查和日志功能

2. **~/.config/systemd/user/waypaper-random.service** - systemd服务文件
   - 定义如何执行脚本
   - 设置必要的环境变量

3. **~/.config/systemd/user/waypaper-random.timer** - systemd定时器文件
   - 每10分钟触发一次服务
   - 系统启动后1分钟开始执行
   - 支持持久化定时器

## 安装和使用

### 1. 脚本已自动安装
脚本和systemd定时器已经配置完成。定时器将在系统启动时自动运行。

### 2. 手动控制命令

```bash
# 查看定时器状态
systemctl --user status waypaper-random.timer

# 查看服务状态
systemctl --user status waypaper-random.service

# 手动触发壁纸更换
systemctl --user start waypaper-random.service

# 启用/禁用定时器
systemctl --user enable waypaper-random.timer
systemctl --user disable waypaper-random.timer

# 重新加载配置
systemctl --user daemon-reload
```

### 3. 查看日志

```bash
# 查看脚本日志
tail -f ~/.local/log/waypaper/waypaper_random.log

# 查看systemd日志
journalctl --user -u waypaper-random.service -f
```

## 定时器设置

- **执行频率**: 每10分钟一次
- **首次执行**: 系统启动后1分钟
- **下次执行时间**: 查看 `systemctl --user status waypaper-random.timer`
- **日志位置**: `~/.local/log/waypaper/waypaper_random.log`

## 注意事项

1. 确保 `waypaper` 命令已安装并可用
2. 脚本需要图形环境（DISPLAY/WAYLAND_DISPLAY）才能正常工作
3. 日志文件会自动创建在 `~/.local/log/waypaper/` 目录

## 故障排除

如果壁纸没有更换，请检查：

1. `waypaper` 命令是否可用：`which waypaper`
2. 脚本是否有执行权限：`ls -la waypaper_random.sh`
3. 定时器是否激活：`systemctl --user list-timers`
4. 查看详细日志：`journalctl --user -u waypaper-random.service -n 20`