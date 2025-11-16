#!/bin/bash

# Simple mpvpaper stop script - only kill actual mpvpaper processes
pkill -TERM -f "^mpvpaper" 2>/dev/null
sleep 1
pkill -KILL -f "^mpvpaper" 2>/dev/null || true

exit 0
