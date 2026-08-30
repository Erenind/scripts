updates_arch=$(checkupdates 2> /dev/null | wc -l)
updates_aur=$(trizen -Su --aur --quiet | wc -l)

updates=$(("$updates_arch" + "$updates_aur"))

# updateslist_arch=$(checkupdates)

# 获取 AUR 更新并存储为字符串
# updateslist_aur=$(trizen -Su --aur --quiet 2>&1)

# 检查是否为空（无更新或出错）
# if [[ -z "$updateslist_arch" ]] && [[ -z "$updateslist_aur" ]]; then
#     echo "无更新"
# else
    # 统计更新数量
#    echo "发现 $updates_arch 个包更新："
#    echo "$updateslist_arch"
#    echo "发现 $updates_aur 个AUR更新："
#    echo "$updateslist_aur"
#fi

# updates_list=$(~/33/code/sh/showUpgrades.sh)
updates_list_arch=$(checkupdates | tr "\n" "\r")
updates_list_aur=$(trizen -Su --aur --quiet | awk -F' *==> *|: +' '{gsub(/^[[:space:]]*[0-9]+\.[[:space:]]*/, "", $1); print $1 " " $2 " -> " $3}' | tr "\n" "\r" | sed 's/\r$//; /^$/d')
updates_list="Packages Updates(${updates_arch}):\r${updates_list_arch}\rAur Updates(${updates_aur}):\r${updates_list_aur}"

if [ "$updates" -lt 100 ]; then
  font_color="ok"
else
  font_color="bad"
fi

printf '{"text": "%s","alt": "%s","tooltip": "%s","class": "%s"}' "$updates" "$updates" "$updates_list" "$font_color"
