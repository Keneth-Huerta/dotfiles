#!/bin/bash

LOG_FILE="/tmp/monitor-watcher.log"
MONITOR_MANAGER="$HOME/.config/hypr/scripts/monitor-manager.sh"
PIDFILE="/tmp/monitor-watcher.pid"
LOCKFILE="/tmp/monitor-watcher.lock"
DEBOUNCE_SECONDS=3

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_message() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"; }

is_hyprland_running() { pgrep -x "Hyprland" >/dev/null 2>&1; }

get_monitor_hash() {
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' | sort | sha256sum | cut -d' ' -f1
}

run_daemon() {
    echo $BASHPID > "$PIDFILE"
    trap '' HUP INT QUIT
    trap 'rm -f "$PIDFILE"; log_message "Daemon stopped"; exit 0' EXIT TERM

    log_message "Daemon started (PID: $BASHPID)"

    while ! is_hyprland_running; do
        sleep 2
    done

    log_message "Hyprland detected, watching monitors"

    log_message "Executing startup monitor auto-configuration..."
    "$MONITOR_MANAGER" auto --no-reload >> "$LOG_FILE" 2>&1

    local last_hash=$(get_monitor_hash)
    local last_trigger=$(date +%s)

    local socket_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}"
    local socket_path="${socket_dir}/.socket2.sock"
    local socket_pid=""

    if command -v socat &>/dev/null && [[ -S "$socket_path" ]]; then
        log_message "Starting Hyprland socket2 event listener (socat)"
        (
            socat -u UNIX-CONNECT:"$socket_path" STDOUT 2>/dev/null | while read -r line; do
                if [[ "$line" == monitoradded* || "$line" == monitorremoved* ]]; then
                    log_message "Socket event detected: $line"
                    exec 200>"$LOCKFILE"
                    if flock -n 200; then
                        log_message "Running auto-configuration from socket event..."
                        "$MONITOR_MANAGER" auto --no-reload >> "$LOG_FILE" 2>&1
                        flock -u 200
                    fi
                fi
            done
        ) &
        socket_pid=$!
    fi

    while is_hyprland_running; do
        local current_hash=$(get_monitor_hash)
        local now=$(date +%s)

        if [[ -n "$current_hash" && "$current_hash" != "$last_hash" ]]; then
            log_message "Monitor change detected via polling: ${last_hash:0:8}... -> ${current_hash:0:8}..."

            if (( now - last_trigger >= DEBOUNCE_SECONDS )); then
                last_trigger=$now
                exec 200>"$LOCKFILE"
                if flock -n 200; then
                    log_message "Running auto-configuration..."
                    "$MONITOR_MANAGER" auto --no-reload >> "$LOG_FILE" 2>&1
                    log_message "Auto-configuration done"
                    flock -u 200
                else
                    log_message "Reconfig already in progress, skipping"
                fi
            else
                log_message "Debounced ($(( DEBOUNCE_SECONDS - now + last_trigger ))s remaining)"
            fi
            last_hash="$current_hash"
        fi
        sleep 2
    done

    [[ -n "$socket_pid" ]] && kill "$socket_pid" 2>/dev/null
    log_message "Hyprland exited, daemon stopping"
}

start_daemon() {
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
        echo -e "${YELLOW}Monitor watcher already running (PID: $(cat $PIDFILE))${NC}"
        return 1
    fi

    echo -e "${GREEN}Starting monitor watcher daemon...${NC}"

    if command -v setsid &>/dev/null; then
        setsid "$0" --daemon-mode </dev/null &>/dev/null &
    else
        nohup "$0" --daemon-mode </dev/null &>/dev/null &
    fi

    sleep 1
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
        echo -e "${GREEN}Monitor watcher started (PID: $(cat $PIDFILE))${NC}"
    else
        echo -e "${RED}Failed to start${NC}"
        rm -f "$PIDFILE"
    fi
}

stop_daemon() {
    if [[ -f "$PIDFILE" ]]; then
        local pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${YELLOW}Stopping (PID: $pid)...${NC}"
            kill "$pid" 2>/dev/null
            sleep 0.5
            kill -0 "$pid" 2>/dev/null && kill -9 "$pid" 2>/dev/null
            rm -f "$PIDFILE"
            echo -e "${GREEN}Stopped${NC}"
        else
            echo -e "${RED}Process not running, cleaning up${NC}"
            rm -f "$PIDFILE"
        fi
    else
        echo -e "${RED}Not running${NC}"
    fi
}

show_status() {
    echo -e "${CYAN}Monitor Watcher Status${NC}"
    echo -e "${YELLOW}========================${NC}"
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
        local pid=$(cat "$PIDFILE")
        echo -e "${GREEN}Running (PID: $pid)${NC}"
        echo -e "${BLUE}Monitor hash: $(get_monitor_hash 2>/dev/null || echo 'N/A')${NC}"
        echo -e "${BLUE}Log: $LOG_FILE${NC}"
    else
        echo -e "${RED}Not running${NC}"
        [[ -f "$PIDFILE" ]] && rm -f "$PIDFILE"
    fi
}

show_logs() {
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${CYAN}Recent Logs${NC}"
        tail -30 "$LOG_FILE"
    else
        echo -e "${YELLOW}No logs${NC}"
    fi
}

manual_trigger() {
    echo -e "${CYAN}Manual trigger...${NC}"
    [[ -x "$MONITOR_MANAGER" ]] && "$MONITOR_MANAGER" auto || echo -e "${RED}Manager not found${NC}"
}

show_help() {
    echo -e "${CYAN}Monitor Watcher Daemon${NC}"
    echo -e "${YELLOW}=========================${NC}"
    echo -e "${GREEN}Commands:${NC} start stop restart status logs trigger help"
    echo -e "  Poll interval: 1s | Debounce: ${DEBOUNCE_SECONDS}s"
    echo -e "  Log: $LOG_FILE | PID: $PIDFILE"
}

if [[ "$1" == "--daemon-mode" ]]; then
    run_daemon
    exit 0
fi

case "$1" in
    start)    start_daemon ;;
    stop)     stop_daemon ;;
    restart)  stop_daemon; sleep 1; start_daemon ;;
    status)   show_status ;;
    logs)     show_logs ;;
    trigger)  manual_trigger ;;
    help|--help|-h) show_help ;;
    *)        echo -e "${RED}Invalid: $1${NC}"; show_help; exit 1 ;;
esac
