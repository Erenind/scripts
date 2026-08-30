wallpaperPath=$(swww query | cut -d ":" -f 5)
mv $wallpaperPath ~/33/wallpaper/dislikes
notify-send "wallpaper has removed to dislikes folder" -r 3323
waypaper --random

