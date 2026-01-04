#!/bin/bash
CONFIG="$HOME/.config/waybar/config.json"
STYLE="$HOME/.config/waybar/style.css"
LOG="/tmp/waybar-launch.log"

[[ ! -f "$CONFIG" ]] && { echo "Config missing"; exit 1; }
pkill -x waybar 2>/dev/null; sleep 0.5

# Ensure a UTF-8 locale to avoid GTK fallback warnings
if locale -a 2>/dev/null | grep -qi '^es_MX\.utf8$'; then
	export LANG=es_MX.utf8
	export LC_ALL=es_MX.utf8
elif locale -a 2>/dev/null | grep -qi '^en_US\.utf8$'; then
	export LANG=en_US.utf8
	export LC_ALL=en_US.utf8
fi

RUNTIME="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
SOCKETS=("$RUNTIME"/wayland-*)
VALID=()
for s in "${SOCKETS[@]}"; do [[ -S "$s" ]] && VALID+=("$s"); done
(( ${#VALID[@]} == 0 )) && { echo "No Wayland sockets"; exit 1; }

export WAYLAND_DISPLAY="$(basename "${VALID[0]}")"
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland

echo "Launching with socket: $WAYLAND_DISPLAY"
waybar --log-level info --config "$CONFIG" --style "$STYLE" >> "$LOG" 2>&1 &
sleep 2
pgrep -x waybar && echo "Waybar OK" || { echo "FAILED"; tail -20 "$LOG"; }
