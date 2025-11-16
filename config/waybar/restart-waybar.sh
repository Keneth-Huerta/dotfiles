#!/bin/bash

# 🔴 Waybar Restart Script 🔴
# Gracefully restarts Waybar with proper cleanup

LOG_FILE="/tmp/waybar-restart.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_message "🔄 Restarting Waybar..."

# Graceful shutdown
if pgrep -x waybar >/dev/null; then
    log_message "🛑 Stopping Waybar..."
    pkill -TERM waybar
    sleep 2
    
    # Force kill if still running
    if pgrep -x waybar >/dev/null; then
        log_message "⚠️ Force killing Waybar..."
        pkill -KILL waybar
        sleep 1
    fi
fi

# Launch Waybar using the launch script
if [[ -x "$HOME/.config/waybar/launch-waybar.sh" ]]; then
    "$HOME/.config/waybar/launch-waybar.sh"
else
    log_message "⚠️ Launch script not found, using direct command..."
    waybar --config "$HOME/.config/waybar/config.json" --style "$HOME/.config/waybar/style.css" >> "$LOG_FILE" 2>&1 &
fi

log_message "✅ Waybar restart completed"
