#!/bin/bash

updates_arch=$(checkupdates)

# 获取 AUR 更新并存储为字符串
updates_aur=$(trizen -Su --aur --quiet 2>&1)

# 检查是否为空（无更新或出错）
if [[ -z "$updates_arch" ]] && [[ -z "$updates_aur" ]]; then
    echo "无更新"
else
    # 统计更新数量
    count_arch=$(echo "$updates_arch" | wc -l)
    count_aur=$(echo "$updates_aur" | wc -l)
    echo "发现 $count_arch 个包更新："
    echo "$updates_arch"
    echo "发现 $count_aur 个AUR更新："
    echo "$updates_aur"
fi
