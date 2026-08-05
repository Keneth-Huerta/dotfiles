#!/bin/bash

LOG_FILE="/tmp/monitor-manager.log"
CONFIG_DIR="$HOME/.config/hypr"
LOCKFILE="/tmp/monitor-manager.lock"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

is_hyprland_running() {
    pgrep -x Hyprland >/dev/null 2>&1
}

check_dependencies() {
    local missing_deps=()

    if ! command -v hyprctl &> /dev/null; then
        missing_deps+=("hyprctl")
    fi

    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_message "Missing dependencies: ${missing_deps[*]}"
        echo -e "${RED}Missing dependencies: ${missing_deps[*]}${NC}"
        return 1
    fi

    if ! is_hyprland_running; then
        log_message "Hyprland is not running"
        echo -e "${RED}Hyprland is not running${NC}"
        return 1
    fi

    return 0
}

acquire_lock() {
    exec 200>"$LOCKFILE"
    if ! flock -n 200; then
        log_message "Another monitor manager instance is running, aborting"
        echo -e "${YELLOW}Another instance is running, try again later${NC}"
        return 1
    fi
    return 0
}

release_lock() {
    flock -u 200 2>/dev/null
    rm -f "$LOCKFILE"
}

get_monitors() {
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || hyprctl monitors | grep -oP '^Monitor \K[^ ]+(?= \(ID)'
}

is_monitor_connected() {
    local monitor_name="$1"
    hyprctl monitors -j 2>/dev/null | jq -e --arg name "$monitor_name" '.[] | select(.name == $name)' >/dev/null 2>&1
}

get_primary_monitor() {
    if is_monitor_connected "eDP-1"; then
        echo "eDP-1"
    elif is_monitor_connected "LVDS-1"; then
        echo "LVDS-1"
    else
        get_monitors | head -n1
    fi
}

get_secondary_monitor() {
    local primary=$(get_primary_monitor)
    get_monitors | grep -v "^$primary$" | head -n1
}

configure_single_monitor() {
    local primary=$(get_primary_monitor)
    local secondary="HDMI-A-1"
    log_message "Configuring single monitor: $primary"

    hyprctl keyword monitor "$primary,preferred,auto,1"

    local existing_workspaces
    existing_workspaces=$(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' 2>/dev/null)
    for ws in $existing_workspaces; do
        if [[ "$ws" -gt 0 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$ws" "$primary" 2>/dev/null || true
        fi
    done

    for i in {1..5}; do
        hyprctl keyword workspace "$i,monitor:$primary"
    done

    for i in {6..10}; do
        hyprctl keyword workspace "$i,monitor:$secondary"
    done

    hyprctl keyword workspace "1,monitor:$primary,default:true"
    hyprctl keyword workspace "6,monitor:$secondary,default:true"

    cat > "$CONFIG_DIR/monitors.conf" << EOF
# Auto-generated - Single Monitor
monitor=$primary,preferred,auto,1

workspace = 1, monitor:$primary, default:true
workspace = 2, monitor:$primary
workspace = 3, monitor:$primary
workspace = 4, monitor:$primary
workspace = 5, monitor:$primary
workspace = 6, monitor:$secondary, default:true
workspace = 7, monitor:$secondary
workspace = 8, monitor:$secondary
workspace = 9, monitor:$secondary
workspace = 10, monitor:$secondary
EOF

    log_message "Single monitor setup completed"
}

configure_dual_monitors() {
    local primary=$(get_primary_monitor)
    local secondary=$(get_secondary_monitor)
    local position="${1:-left}"

    if [[ -z "$secondary" ]]; then
        log_message "No secondary monitor found, falling back to single"
        configure_single_monitor
        return
    fi

    log_message "Configuring dual monitors: $primary + $secondary (position: $position)"

    if [[ "$position" == "left" ]]; then
        hyprctl keyword monitor "$secondary,preferred,0x0,1"
        hyprctl keyword monitor "$primary,preferred,auto,1"
    else
        hyprctl keyword monitor "$primary,preferred,0x0,1"
        hyprctl keyword monitor "$secondary,preferred,auto,1"
    fi

    for i in {1..5}; do
        hyprctl keyword workspace "$i,monitor:$primary"
    done

    for i in {6..10}; do
        hyprctl keyword workspace "$i,monitor:$secondary"
    done

    hyprctl keyword workspace "1,monitor:$primary,default:true"
    hyprctl keyword workspace "6,monitor:$secondary,default:true"

    local existing_workspaces
    existing_workspaces=$(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' 2>/dev/null)
    for ws in $existing_workspaces; do
        if [[ "$ws" -ge 1 && "$ws" -le 5 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$ws" "$primary" 2>/dev/null || true
        elif [[ "$ws" -ge 6 && "$ws" -le 10 ]]; then
            hyprctl dispatch moveworkspacetomonitor "$ws" "$secondary" 2>/dev/null || true
        fi
    done

    if [[ "$position" == "left" ]]; then
        cat > "$CONFIG_DIR/monitors.conf" << EOF
# Auto-generated - Dual Monitor (Secondary Left)
monitor=$secondary,preferred,0x0,1
monitor=$primary,preferred,auto,1

workspace = 1, monitor:$primary, default:true
workspace = 2, monitor:$primary
workspace = 3, monitor:$primary
workspace = 4, monitor:$primary
workspace = 5, monitor:$primary
workspace = 6, monitor:$secondary, default:true
workspace = 7, monitor:$secondary
workspace = 8, monitor:$secondary
workspace = 9, monitor:$secondary
workspace = 10, monitor:$secondary
EOF
    else
        cat > "$CONFIG_DIR/monitors.conf" << EOF
# Auto-generated - Dual Monitor (Secondary Right)
monitor=$primary,preferred,0x0,1
monitor=$secondary,preferred,auto,1

workspace = 1, monitor:$primary, default:true
workspace = 2, monitor:$primary
workspace = 3, monitor:$primary
workspace = 4, monitor:$primary
workspace = 5, monitor:$primary
workspace = 6, monitor:$secondary, default:true
workspace = 7, monitor:$secondary
workspace = 8, monitor:$secondary
workspace = 9, monitor:$secondary
workspace = 10, monitor:$secondary
EOF
    fi

    local current_workspace=$(hyprctl activewindow -j | jq -r '.workspace.id' 2>/dev/null || echo "1")
    if [[ "$current_workspace" -gt 5 ]]; then
        hyprctl dispatch workspace 6
    else
        hyprctl dispatch workspace 1
    fi

    log_message "Dual monitor setup completed"
}

auto_configure() {
    local no_reload=false
    [[ "$1" == "--no-reload" ]] && no_reload=true

    if ! check_dependencies >/dev/null 2>&1; then
        return 1
    fi

    if ! acquire_lock; then
        return 1
    fi

    local monitors
    monitors=$(get_monitors)
    local monitor_count=$(echo "$monitors" | grep -c .)

    log_message "Detected $monitor_count monitor(s)"
    echo "$monitors" | while read -r monitor; do
        [[ -n "$monitor" ]] && log_message "  $monitor"
    done

    if [[ $monitor_count -eq 1 ]]; then
        configure_single_monitor
    elif [[ $monitor_count -ge 2 ]]; then
        configure_dual_monitors
    else
        log_message "No monitors detected!"
        release_lock
        return 1
    fi

    if [[ -x "$CONFIG_DIR/scripts/mpvpaper-manager.sh" ]]; then
        log_message "Restarting wallpaper..."
        "$CONFIG_DIR/scripts/mpvpaper-manager.sh" restart >/dev/null 2>&1 &
    fi

    if ! $no_reload; then
        hyprctl reload
    fi

    release_lock
    return 0
}

show_status() {
    if ! check_dependencies >/dev/null 2>&1; then
        return 1
    fi

    echo -e "${CYAN}Monitor Manager Status${NC}"
    echo -e "${YELLOW}========================${NC}"

    local monitors
    monitors=$(get_monitors)
    local monitor_count=$(echo "$monitors" | grep -c .)

    echo -e "${BLUE}Connected monitors: ${GREEN}$monitor_count${NC}"

    echo "$monitors" | while read -r monitor; do
        [[ -z "$monitor" ]] && continue
        local focused=$(hyprctl monitors -j | jq -r --arg name "$monitor" '.[] | select(.name == $name) | .focused' 2>/dev/null)
        local workspace=$(hyprctl monitors -j | jq -r --arg name "$monitor" '.[] | select(.name == $name) | .activeWorkspace.name' 2>/dev/null)

        if [[ "$focused" == "true" ]]; then
            echo -e "  ${GREEN}$monitor${NC} (focused) - workspace $workspace"
        else
            echo -e "  ${YELLOW}$monitor${NC} - workspace $workspace"
        fi
    done

    echo ""
    echo -e "${PURPLE}Workspace Distribution:${NC}"
    if [[ $monitor_count -eq 1 ]]; then
        echo -e "  Single monitor: workspaces 1-10"
    else
        local primary=$(get_primary_monitor)
        local secondary=$(get_secondary_monitor)
        echo -e "  ${GREEN}$primary${NC} (primary): workspaces 1-5"
        echo -e "  ${YELLOW}$secondary${NC} (secondary): workspaces 6-10"
    fi
}

toggle_mode() {
    local monitor_count=$(echo "$(get_monitors)" | grep -c .)

    if [[ $monitor_count -eq 1 ]]; then
        echo -e "${YELLOW}Only one monitor detected, cannot toggle${NC}"
        return 1
    else
        echo -e "${BLUE}Toggling monitor configuration...${NC}"
        auto_configure
    fi
}

move_workspace_to_monitor() {
    local workspace="$1"
    local monitor="$2"

    if [[ -z "$workspace" || -z "$monitor" ]]; then
        echo "Usage: move_workspace_to_monitor <workspace_id> <monitor_name>"
        return 1
    fi

    if ! is_monitor_connected "$monitor"; then
        echo -e "${RED}Monitor $monitor is not connected${NC}"
        return 1
    fi

    log_message "Moving workspace $workspace to $monitor"
    hyprctl keyword workspace "$workspace,monitor:$monitor"
    echo -e "${GREEN}Workspace $workspace moved to $monitor${NC}"
}

show_help() {
    echo -e "${CYAN}Monitor Manager for Hyprland${NC}"
    echo -e "${YELLOW}=================================${NC}"
    echo ""
    echo -e "${GREEN}Usage:${NC} $0 {auto|status|toggle|single|dual|dual-left|dual-right|move|help}"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo -e "  ${GREEN}auto${NC}       - Auto-detect and configure monitors"
    echo -e "  ${GREEN}status${NC}     - Show current monitor status"
    echo -e "  ${GREEN}toggle${NC}     - Toggle between single/dual monitor mode"
    echo -e "  ${GREEN}single${NC}     - Force single monitor configuration"
    echo -e "  ${GREEN}dual${NC}       - Force dual monitor (secondary on left)"
    echo -e "  ${GREEN}dual-left${NC}  - Dual monitor with secondary on left"
    echo -e "  ${GREEN}dual-right${NC} - Dual monitor with secondary on right"
    echo -e "  ${GREEN}move${NC}       - Move workspace to monitor"
    echo -e "  ${GREEN}help${NC}       - Show this help"
    echo ""
    echo -e "${PURPLE}Examples:${NC}"
    echo -e "  $0 auto              # Auto-configure"
    echo -e "  $0 dual-left         # Dual with secondary left"
    echo -e "  $0 status            # Show current setup"
}

case "$1" in
    auto)
        auto_configure "$2"
        ;;
    status)
        show_status
        ;;
    toggle)
        toggle_mode
        ;;
    single)
        configure_single_monitor
        ;;
    dual)
        if [[ $(echo "$(get_monitors)" | grep -c .) -lt 2 ]]; then
            echo -e "${RED}Dual monitor requires 2+ connected monitors${NC}"
            exit 1
        fi
        configure_dual_monitors "left"
        ;;
    dual-left)
        if [[ $(echo "$(get_monitors)" | grep -c .) -lt 2 ]]; then
            echo -e "${RED}Dual monitor requires 2+ connected monitors${NC}"
            exit 1
        fi
        configure_dual_monitors "left"
        ;;
    dual-right)
        if [[ $(echo "$(get_monitors)" | grep -c .) -lt 2 ]]; then
            echo -e "${RED}Dual monitor requires 2+ connected monitors${NC}"
            exit 1
        fi
        configure_dual_monitors "right"
        ;;
    move)
        echo -e "${CYAN}Interactive Workspace Movement${NC}"
        echo -e "${YELLOW}Available monitors:${NC}"
        get_monitors | nl -w2 -s'. '
        echo ""
        read -p "Enter workspace number (1-10): " workspace
        read -p "Enter monitor name: " monitor
        move_workspace_to_monitor "$workspace" "$monitor"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Invalid option: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
