#!/bin/bash

# 🔴 Waybar Launch Script with Error Handling 🔴
# Properly launches Waybar with configuration validation

CONFIG_FILE="$HOME/.config/waybar/config.json"
STYLE_FILE="$HOME/.config/waybar/style.css"
LOG_FILE="/tmp/waybar-launch.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Validate configuration files exist
if [[ ! -f "$CONFIG_FILE" ]]; then
    log_message "❌ Error: Config file not found: $CONFIG_FILE"
    notify-send "Waybar Error" "Config file not found" --urgency=critical
    exit 1
fi

if [[ ! -f "$STYLE_FILE" ]]; then
    log_message "❌ Error: Style file not found: $STYLE_FILE"
    notify-send "Waybar Error" "Style file not found" --urgency=critical
    exit 1
fi

# Validate JSON syntax
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    log_message "❌ Error: Invalid JSON in config file"
    notify-send "Waybar Error" "Invalid JSON configuration" --urgency=critical
    exit 1
fi

# Kill existing Waybar instances
if pgrep -x waybar >/dev/null; then
    log_message "🛑 Stopping existing Waybar instances..."
    pkill -x waybar
    sleep 1
fi

# Launch Waybar
log_message "Launching Waybar..."
waybar --config "$CONFIG_FILE" --style "$STYLE_FILE" >> "$LOG_FILE" 2>&1 &

# Verify launch
sleep 2
if pgrep -x waybar >/dev/null; then
    log_message "✅ Waybar launched successfully"
    notify-send "🔴 Waybar" "Launched successfully" --urgency=low
else
    log_message "❌ Failed to launch Waybar"
    notify-send "Waybar Error" "Failed to start - check logs" --urgency=critical
    exit 1
fi
