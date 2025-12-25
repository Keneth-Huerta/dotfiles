#!/bin/bash

# Red themed mpvpaper manager for Hyprland
# Improved error handling and process management

# Set up signal handling to prevent interruption
set -m  # Enable job control
trap 'exit 0' TERM INT HUP

WALLPAPER_FILE="$HOME/Pictures/Wallpapers/rojo.mp4"
WALLPAPER_PINGPONG="$HOME/Pictures/Wallpapers/rojo-pingpong.mp4"
MPVPAPER_OPTS="--mpv-options=\"--loop-file=inf --no-audio --video-unscaled=downscale-big --keep-open=yes --video-sync=display-resample --interpolation=yes --tscale=oversample --video-output-levels=full\""
LOG_FILE="/tmp/mpvpaper-manager.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v mpvpaper &> /dev/null; then
        missing_deps+=("mpvpaper")
    fi
    
    if ! command -v mpv &> /dev/null; then
        missing_deps+=("mpv")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_message " Error: Missing dependencies: ${missing_deps[*]}"
        log_message "Install with: yay -S mpvpaper mpv"
        return 1
    fi
    
    return 0
}

start_mpvpaper() {
    log_message " Starting red video wallpaper..."
    
    # Check dependencies first
    if ! check_dependencies; then
        return 1
    fi
    
    # Choose video file: ping-pong version if available, otherwise original
    local video_to_use="$WALLPAPER_FILE"
    if [[ -f "$WALLPAPER_PINGPONG" ]]; then
        video_to_use="$WALLPAPER_PINGPONG"
        log_message " Using ping-pong video for seamless loop"
    else
        log_message " Using original video (consider creating ping-pong version)"
    fi
    
    # Ensure the video file exists
    if [[ ! -f "$video_to_use" ]]; then
        log_message " Error: Video file not found at $video_to_use"
        return 1
    fi
    
    # Kill any existing mpvpaper processes (but not this script)
    if pgrep -f "^mpvpaper" >/dev/null 2>&1; then
        log_message " Stopping existing mpvpaper processes..."
        pkill -f "^mpvpaper" 2>/dev/null || true
        sleep 2
        # Force kill if still running
        if pgrep -f "^mpvpaper" >/dev/null 2>&1; then
            pkill -9 -f "^mpvpaper" 2>/dev/null || true
            sleep 1
        fi
    fi
    
    # Start mpvpaper with proper background handling
    log_message " Launching mpvpaper with options: $MPVPAPER_OPTS"
    log_message " Video file: $video_to_use"
    
    # Use eval to properly expand the options and setsid to create a new session
    eval "setsid mpvpaper $MPVPAPER_OPTS '*' \"$video_to_use\"" >/dev/null 2>&1 &
    local mpv_pid=$!
    
    # Give it time to start
    sleep 3
    
    # Verify the process is running
    if pgrep -f "^mpvpaper.*$(basename "$video_to_use")" >/dev/null 2>&1; then
        log_message " Red video wallpaper started successfully"
        return 0
    else
        log_message " First attempt failed, trying alternative method..."
        
        # Alternative method: use nohup with eval for proper option expansion
        eval "nohup mpvpaper $MPVPAPER_OPTS '*' \"$video_to_use\"" >/dev/null 2>&1 &
        sleep 3
        
        if pgrep -f "^mpvpaper.*$(basename "$video_to_use")" >/dev/null 2>&1; then
            log_message " Red video wallpaper started on retry"
            return 0
        else
            log_message " Failed to start mpvpaper after retry"
            log_message "Debug: Checking mpvpaper installation and permissions..."
            which mpvpaper >> "$LOG_FILE" 2>&1
            ls -la "$video_to_use" >> "$LOG_FILE" 2>&1
            return 1
        fi
    fi
}

stop_mpvpaper() {
    log_message " Stopping mpvpaper..."
    
    # First try graceful termination
    if pgrep -f "^mpvpaper" >/dev/null 2>&1; then
        log_message "Sending TERM signal to mpvpaper processes..."
        pkill -TERM -f "^mpvpaper" 2>/dev/null
        sleep 3
    fi
    
    # Force kill if still running
    if pgrep -f "^mpvpaper" >/dev/null 2>&1; then
        log_message "Force killing remaining mpvpaper processes..."
        pkill -KILL -f "^mpvpaper" 2>/dev/null
        sleep 1
    fi
    
    # Final check and cleanup
    if pgrep -f "^mpvpaper" >/dev/null 2>&1; then
        log_message " Some mpvpaper processes may still be running"
        pgrep -f "^mpvpaper" -l >> "$LOG_FILE" 2>&1
        return 1
    else
        log_message " mpvpaper stopped successfully"
        return 0
    fi
}

status_mpvpaper() {
    if pgrep -f "^mpvpaper" >/dev/null 2>&1; then
        log_message " mpvpaper is running with red video wallpaper"
        echo "Process details:"
        pgrep -f "^mpvpaper" -l
        echo "Video file: $WALLPAPER_FILE"
        echo "Log file: $LOG_FILE"
    else
        log_message " mpvpaper is not running"
        echo "Log file: $LOG_FILE (for troubleshooting)"
    fi
}

case "$1" in
    start)
        start_mpvpaper
        ;;
    stop)
        stop_mpvpaper
        ;;
    restart)
        log_message " Restarting mpvpaper..."
        stop_mpvpaper
        sleep 2
        start_mpvpaper
        ;;
    status)
        status_mpvpaper
        ;;
    create-pingpong)
        log_message " Creating ping-pong video..."
        ~/.config/hypr/scripts/create-pingpong-video.sh
        ;;
    use-pingpong)
        if [[ -f "$WALLPAPER_PINGPONG" ]]; then
            log_message " Switching to ping-pong video..."
            stop_mpvpaper
            sleep 2
            start_mpvpaper
        else
            log_message " Ping-pong video not found. Create it first with: $0 create-pingpong"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|create-pingpong|use-pingpong}"
        echo "  start         - Start red video wallpaper"
        echo "  stop          - Stop video wallpaper"  
        echo "  restart       - Restart video wallpaper"
        echo "  status        - Check if wallpaper is running"
        echo "  create-pingpong - Create seamless ping-pong version of video"
        echo "  use-pingpong  - Switch to ping-pong video (creates if needed)"
        echo ""
        echo "Log file: $LOG_FILE"
        exit 1
        ;;
esac
