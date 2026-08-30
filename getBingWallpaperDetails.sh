#!/bin/bash

# Script to get Bing wallpaper details in JSON format
# Usage: ./getBingWallpaperDetails.sh [-d YYYY-MM-DD]

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
    *) echo "Usage: $0 [-d YYYY-MM-DD]"; exit 1;;
  esac
done

# Validate date format if provided
if [[ -n "$DATE" ]]; then
  # Check if date matches YYYY-MM-DD format
  if ! [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo '{"error": "Invalid date format. Please use YYYY-MM-DD"}'
    exit 1
  fi
  
  # Check if date is valid
  if ! date -d "$DATE" >/dev/null 2>&1; then
    echo "{\"error\": \"Invalid date: $DATE\"}"
    exit 1
  fi
  
  # Prevent future dates (Bing doesn't have future wallpapers)
  if [[ $(date -d "$DATE" +%s) -gt $(date +%s) ]]; then
    echo '{"error": "Date cannot be in the future"}'
    exit 1
  fi
  
  # Calculate how many days ago the specified date was
  DAYS_DIFF=$(( ($(date +%s) - $(date -d "$DATE" +%s)) / 86400 ))
  # Bing only archives wallpapers for past 7 days
  if [[ $DAYS_DIFF -gt 7 ]]; then
    echo '{"error": "Bing only archives wallpapers for the past 7 days"}'
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
  echo '{"error": "Failed to fetch Bing API data"}'
  exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo '{"error": "jq tool is required to parse JSON response. Install with: sudo apt install jq (Ubuntu/Debian) or sudo yum install jq (CentOS/RHEL)"}'
  exit 1
fi

# Extract information
CHINESE_DESCRIPTION=$(echo "$JSON_RESPONSE" | jq -r '.images[0].copyright' 2>/dev/null)
TITLE=$(echo "$JSON_RESPONSE" | jq -r '.images[0].title' 2>/dev/null)
URLBASE=$(echo "$JSON_RESPONSE" | jq -r '.images[0].urlbase' 2>/dev/null)
FULL_URL="https://www.bing.com$URLBASE"

# Check if jq parsing was successful
if [ $? -ne 0 ] || [ -z "$CHINESE_DESCRIPTION" ] || [ "$CHINESE_DESCRIPTION" = "null" ]; then
  echo '{"error": "Failed to parse Bing API response"}'
  exit 1
fi

# Set the date for output
if [[ -n "$DATE" ]]; then
  OUTPUT_DATE="$DATE"
else
  OUTPUT_DATE=$(date +%Y-%m-%d)
fi

# Output in JSON format
printf '{"description": "%s", "title": "%s", "url": "%s", "date": "%s"}' \
  "$CHINESE_DESCRIPTION" "$TITLE" "$FULL_URL" "$OUTPUT_DATE"
