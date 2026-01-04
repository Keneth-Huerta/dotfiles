#!/bin/bash

# 🔌 Monitor Hotplug Handler
# Automatically configures monitors when they are connected/disconnected

LOG_FILE="/tmp/monitor-hotplug.log"
MONITOR_MANAGER="/home/valge/.config/hypr/scripts/monitor-manager.sh"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to wait for Hyprland to be ready
wait_for_hyprland() {
    local timeout=10
    local count=0
    
    while ! hyprctl monitors >/dev/null 2>&1; do
        sleep 1
        count=$((count + 1))
        if [[ $count -gt $timeout ]]; then
            log_message "⚠️ Timeout waiting for Hyprland"
            return 1
        fi
    done
    return 0
}

# Main hotplug logic
handle_monitor_change() {
    log_message "🔌 Monitor change detected"
    
    # Wait a bit for the system to stabilize
    sleep 2
    
    # Ensure Hyprland is ready
    if ! wait_for_hyprland; then
        log_message "❌ Hyprland not available"
        exit 1
    fi
    
    # Auto-configure monitors
    if [[ -x "$MONITOR_MANAGER" ]]; then
        log_message "🖥️ Running auto-configuration..."
        "$MONITOR_MANAGER" auto >> "$LOG_FILE" 2>&1
        log_message "✅ Monitor configuration completed"
    else
        log_message "❌ Monitor manager script not found or not executable"
    fi
}

# Handle the event
if [[ "$1" == "change" ]]; then
    handle_monitor_change
else
    log_message "🔍 Hotplug event: $1 (ignored)"
fi
