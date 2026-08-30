#!/bin/bash

# Script to get Bing wallpaper Chinese description
# Usage: ./getBingWallpaperCN.sh [-d YYYY-MM-DD]

# Default to today's wallpaper
DATE=""
IDX=0

# Parse command line arguments:
# -d : specify date in YYYY-MM-DD format (default: today)
while getopts "d:" opt; do
  case $opt in
    # Set date from -d argument
    d) DATE="$OPTARG";;
    # Show usage for invalid arguments
    *) echo "用法: $0 [-d YYYY-MM-DD]"; exit 1;;
  esac
done

# Validate date format if provided
if [[ -n "$DATE" ]]; then
  # Check if date matches YYYY-MM-DD format
  if ! [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "无效的日期格式。请使用 YYYY-MM-DD 格式"
    exit 1
  fi
  
  # Check if date is valid
  if ! date -d "$DATE" >/dev/null 2>&1; then
    echo "无效的日期: $DATE"
    exit 1
  fi
  
  # Prevent future dates (Bing doesn't have future wallpapers)
  if [[ $(date -d "$DATE" +%s) -gt $(date +%s) ]]; then
    echo "日期不能是未来日期"
    exit 1
  fi
  
  # Calculate how many days ago the specified date was
  DAYS_DIFF=$(( ($(date +%s) - $(date -d "$DATE" +%s)) / 86400 ))
  # Bing only archives wallpapers for past 7 days
  if [[ $DAYS_DIFF -gt 7 ]]; then
    echo "Bing 只存档过去7天的壁纸"
    exit 1
  fi
  IDX=$DAYS_DIFF
fi

# Get Bing wallpaper information with Chinese locale
URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=$IDX&n=1&mkt=zh-CN"

# Get the JSON response
JSON_RESPONSE=$(curl -s "$URL")

# Check if curl was successful
if [ $? -ne 0 ]; then
  echo "获取Bing API数据失败"
  exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "需要安装 jq 工具来解析JSON响应"
  echo "在Ubuntu/Debian上可以使用: sudo apt install jq"
  echo "在CentOS/RHEL上可以使用: sudo yum install jq"
  exit 1
fi

# Extract Chinese description
CHINESE_DESCRIPTION=$(echo "$JSON_RESPONSE" | jq -r '.images[0].copyright' 2>/dev/null)

# Check if jq parsing was successful
if [ $? -ne 0 ] || [ -z "$CHINESE_DESCRIPTION" ] || [ "$CHINESE_DESCRIPTION" = "null" ]; then
  echo "解析Bing API响应失败"
  echo "原始响应:"
  echo "$JSON_RESPONSE"
  exit 1
fi

# Extract additional information
TITLE=$(echo "$JSON_RESPONSE" | jq -r '.images[0].title' 2>/dev/null)
URLBASE=$(echo "$JSON_RESPONSE" | jq -r '.images[0].urlbase' 2>/dev/null)
FULL_URL="https://www.bing.com$URLBASE"

# Output the Chinese description
echo "中文描述: $CHINESE_DESCRIPTION"
echo "标题: $TITLE"
echo "壁纸链接: $FULL_URL"

# If date was specified, show it
if [[ -n "$DATE" ]]; then
  echo "日期: $DATE"
else
  echo "日期: $(date +%Y-%m-%d)"
fi
