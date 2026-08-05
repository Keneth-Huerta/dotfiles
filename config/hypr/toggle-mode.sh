#!/bin/bash
# #######################################################################################
# HYPRLAND PERFORMANCE MODE TOGGLE SCRIPT (Mejorado)
# Script unificado para alternar entre modos de rendimiento
# No duplica gaming-mode.sh - este es para presets rápidos
# #######################################################################################

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

MODE_FILE="$HOME/.config/hypr/.current_mode"

show_help() {
    echo -e "${CYAN}Hyprland Performance Mode Toggle${NC}"
    echo -e "${YELLOW}Uso: $0 [MODO]${NC}"
    echo ""
    echo -e "  ${GREEN}normal${NC}      - Modo normal con todas las características"
    echo -e "  ${GREEN}gaming${NC}      - Modo gaming (máximo rendimiento)"
    echo -e "  ${GREEN}battery${NC}     - Modo ahorro de batería"
    echo -e "  ${GREEN}focus${NC}       - Modo concentración (sin distracciones)"
    echo -e "  ${GREEN}status${NC}      - Mostrar modo actual"
    echo ""
    echo -e "${BLUE}Nota:${NC} Para modo gaming completo con CPU, usa: gaming-mode.sh"
}

save_mode() {
    echo "$1" > "$MODE_FILE"
}

apply_normal_mode() {
    echo -e "${GREEN}Aplicando modo normal...${NC}"
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword animations:enabled true
    hyprctl keyword decoration:shadow:enabled true
    hyprctl keyword general:gaps_in 5
    hyprctl keyword general:gaps_out 20
    hyprctl keyword decoration:active_opacity 0.95
    hyprctl keyword decoration:inactive_opacity 0.88
    save_mode "normal"
    notify-send "🎨 Modo Normal" "Todas las características activadas" -i preferences-system
}

apply_gaming_mode() {
    echo -e "${RED}Aplicando modo gaming...${NC}"
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 5
    hyprctl keyword general:border_size 1
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0
    save_mode "gaming"
    notify-send "🎮 Modo Gaming" "Máximo rendimiento activado" -i applications-games
}

apply_battery_mode() {
    echo -e "${YELLOW}Aplicando modo ahorro de batería...${NC}"
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword general:gaps_in 2
    hyprctl keyword general:gaps_out 5
    hyprctl keyword general:border_size 1
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 0.95
    save_mode "battery"
    notify-send "🔋 Modo Batería" "Ahorro de energía activado" -i battery-low
}

apply_focus_mode() {
    echo -e "${CYAN}Aplicando modo concentración...${NC}"
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword animations:enabled true
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 0.80
    save_mode "focus"
    notify-send "🎯 Modo Concentración" "Sin distracciones visuales" -i document-edit
}

show_status() {
    local current="desconocido"
    [[ -f "$MODE_FILE" ]] && current=$(cat "$MODE_FILE")
    
    echo -e "${CYAN}📊 Estado Actual${NC}"
    echo -e "${YELLOW}================${NC}"
    echo -e "Modo: ${GREEN}$current${NC}"
    echo ""
    
    local blur=$(hyprctl getoption decoration:blur:enabled -j 2>/dev/null | jq -r '.int // "N/A"')
    local anim=$(hyprctl getoption animations:enabled -j 2>/dev/null | jq -r '.int // "N/A"')
    local shadow=$(hyprctl getoption decoration:shadow:enabled -j 2>/dev/null | jq -r '.int // "N/A"')
    local gaps_in=$(hyprctl getoption general:gaps_in -j 2>/dev/null | jq -r '.int // "N/A"')
    local gaps_out=$(hyprctl getoption general:gaps_out -j 2>/dev/null | jq -r '.int // "N/A"')
    
    echo -e "  Blur:     $([[ $blur == \"1\" ]] && echo -e "${GREEN}ON${NC}" || echo -e "${RED}OFF${NC}")"
    echo -e "  Animaciones: $([[ $anim == \"1\" ]] && echo -e "${GREEN}ON${NC}" || echo -e "${RED}OFF${NC}")"
    echo -e "  Sombras:  $([[ $shadow == \"1\" ]] && echo -e "${GREEN}ON${NC}" || echo -e "${RED}OFF${NC}")"
    echo -e "  Gaps in:  ${BLUE}$gaps_in${NC}"
    echo -e "  Gaps out: ${BLUE}$gaps_out${NC}"
}

# Main
case "$1" in
    "normal")   apply_normal_mode ;;
    "gaming")   apply_gaming_mode ;;
    "battery")  apply_battery_mode ;;
    "focus")    apply_focus_mode ;;
    "status")   show_status ;;
    "-h"|"--help"|"help"|"") show_help ;;
    *)
        echo -e "${RED}Error: Modo '$1' no reconocido${NC}"
        show_help
        exit 1
        ;;
esac
