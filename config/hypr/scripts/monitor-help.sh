#!/bin/bash

#  Monitor System Quick Help
# Shows all available options for monitor management

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN} Monitor Management System - Quick Help${NC}"
echo -e "${YELLOW}===========================================${NC}"
echo ""

echo -e "${GREEN} KEYBOARD SHORTCUTS (Fastest):${NC}"
echo -e "  Super + Alt + M             - Auto-configure monitors"
echo -e "  Super + Alt + Shift + M     - Toggle single/dual mode"
echo -e "  Super + Alt + F6            - Manual detection"
echo -e "  Super + Alt + Shift + F6    - Restart watcher"
echo -e "  Super + Ctrl + ←/→          - Focus monitor"
echo -e "  Super + Ctrl + Shift + ←/→  - Move window to monitor"
echo ""

echo -e "${GREEN} AUTOMATIC DETECTION:${NC}"
echo -e "   Connects/disconnects are detected automatically"
echo -e "   Monitor watcher daemon runs in background"
echo -e "   Configuration updates instantly"
echo ""

echo -e "${GREEN} MANUAL COMMANDS:${NC}"
echo -e "  Auto-configure:     monitor-manager.sh auto"
echo -e "  Status:             monitor-manager.sh status"
echo -e "  Dual (default):     monitor-manager.sh dual (secundario a la izquierda)"
echo -e "  Dual (left):        monitor-manager.sh dual-left"
echo -e "  Dual (right):       monitor-manager.sh dual-right"
echo -e "  Single monitor:     monitor-manager.sh single"
echo ""

echo -e "${GREEN} MONITOR WATCHER:${NC}"
echo -e "  Status:             monitor-watcher.sh status"
echo -e "  Start/Stop:         monitor-watcher.sh start|stop"
echo -e "  Manual trigger:     monitor-watcher.sh trigger"
echo -e "  View logs:          monitor-watcher.sh logs"
echo ""

echo -e "${BLUE} WHAT TO DO WHEN YOU CONNECT/DISCONNECT:${NC}"
echo -e "${YELLOW}   Option 1 (Automatic): ${NC}Just wait 3-5 seconds - it's automatic!"
echo -e "${YELLOW}   Option 2 (Manual):    ${NC}Press Super + Alt + F6"
echo -e "${YELLOW}   Option 3 (Command):   ${NC}Run './monitor-watcher.sh trigger'"
echo ""

echo -e "${GREEN} WORKSPACE LAYOUT:${NC}"
echo -e "  Single monitor:  Workspaces 1-10 on main screen"
echo -e "  Dual monitor:    Workspaces 1-5 on primary, 6-10 on secondary"
echo ""

echo -e "${CYAN} Configuration files:${NC}"
echo -e "  Monitor config:  ~/.config/hypr/monitors.conf"
echo -e "  Watcher logs:    /tmp/monitor-watcher.log"
