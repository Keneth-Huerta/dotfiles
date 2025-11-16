#!/bin/bash

# Simple mpvpaper starter script - uses disown to avoid signal issues
WALLPAPER_FILE="$HOME/Pictures/Wallpapers/rojo.mp4"

# Kill existing mpvpaper processes (but not this script)
pkill -f "^mpvpaper" 2>/dev/null || true
sleep 1

# Start new mpvpaper process and immediately disown it
mpvpaper --mpv-options='--loop-file --no-audio --video-unscaled=downscale-big' '*' "$WALLPAPER_FILE" >/dev/null 2>&1 & disown

# Exit quickly
exit 0
