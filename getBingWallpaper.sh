#!/bin/bash

# Script to download and set Bing wallpapers with optional resolution and date parameters

# Default resolution if not specified (4K)
RESOLUTION="3840x2160"
# Initialize date variable (empty means today's wallpaper)
DATE=""

# Parse command line arguments:
# -r : specify resolution (default: 3840x2160)
# -d : specify date in YYYY-MM-DD format (default: today)
# -c : show Chinese description and details
while getopts "r:d:c" opt; do
  case $opt in
    # Set resolution from -r argument
    r) RESOLUTION="$OPTARG";;
    # Set date from -d argument
    d) DATE="$OPTARG";;
    # Show Chinese description
    c) SHOW_CHINESE=true;;
    # Show usage for invalid arguments
    *) echo "Usage: $0 [-r resolution] [-d YYYY-MM-DD] [-c]"; exit 1;;
  esac
done

# Validate date format if provided
if [[ -n "$DATE" ]]; then
  # Check if date matches YYYY-MM-DD format
  if ! [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Invalid date format. Please use YYYY-MM-DD"
    exit 1
  fi
  
  # Prevent future dates (Bing doesn't have future wallpapers)
  if [[ $(date -d "$DATE" +%s) -gt $(date +%s) ]]; then
    echo "Date cannot be in the future"
    exit 1
  fi
fi

# Calculate how many days ago the specified date was
if [[ -n "$DATE" ]]; then
  DAYS_DIFF=$(( ($(date +%s) - $(date -d "$DATE" +%s)) / 86400 ))
  # Bing only archives wallpapers for past 7 days
  if [[ $DAYS_DIFF -gt 7 ]]; then
    echo "Bing only archives wallpapers for the past 7 days"
    exit 1
  fi
  IDX=$DAYS_DIFF
else
  # Default to today's wallpaper (index 0)
  IDX=0
fi

# Get Bing wallpaper URL based on resolution
case $RESOLUTION in
  "1920x1080") 
    URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=$IDX&n=1&mkt=en-US"
    IMG_URL="https://www.bing.com$(curl -s $URL | jq -r '.images[0].url')"
    ;;
  "3840x2160")
    URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=$IDX&n=1&mkt=en-US&uhd=1"
    IMG_URL="https://www.bing.com$(curl -s $URL | jq -r '.images[0].url')"
    ;;
  *)
    echo "Unsupported resolution. Supported: 1920x1080, 3840x2160"
    exit 1
    ;;
esac

# Get the JSON response
JSON_RESPONSE=$(curl -s "$URL")

# Check if curl was successful
if [ $? -ne 0 ]; then
  echo "Failed to get Bing API data"
  exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "jq tool is required to parse JSON response"
  echo "On Ubuntu/Debian: sudo apt install jq"
  echo "On CentOS/RHEL: sudo yum install jq"
  exit 1
fi

# Extract wallpaper information
DESCRIPTION=$(echo "$JSON_RESPONSE" | jq -r '.images[0].copyright' | tr -cd '[:alnum:][:space:]' | tr ' ' '_' | tr -s '_')
CHINESE_DESCRIPTION=$(echo "$JSON_RESPONSE" | jq -r '.images[0].copyright' 2>/dev/null)
TITLE=$(echo "$JSON_RESPONSE" | jq -r '.images[0].title' 2>/dev/null)

# Check if jq parsing was successful
if [ $? -ne 0 ] || [ -z "$CHINESE_DESCRIPTION" ] || [ "$CHINESE_DESCRIPTION" = "null" ]; then
  echo "Failed to parse Bing API response"
  echo "Raw response:"
  echo "$JSON_RESPONSE"
  exit 1
fi

# Show Chinese description if -c flag is set
if [[ "$SHOW_CHINESE" = true ]]; then
  echo "中文描述: $CHINESE_DESCRIPTION"
  echo "标题: $TITLE"
  echo "壁纸链接: $IMG_URL"
  if [[ -n "$DATE" ]]; then
    echo "日期: $DATE"
  else
    echo "日期: $(date +%Y-%m-%d)"
  fi
  exit 0
fi

# Download and set wallpaper
TODAY=$(date +%Y-%m-%d)
if [[ -n "$DATE" ]]; then
  WALLPAPER_FILE="$HOME/33/wallpaper/wallpapers/bing_${DATE}_${DESCRIPTION}.jpg"
else
  WALLPAPER_FILE="$HOME/33/wallpaper/wallpapers/bing_${TODAY}_${DESCRIPTION}.jpg"
fi
curl -s -o "$WALLPAPER_FILE" "$IMG_URL"

# Set wallpaper using pywal
wal -i "$WALLPAPER_FILE" >/dev/null 2>&1 && swww img "$WALLPAPER_FILE" --transition-type any --transition-step 90 --transition-duration 2 --transition-fps 60

echo "Wallpaper set successfully with resolution $RESOLUTION"
echo "Saved to: $WALLPAPER_FILE"
