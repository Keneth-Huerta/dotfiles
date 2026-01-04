#!/bin/bash

# 🚀 System Optimizer for Hyprland
# Optimizes system performance and cleans up resources

LOG_FILE="/tmp/system-optimizer.log"
CACHE_DIR="$HOME/.cache"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🚀 Hyprland System Optimizer 🚀    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Function to clean cache
clean_cache() {
    echo -e "${YELLOW}🧹 Cleaning cache...${NC}"
    log_message "Starting cache cleanup"
    
    # Clean thumbnail cache
    if [[ -d "$CACHE_DIR/thumbnails" ]]; then
        local before=$(du -sh "$CACHE_DIR/thumbnails" 2>/dev/null | cut -f1)
        find "$CACHE_DIR/thumbnails" -type f -atime +30 -delete 2>/dev/null
        local after=$(du -sh "$CACHE_DIR/thumbnails" 2>/dev/null | cut -f1)
        echo -e "${GREEN}  ✓ Thumbnails: $before → $after${NC}"
        log_message "Cleaned thumbnails cache: $before → $after"
    fi
    
    # Clean Waybar cache
    if [[ -d "$CACHE_DIR/waybar" ]]; then
        rm -rf "$CACHE_DIR/waybar"/*
        echo -e "${GREEN}  ✓ Waybar cache cleared${NC}"
        log_message "Cleared Waybar cache"
    fi
    
    # Clean fontconfig cache
    if command -v fc-cache &> /dev/null; then
        fc-cache -f -v > /dev/null 2>&1
        echo -e "${GREEN}  ✓ Font cache rebuilt${NC}"
        log_message "Rebuilt font cache"
    fi
    
    # Clean old logs
    find /tmp -name "*.log" -type f -mtime +7 -delete 2>/dev/null
    echo -e "${GREEN}  ✓ Old logs cleaned${NC}"
    log_message "Cleaned old log files"
}

# Function to optimize PipeWire
optimize_pipewire() {
    echo -e "${YELLOW}🎵 Optimizing PipeWire...${NC}"
    log_message "Optimizing PipeWire"
    
    # Restart PipeWire services
    systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}  ✓ PipeWire services restarted${NC}"
        log_message "PipeWire services restarted successfully"
    else
        echo -e "${RED}  ✗ Failed to restart PipeWire${NC}"
        log_message "Failed to restart PipeWire services"
    fi
}

# Function to check system resources
check_resources() {
    echo -e "${YELLOW}📊 System Resources:${NC}"
    log_message "Checking system resources"
    
    # CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo -e "${BLUE}  CPU: ${cpu_usage}%${NC}"
    
    # Memory usage
    local mem_info=$(free -h | awk '/^Mem:/ {printf "Used: %s / Total: %s (%.1f%%)", $3, $2, ($3/$2)*100}')
    echo -e "${BLUE}  RAM: $mem_info${NC}"
    
    # Disk usage
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}')
    echo -e "${BLUE}  Disk: $disk_usage${NC}"
    
    log_message "CPU: ${cpu_usage}%, Memory: $mem_info, Disk: $disk_usage"
}

# Function to optimize Hyprland
optimize_hyprland() {
    echo -e "${YELLOW}⚡ Optimizing Hyprland...${NC}"
    log_message "Optimizing Hyprland configuration"
    
    if pgrep -x Hyprland >/dev/null; then
        # Reduce blur for performance if needed
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
        
        if [[ $cpu_usage -gt 70 ]]; then
            hyprctl keyword decoration:blur:passes 2
            echo -e "${GREEN}  ✓ Reduced blur passes (CPU > 70%)${NC}"
            log_message "Reduced blur passes due to high CPU usage"
        fi
        
        # Clean up unused workspaces
        local workspace_count=$(hyprctl workspaces -j | jq '. | length')
        echo -e "${GREEN}  ✓ Active workspaces: $workspace_count${NC}"
        log_message "Active workspaces: $workspace_count"
    else
        echo -e "${RED}  ✗ Hyprland not running${NC}"
        log_message "Hyprland is not running"
    fi
}

# Function to show recommendations
show_recommendations() {
    echo ""
    echo -e "${BLUE}💡 Performance Recommendations:${NC}"
    
    # Check if gaming mode would help
    local mem_percent=$(free | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}')
    if [[ $mem_percent -gt 80 ]]; then
        echo -e "${YELLOW}  ⚠ High memory usage ($mem_percent%)${NC}"
        echo -e "${GREEN}  → Consider: Super+F1 (disable blur) or Super+F3 (disable animations)${NC}"
    fi
    
    # Check for heavy processes
    echo -e "${BLUE}  Top 3 CPU processes:${NC}"
    ps aux --sort=-%cpu | head -4 | tail -3 | awk '{printf "    • %s (%.1f%% CPU)\n", $11, $3}'
    
    echo -e "${BLUE}  Top 3 Memory processes:${NC}"
    ps aux --sort=-%mem | head -4 | tail -3 | awk '{printf "    • %s (%.1f%% MEM)\n", $11, $4}'
}

# Main execution
main() {
    case "$1" in
        "cache")
            clean_cache
            ;;
        "pipewire")
            optimize_pipewire
            ;;
        "hyprland")
            optimize_hyprland
            ;;
        "resources")
            check_resources
            ;;
        "all")
            clean_cache
            echo ""
            optimize_pipewire
            echo ""
            optimize_hyprland
            echo ""
            check_resources
            echo ""
            show_recommendations
            ;;
        *)
            echo -e "${GREEN}Usage:${NC} $0 {cache|pipewire|hyprland|resources|all}"
            echo ""
            echo -e "${BLUE}Options:${NC}"
            echo -e "  ${GREEN}cache${NC}      - Clean system cache"
            echo -e "  ${GREEN}pipewire${NC}   - Optimize PipeWire audio"
            echo -e "  ${GREEN}hyprland${NC}   - Optimize Hyprland settings"
            echo -e "  ${GREEN}resources${NC}  - Check system resources"
            echo -e "  ${GREEN}all${NC}        - Run all optimizations"
            echo ""
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ Optimization completed!${NC}"
    log_message "Optimization script completed: $1"
}

main "$@"
