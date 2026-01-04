#!/bin/bash
# #######################################################################################
# IDLE MANAGER - Automatic screen lock and power management
# Handles screen locking and display power management when idle
# #######################################################################################

# Kill any existing swayidle instances
pkill -9 swayidle

# Start swayidle with the following configuration:
# - Lock screen after 5 minutes (300 seconds) of inactivity
# - Turn off displays after 10 minutes (600 seconds) of inactivity  
# - Turn displays back on when activity resumes
# - Lock screen before suspend

swayidle -w \
    timeout 300 'swaylock -f' \
    timeout 600 'hyprctl dispatch dpms off' \
    resume 'hyprctl dispatch dpms on' \
    before-sleep 'swaylock -f' &

# Log the start
echo "$(date): Idle manager started" >> ~/.config/hypr/logs/idle-manager.log
