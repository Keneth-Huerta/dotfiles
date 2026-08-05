#!/bin/bash

# 🔴 Waybar Launch Script (Optimizado)
# Limpio, rápido y sin logs masivos

CONFIG_FILE="$HOME/.config/waybar/config.json"
STYLE_FILE="$HOME/.config/waybar/style.css"
LOG_FILE="/tmp/waybar.log"

# Kill existing waybar
if pgrep -x waybar >/dev/null 2>&1; then
    pkill -x waybar
    sleep 0.5
fi

# Validate files
if [[ ! -f "$CONFIG_FILE" ]]; then
    notify-send "Waybar Error" "Config no encontrado" --urgency=critical
    exit 1
fi

if [[ ! -f "$STYLE_FILE" ]]; then
    notify-send "Waybar Error" "Style no encontrado" --urgency=critical
    exit 1
fi

# Validate JSON
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    notify-send "Waybar Error" "JSON inválido en config" --urgency=critical
    exit 1
fi

# Launch with minimal logging (suppress known GTK warnings)
G_MESSAGES_DEBUG=none waybar --config "$CONFIG_FILE" --style "$STYLE_FILE" 2>/dev/null >> "$LOG_FILE" 2>&1 &

sleep 1
if pgrep -x waybar >/dev/null 2>&1; then
    notify-send "🔴 Waybar" "Iniciado correctamente" --urgency=low
else
    notify-send "Waybar Error" "Fallo al iniciar - revisa /tmp/waybar.log" --urgency=critical
    exit 1
fi
