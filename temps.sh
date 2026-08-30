for dev in /sys/class/thermal/cooling_device*; do
    if [ -f "$dev/type" ]; then
        name=$(basename "$dev")
        type=$(cat "$dev/type")
        cur=$(cat "$dev/cur_state" 2>/dev/null || echo "0")
        max=$(cat "$dev/max_state" 2>/dev/null || echo "0")

        if [ "$cur" -gt 0 ] 2>/dev/null; then
            status="🔥 开启/生效中 (等级: $cur / 最大: $max)"
        else
            status="💤 未触发/空闲 ($cur / $max)"
        fi

        printf "%-16s | %-20s | %s\n" "$name" "$type" "$status"
    fi
done