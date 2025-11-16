#!/bin/bash

# 🚀 Auto-start script for monitor configuration
# This script runs when Hyprland starts to auto-configure monitors

LOG_FILE="/tmp/hyprland-autostart.log"
MONITOR_MANAGER="$HOME/.config/hypr/scripts/monitor-manager.sh"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Wait for Hyprland to be fully loaded
sleep 3

log_message "🚀 Hyprland auto-start: Configuring monitors..."

# Check if monitor manager exists and is executable
if [[ -x "$MONITOR_MANAGER" ]]; then
    # Auto-configure monitors
    "$MONITOR_MANAGER" auto >> "$LOG_FILE" 2>&1
    log_message "✅ Monitor auto-configuration completed"
else
    log_message "❌ Monitor manager not found: $MONITOR_MANAGER"
fi

# Optional: Start additional services here
# log_message "🎵 Starting additional services..."

log_message "🏁 Auto-start script completed"
