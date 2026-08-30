#!/bin/bash

OUTPUT_FILE="/home/kyee/33/obsidian/store/code-time.md"
START_LINE=0

timestamp() {
  date +%s%3N
}

update_end() {
  local ts=$(timestamp)
  if [ "$START_LINE" -gt 0 ]; then
    head -n $((START_LINE + 1)) "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp"
    echo "end $ts" >> "${OUTPUT_FILE}.tmp"
    echo "" >> "${OUTPUT_FILE}.tmp"
    mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
  fi
}

cleanup() {
  update_end
  exit 0
}

trap cleanup SIGINT SIGTERM EXIT

echo "" >> "$OUTPUT_FILE"
echo "start $(timestamp)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "end $(timestamp)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

START_LINE=$(grep -n "^start " "$OUTPUT_FILE" | tail -1 | cut -d: -f1)

while true; do
  sleep 3
  update_end
done
