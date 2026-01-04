#!/bin/bash
set -euo pipefail
CONFIG_FILE="$HOME/.config/waybar/config.min.json"
STYLE_FILE="$HOME/.config/waybar/style.min.css"
LOG_FILE="/tmp/waybar-launch.log"
log(){ echo "$(date '+%Y-%m-%d %H:%M:%S') - [mini] $*" | tee -a "$LOG_FILE"; }

log "Launching Waybar minimal..."
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
SOCKETS=("${RUNTIME_DIR}"/wayland-*)
for s in "${SOCKETS[@]}"; do if [[ -S "$s" ]]; then export WAYLAND_DISPLAY="$(basename "$s")"; break; fi; done
if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then log "No Wayland sockets in $RUNTIME_DIR"; exit 1; fi
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland

WAYBAR_LOG_LEVEL=trace waybar --log-level trace --config "$CONFIG_FILE" --style "$STYLE_FILE" >> "$LOG_FILE" 2>&1 &
sleep 2
pgrep -x waybar >/dev/null && log "Waybar minimal OK" || { log "Waybar minimal FAILED"; exit 1; }
