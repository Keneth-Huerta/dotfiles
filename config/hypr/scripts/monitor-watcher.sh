#!/bin/bash

# 👁️ Monitor Watcher Daemon
# Continuously monitors for display changes and auto-configures

LOG_FILE="/tmp/monitor-watcher.log"
MONITOR_MANAGER="/home/valge/.config/hypr/scripts/monitor-manager.sh"
PIDFILE="/tmp/monitor-watcher.pid"
CHECK_INTERVAL=3  # Check every 3 seconds

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to get current monitor setup hash
get_monitor_hash() {
    hyprctl monitors 2>/dev/null | grep -E "^Monitor|description:" | sha256sum | cut -d' ' -f1
}

# Function to check if Hyprland is running
is_hyprland_running() {
    pgrep -x "Hyprland" >/dev/null 2>&1
}

# Function to start daemon
start_daemon() {
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Monitor watcher is already running (PID: $(cat $PIDFILE))${NC}"
        return 1
    fi
    
    echo -e "${GREEN}🚀 Starting monitor watcher daemon...${NC}"
    log_message "👁️ Monitor watcher daemon starting"
    
    # Store PID
    echo $$ > "$PIDFILE"
    
    # Wait for Hyprland to be ready
    while ! is_hyprland_running; do
        sleep 2
    done
    
    log_message "✅ Hyprland detected, starting monitor watch"
    
    # Get initial state
    local last_hash=$(get_monitor_hash)
    log_message "📊 Initial monitor hash: $last_hash"
    
    # Main monitoring loop
    while true; do
        if ! is_hyprland_running; then
            log_message "⚠️ Hyprland not running, stopping watcher"
            break
        fi
        
        local current_hash=$(get_monitor_hash)
        
        if [[ "$current_hash" != "$last_hash" ]]; then
            log_message "🔄 Monitor configuration changed!"
            log_message "📊 Previous hash: $last_hash"
            log_message "📊 Current hash: $current_hash"
            
            # Wait a moment for the system to stabilize
            sleep 2
            
            # Reconfigure monitors
            if [[ -x "$MONITOR_MANAGER" ]]; then
                log_message "🖥️ Auto-configuring monitors..."
                "$MONITOR_MANAGER" auto >> "$LOG_FILE" 2>&1
                log_message "✅ Monitor reconfiguration completed"
            else
                log_message "❌ Monitor manager not found: $MONITOR_MANAGER"
            fi
            
            last_hash="$current_hash"
        fi
        
        sleep "$CHECK_INTERVAL"
    done
    
    # Clean up
    rm -f "$PIDFILE"
    log_message "🛑 Monitor watcher daemon stopped"
}

# Function to stop daemon
stop_daemon() {
    if [[ -f "$PIDFILE" ]]; then
        local pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${YELLOW}🛑 Stopping monitor watcher daemon (PID: $pid)...${NC}"
            kill "$pid"
            rm -f "$PIDFILE"
            log_message "🛑 Monitor watcher daemon stopped by user"
            echo -e "${GREEN}✅ Monitor watcher stopped${NC}"
        else
            echo -e "${RED}❌ PID file exists but process not running${NC}"
            rm -f "$PIDFILE"
        fi
    else
        echo -e "${RED}❌ Monitor watcher is not running${NC}"
    fi
}

# Function to show status
show_status() {
    echo -e "${CYAN}👁️ Monitor Watcher Status${NC}"
    echo -e "${YELLOW}========================${NC}"
    
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
        local pid=$(cat "$PIDFILE")
        echo -e "${GREEN}✅ Running (PID: $pid)${NC}"
        echo -e "${BLUE}📊 Current monitor hash: $(get_monitor_hash)${NC}"
        echo -e "${BLUE}📝 Log file: $LOG_FILE${NC}"
        echo -e "${BLUE}⏰ Check interval: ${CHECK_INTERVAL}s${NC}"
    else
        echo -e "${RED}❌ Not running${NC}"
        if [[ -f "$PIDFILE" ]]; then
            echo -e "${YELLOW}⚠️ Stale PID file detected${NC}"
            rm -f "$PIDFILE"
        fi
    fi
}

# Function to show recent logs
show_logs() {
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${CYAN}📝 Recent Monitor Watcher Logs${NC}"
        echo -e "${YELLOW}==============================${NC}"
        tail -20 "$LOG_FILE"
    else
        echo -e "${YELLOW}⚠️ No log file found${NC}"
    fi
}

# Function to manually trigger detection
manual_trigger() {
    echo -e "${CYAN}🔧 Manual Monitor Detection${NC}"
    echo -e "${YELLOW}============================${NC}"
    
    if [[ -x "$MONITOR_MANAGER" ]]; then
        echo -e "${BLUE}🖥️ Running monitor auto-configuration...${NC}"
        "$MONITOR_MANAGER" auto
        echo -e "${GREEN}✅ Manual trigger completed${NC}"
    else
        echo -e "${RED}❌ Monitor manager not found: $MONITOR_MANAGER${NC}"
    fi
}

# Help function
show_help() {
    echo -e "${CYAN}👁️ Monitor Watcher Daemon${NC}"
    echo -e "${YELLOW}=========================${NC}"
    echo ""
    echo -e "${GREEN}Usage:${NC} $0 {start|stop|restart|status|logs|trigger|help}"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo -e "  ${GREEN}start${NC}    - Start monitor watcher daemon"
    echo -e "  ${GREEN}stop${NC}     - Stop monitor watcher daemon"
    echo -e "  ${GREEN}restart${NC}  - Restart monitor watcher daemon"
    echo -e "  ${GREEN}status${NC}   - Show daemon status"
    echo -e "  ${GREEN}logs${NC}     - Show recent logs"
    echo -e "  ${GREEN}trigger${NC}  - Manually trigger monitor detection"
    echo -e "  ${GREEN}help${NC}     - Show this help message"
    echo ""
    echo -e "${CYAN}Features:${NC}"
    echo -e "  ✅ Automatic monitor detection every ${CHECK_INTERVAL}s"
    echo -e "  ✅ Auto-configuration when monitors change"
    echo -e "  ✅ Hyprland integration"
    echo -e "  ✅ Comprehensive logging"
    echo ""
    echo -e "${BLUE}Files:${NC}"
    echo -e "  📝 Log: $LOG_FILE"
    echo -e "  🔒 PID: $PIDFILE"
}

# Main logic
case "$1" in
    start)
        start_daemon
        ;;
    stop)
        stop_daemon
        ;;
    restart)
        stop_daemon
        sleep 1
        start_daemon
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    trigger)
        manual_trigger
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Invalid option: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
