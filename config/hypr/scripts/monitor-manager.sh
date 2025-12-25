#!/bin/bash

#  Monitor Manager for Hyprland
# Automatic dual monitor setup and workspace configuration

LOG_FILE="/tmp/monitor-manager.log"
CONFIG_DIR="$HOME/.config/hypr"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if Hyprland is running
is_hyprland_running() {
    pgrep -x Hyprland >/dev/null 2>&1
}

# Function to validate dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v hyprctl &> /dev/null; then
        missing_deps+=("hyprctl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_message " Error: Missing dependencies: ${missing_deps[*]}"
        echo -e "${RED} Missing dependencies: ${missing_deps[*]}${NC}"
        return 1
    fi
    
    if ! is_hyprland_running; then
        log_message " Error: Hyprland is not running"
        echo -e "${RED} Hyprland is not running${NC}"
        return 1
    fi
    
    return 0
}

# Function to get connected monitors
get_monitors() {
    if ! check_dependencies >/dev/null 2>&1; then
        return 1
    fi
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || hyprctl monitors | grep -oP '^Monitor \K[^ ]+(?= \(ID)'
}

# Function to check if a specific monitor is connected
is_monitor_connected() {
    local monitor_name="$1"
    get_monitors | grep -q "^$monitor_name$"
}

# Function to get primary monitor (usually eDP-1 for laptops)
get_primary_monitor() {
    # Try to find laptop screen first, then fallback to first monitor
    if is_monitor_connected "eDP-1"; then
        echo "eDP-1"
    elif is_monitor_connected "LVDS-1"; then
        echo "LVDS-1"
    else
        get_monitors | head -n1
    fi
}

# Function to get secondary monitor
get_secondary_monitor() {
    local primary=$(get_primary_monitor)
    get_monitors | grep -v "^$primary$" | head -n1
}

# Function to configure single monitor setup
configure_single_monitor() {
    local primary=$(get_primary_monitor)
    log_message " Configuring single monitor setup: $primary"
    
    # Configure primary monitor
    hyprctl keyword monitor "$primary,1920x1080@60,0x0,1"
    
    # Move all workspaces to primary monitor
    for i in {1..10}; do
        hyprctl keyword workspace "$i,monitor:$primary"
    done
    
    # Update workspace configuration
    cat > "$CONFIG_DIR/monitors.conf" << EOF
# Auto-generated monitor configuration - Single Monitor
monitor=$primary,1920x1080@60,0x0,1
monitor=,disabled

# Workspace assignments for single monitor
workspace = 1, monitor:$primary, default:true
workspace = 2, monitor:$primary
workspace = 3, monitor:$primary
workspace = 4, monitor:$primary
workspace = 5, monitor:$primary
workspace = 6, monitor:$primary
workspace = 7, monitor:$primary
workspace = 8, monitor:$primary
workspace = 9, monitor:$primary
workspace = 10, monitor:$primary
EOF
    
    log_message " Single monitor setup completed"
}

# Function to configure dual monitor setup
configure_dual_monitors() {
    local primary=$(get_primary_monitor)
    local secondary=$(get_secondary_monitor)
    local position="${1:-left}"  # Default to LEFT instead of right
    
    log_message " Configuring dual monitor setup: $primary (primary) + $secondary (secondary) - Position: $position"
    
    # Configure monitors based on position
    if [[ "$position" == "left" ]]; then
        # Secondary monitor on the left
        hyprctl keyword monitor "$secondary,1920x1080@60,0x0,1"
        hyprctl keyword monitor "$primary,1920x1080@60,1920x0,1"
    else
        # Secondary monitor on the right (default)
        hyprctl keyword monitor "$primary,1920x1080@60,0x0,1"
        hyprctl keyword monitor "$secondary,1920x1080@60,1920x0,1"
    fi
    
    # Configure workspaces for dual monitor
    # Primary monitor: workspaces 1-5
    for i in {1..5}; do
        hyprctl keyword workspace "$i,monitor:$primary"
    done
    
    # Secondary monitor: workspaces 6-10
    for i in {6..10}; do
        hyprctl keyword workspace "$i,monitor:$secondary"
    done
    
    # Set default workspaces
    hyprctl keyword workspace "1,monitor:$primary,default:true"
    hyprctl keyword workspace "6,monitor:$secondary,default:true"
    
    # Update monitor configuration file
    if [[ "$position" == "left" ]]; then
        cat > "$CONFIG_DIR/monitors.conf" << EOF
# Auto-generated monitor configuration - Dual Monitor (Secondary on Left)
monitor=$secondary,1920x1080@60,0x0,1
monitor=$primary,1920x1080@60,1920x0,1

# Workspace assignments for dual monitor
# Primary monitor ($primary): workspaces 1-5
workspace = 1, monitor:$primary, default:true
workspace = 2, monitor:$primary
workspace = 3, monitor:$primary
workspace = 4, monitor:$primary
workspace = 5, monitor:$primary

# Secondary monitor ($secondary): workspaces 6-10
workspace = 6, monitor:$secondary, default:true
workspace = 7, monitor:$secondary
workspace = 8, monitor:$secondary
workspace = 9, monitor:$secondary
workspace = 10, monitor:$secondary
EOF
    else
        cat > "$CONFIG_DIR/monitors.conf" << EOF
# Auto-generated monitor configuration - Dual Monitor (Secondary on Right)
monitor=$primary,1920x1080@60,0x0,1
monitor=$secondary,1920x1080@60,1920x0,1

# Workspace assignments for dual monitor
# Primary monitor ($primary): workspaces 1-5
workspace = 1, monitor:$primary, default:true
workspace = 2, monitor:$primary
workspace = 3, monitor:$primary
workspace = 4, monitor:$primary
workspace = 5, monitor:$primary

# Secondary monitor ($secondary): workspaces 6-10
workspace = 6, monitor:$secondary, default:true
workspace = 7, monitor:$secondary
workspace = 8, monitor:$secondary
workspace = 9, monitor:$secondary
workspace = 10, monitor:$secondary
EOF
    fi
    
    # Move to appropriate workspaces if currently active
    current_workspace=$(hyprctl activewindow -j | jq -r '.workspace.id' 2>/dev/null || echo "1")
    if [[ "$current_workspace" -gt 5 ]]; then
        # If on workspace 6-10, move to secondary monitor
        hyprctl dispatch workspace 6
    else
        # If on workspace 1-5, stay on primary monitor
        hyprctl dispatch workspace 1
    fi
    
    log_message " Dual monitor setup completed"
}

# Function to detect and auto-configure monitors
auto_configure() {
    local monitor_count=$(get_monitors | wc -l)
    
    log_message " Detecting monitors... Found: $monitor_count"
    get_monitors | while read monitor; do
        log_message "   $monitor"
    done
    
    if [[ $monitor_count -eq 1 ]]; then
        configure_single_monitor
    elif [[ $monitor_count -ge 2 ]]; then
        configure_dual_monitors
    else
        log_message " No monitors detected!"
        return 1
    fi
    
    # Restart wallpaper if available
    if [[ -f "$CONFIG_DIR/scripts/mpvpaper-manager.sh" ]]; then
        log_message " Restarting wallpaper..."
        "$CONFIG_DIR/scripts/mpvpaper-manager.sh" restart >/dev/null 2>&1
    fi
    
    # Refresh Hyprland
    hyprctl reload
    
    return 0
}

# Function to show monitor status
show_status() {
    echo -e "${CYAN} Monitor Manager Status${NC}"
    echo -e "${YELLOW}========================${NC}"
    
    local monitor_count=$(get_monitors | wc -l)
    echo -e "${BLUE}Connected monitors: ${GREEN}$monitor_count${NC}"
    
    get_monitors | while read monitor; do
        local status=$(hyprctl monitors | grep -A10 "^Monitor $monitor" | grep "focused:" | awk '{print $2}')
        local workspace=$(hyprctl monitors | grep -A10 "^Monitor $monitor" | grep "active workspace:" | awk '{print $3}')
        
        if [[ "$status" == "yes" ]]; then
            echo -e "   ${GREEN}$monitor${NC} (focused) - workspace $workspace"
        else
            echo -e "   ${YELLOW}$monitor${NC} - workspace $workspace"
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
    
    echo ""
    echo -e "${CYAN}Configuration file: ${NC}$CONFIG_DIR/monitors.conf"
    echo -e "${CYAN}Log file: ${NC}$LOG_FILE"
}

# Function to toggle between single and dual monitor mode
toggle_mode() {
    local monitor_count=$(get_monitors | wc -l)
    
    if [[ $monitor_count -eq 1 ]]; then
        echo -e "${YELLOW} Only one monitor detected. Cannot toggle to dual mode.${NC}"
        echo -e "${CYAN} Connect a second monitor and run 'auto' mode.${NC}"
        return 1
    else
        echo -e "${BLUE} Toggling monitor configuration...${NC}"
        auto_configure
    fi
}

# Function to move workspace to specific monitor
move_workspace_to_monitor() {
    local workspace="$1"
    local monitor="$2"
    
    if [[ -z "$workspace" || -z "$monitor" ]]; then
        echo "Usage: move_workspace_to_monitor <workspace_id> <monitor_name>"
        return 1
    fi
    
    if ! is_monitor_connected "$monitor"; then
        echo -e "${RED} Monitor $monitor is not connected${NC}"
        return 1
    fi
    
    log_message " Moving workspace $workspace to monitor $monitor"
    hyprctl keyword workspace "$workspace,monitor:$monitor"
    echo -e "${GREEN} Workspace $workspace moved to $monitor${NC}"
}

# Help function
show_help() {
    echo -e "${CYAN} Monitor Manager for Hyprland${NC}"
    echo -e "${YELLOW}=================================${NC}"
    echo ""
    echo -e "${GREEN}Usage:${NC} $0 {auto|status|toggle|single|dual|dual-left|dual-right|move|help}"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo -e "  ${GREEN}auto${NC}       - Auto-detect and configure monitors"
    echo -e "  ${GREEN}status${NC}     - Show current monitor status"
    echo -e "  ${GREEN}toggle${NC}     - Toggle between single/dual monitor mode"
    echo -e "  ${GREEN}single${NC}     - Force single monitor configuration"
    echo -e "  ${GREEN}dual${NC}       - Force dual monitor configuration (secondary on left)"
    echo -e "  ${GREEN}dual-left${NC}  - Dual monitor with secondary on left"
    echo -e "  ${GREEN}dual-right${NC} - Dual monitor with secondary on right"
    echo -e "  ${GREEN}move${NC}       - Move workspace to monitor (interactive)"
    echo -e "  ${GREEN}help${NC}       - Show this help message"
    echo ""
    echo -e "${PURPLE}Examples:${NC}"
    echo -e "  $0 auto              # Auto-configure based on connected monitors"
    echo -e "  $0 dual-left         # Setup dual monitors with secondary on left"
    echo -e "  $0 status            # Show current setup"
    echo -e "  $0 move              # Interactive workspace movement"
    echo ""
    echo -e "${CYAN}Workspace Distribution:${NC}"
    echo -e "  Single monitor: workspaces 1-10 on main display"
    echo -e "  Dual monitor:   workspaces 1-5 on primary, 6-10 on secondary"
}

# Main script logic
case "$1" in
    auto)
        auto_configure
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
        if [[ $(get_monitors | wc -l) -lt 2 ]]; then
            echo -e "${RED} Dual monitor mode requires at least 2 connected monitors${NC}"
            exit 1
        fi
        configure_dual_monitors "left"  # Changed default to left
        ;;
    dual-left)
        if [[ $(get_monitors | wc -l) -lt 2 ]]; then
            echo -e "${RED} Dual monitor mode requires at least 2 connected monitors${NC}"
            exit 1
        fi
        configure_dual_monitors "left"
        ;;
    dual-right)
        if [[ $(get_monitors | wc -l) -lt 2 ]]; then
            echo -e "${RED} Dual monitor mode requires at least 2 connected monitors${NC}"
            exit 1
        fi
        configure_dual_monitors "right"
        ;;
    move)
        echo -e "${CYAN} Interactive Workspace Movement${NC}"
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
        echo -e "${RED} Invalid option: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
