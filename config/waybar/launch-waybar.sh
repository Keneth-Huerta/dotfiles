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
log_message "🚀 Launching Waybar (dynamic socket detection)..."

# Wayland environment discovery
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
CURRENT_DISPLAY="$WAYLAND_DISPLAY"
SOCKETS=("${RUNTIME_DIR}"/wayland-*)
VALID_SOCKETS=()
for s in "${SOCKETS[@]}"; do [[ -S "$s" ]] && VALID_SOCKETS+=("$s"); done

if [[ -z "$CURRENT_DISPLAY" || ! -S "${RUNTIME_DIR}/$CURRENT_DISPLAY" ]]; then
    if (( ${#VALID_SOCKETS[@]} > 0 )); then
        PICKED="$(basename "${VALID_SOCKETS[0]}")"
        export WAYLAND_DISPLAY="$PICKED"
        log_message "🔍 Selected available Wayland socket: $PICKED"
    else
        log_message "❌ No Wayland sockets found in $RUNTIME_DIR"
        notify-send "Waybar Error" "No Wayland sockets in $RUNTIME_DIR" --urgency=critical
        exit 1
    fi
else
    export WAYLAND_DISPLAY="$CURRENT_DISPLAY"
    log_message "✅ Using existing WAYLAND_DISPLAY=$CURRENT_DISPLAY"
fi

export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland

SOCKET_PATH="${RUNTIME_DIR}/$WAYLAND_DISPLAY"
if [[ ! -S "$SOCKET_PATH" ]]; then
    log_message "❌ Final socket missing: $SOCKET_PATH"
    notify-send "Waybar Error" "Socket not found: $SOCKET_PATH" --urgency=critical
    exit 1
fi

log_message "ℹ️ Environment: WAYLAND_DISPLAY=$WAYLAND_DISPLAY RUNTIME_DIR=$RUNTIME_DIR"
log_message "ℹ️ Launch command: waybar --log-level trace --config $CONFIG_FILE --style $STYLE_FILE"

WAYBAR_LOG_LEVEL=trace waybar --log-level trace --config "$CONFIG_FILE" --style "$STYLE_FILE" >> "$LOG_FILE" 2>&1 &

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
