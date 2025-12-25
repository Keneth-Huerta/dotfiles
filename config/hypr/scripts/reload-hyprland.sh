#!/bin/bash

#  Hyprland Reload Script with Red Theme 
# Reloads Hyprland and restarts background services

LOG_FILE="/tmp/hyprland-reload.log"
MAX_RETRIES=3

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if Hyprland is running
if ! pgrep -x Hyprland >/dev/null; then
    log_message " Error: Hyprland is not running"
    notify-send " Reload Failed" "Hyprland is not running" --urgency=critical
    exit 1
fi

log_message " Starting Hyprland reload process..."

# Stop mpvpaper cleanly
log_message " Stopping mpvpaper..."
~/.config/hypr/scripts/mpvpaper-manager.sh stop
sleep 1

# Reload Hyprland configuration
log_message " Reloading Hyprland configuration..."
if hyprctl reload; then
    log_message " Hyprland configuration reloaded successfully"
else
    log_message " Warning: Hyprland reload command failed"
fi

# Wait a moment for reload to complete
sleep 2

# Ensure Num Lock stays enabled after reload
if command -v numlockx &> /dev/null; then
    numlockx on
    log_message "⌨ Num Lock re-enabled"
fi

# Restart mpvpaper with retries
log_message " Restarting mpvpaper..."
for ((i=1; i<=MAX_RETRIES; i++)); do
    ~/.config/hypr/scripts/mpvpaper-manager.sh start
    sleep 2
    
    if pgrep -f mpvpaper >/dev/null; then
        log_message " mpvpaper restarted successfully on attempt $i"
        notify-send " Hyprland Reloaded" "All services restarted successfully" --urgency=low
        exit 0
    else
        log_message " mpvpaper failed to start (attempt $i/$MAX_RETRIES)"
        if [[ $i -lt $MAX_RETRIES ]]; then
            sleep 2
        fi
    fi
done

log_message " mpvpaper failed to start after $MAX_RETRIES attempts"
notify-send " Reload Warning" "Hyprland reloaded but mpvpaper may have issues" --urgency=normal
exit 1
