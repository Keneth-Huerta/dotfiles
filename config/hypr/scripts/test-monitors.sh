#!/bin/bash

# 🧪 Monitor Manager Test Suite
# Comprehensive testing of the monitor management system

LOG_FILE="/tmp/monitor-test.log"
MONITOR_MANAGER="$HOME/.config/hypr/scripts/monitor-manager.sh"

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

# Function to run test
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    
    echo -e "${CYAN}🧪 Testing: $test_name${NC}"
    
    if eval "$command" >/dev/null 2>&1; then
        local exit_code=$?
        if [[ $exit_code -eq $expected_exit_code ]]; then
            echo -e "${GREEN}✅ PASS: $test_name${NC}"
            return 0
        else
            echo -e "${RED}❌ FAIL: $test_name (exit code: $exit_code, expected: $expected_exit_code)${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ FAIL: $test_name (command failed)${NC}"
        return 1
    fi
}

# Function to show test results
show_results() {
    local passed="$1"
    local total="$2"
    local failed=$((total - passed))
    
    echo ""
    echo -e "${CYAN}📊 Test Results${NC}"
    echo -e "${YELLOW}===============${NC}"
    echo -e "${GREEN}✅ Passed: $passed${NC}"
    echo -e "${RED}❌ Failed: $failed${NC}"
    echo -e "${BLUE}📝 Total:  $total${NC}"
    
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️ Some tests failed. Check the log: $LOG_FILE${NC}"
        return 1
    fi
}

# Start testing
echo -e "${PURPLE}🚀 Starting Monitor Manager Test Suite${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

log_message "🧪 Starting monitor manager tests"

passed_tests=0
total_tests=0

# Test 1: Monitor manager script exists and is executable
((total_tests++))
if run_test "Monitor manager script exists and is executable" "[[ -x '$MONITOR_MANAGER' ]]"; then
    ((passed_tests++))
fi

# Test 2: Status command works
((total_tests++))
if run_test "Status command" "$MONITOR_MANAGER status"; then
    ((passed_tests++))
fi

# Test 3: Auto-configure command works
((total_tests++))
if run_test "Auto-configure command" "$MONITOR_MANAGER auto"; then
    ((passed_tests++))
fi

# Test 4: Configuration file was created
((total_tests++))
if run_test "Configuration file exists" "[[ -f '$HOME/.config/hypr/monitors.conf' ]]"; then
    ((passed_tests++))
fi

# Test 5: Hyprland can read monitors
((total_tests++))
if run_test "Hyprland monitor detection" "hyprctl monitors >/dev/null"; then
    ((passed_tests++))
fi

# Test 6: Workspace configuration works
((total_tests++))
if run_test "Workspace switching" "hyprctl dispatch workspace 1"; then
    ((passed_tests++))
fi

# Test 7: Configuration file has proper content
((total_tests++))
if run_test "Configuration file content" "grep -q 'monitor=' '$HOME/.config/hypr/monitors.conf'"; then
    ((passed_tests++))
fi

# Test 8: Help command works
((total_tests++))
if run_test "Help command" "$MONITOR_MANAGER help"; then
    ((passed_tests++))
fi

# Test 9: Toggle command works (if multiple monitors)
monitor_count=$(hyprctl monitors | grep -c "^Monitor")
if [[ $monitor_count -gt 1 ]]; then
    ((total_tests++))
    if run_test "Toggle command (multi-monitor)" "$MONITOR_MANAGER toggle"; then
        ((passed_tests++))
    fi
else
    echo -e "${YELLOW}⏭️ Skipping toggle test (single monitor detected)${NC}"
fi

# Test 10: Autostart script exists
((total_tests++))
if run_test "Autostart script exists" "[[ -x '$HOME/.config/hypr/scripts/autostart-monitors.sh' ]]"; then
    ((passed_tests++))
fi

log_message "🏁 Testing completed: $passed_tests/$total_tests tests passed"

# Show results
show_results $passed_tests $total_tests

# Additional information
echo ""
echo -e "${CYAN}📋 System Information${NC}"
echo -e "${YELLOW}=====================${NC}"
echo -e "${BLUE}Connected monitors:${NC} $(hyprctl monitors | grep -c "^Monitor")"
echo -e "${BLUE}Active workspace:${NC} $(hyprctl activewindow | grep "workspace:" | awk '{print $2}')"
echo -e "${BLUE}Monitor config file:${NC} $HOME/.config/hypr/monitors.conf"
echo -e "${BLUE}Test log file:${NC} $LOG_FILE"

echo ""
echo -e "${PURPLE}🎯 Quick Commands${NC}"
echo -e "${YELLOW}=================${NC}"
echo -e "${GREEN}Status:${NC} $MONITOR_MANAGER status"
echo -e "${GREEN}Auto-config:${NC} $MONITOR_MANAGER auto"
echo -e "${GREEN}Help:${NC} $MONITOR_MANAGER help"
