#!/bin/bash
# #######################################################################################
# HYPRLAND PERFORMANCE MODE TOGGLE SCRIPT
# Script para alternar entre diferentes modos de rendimiento
# #######################################################################################

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Hyprland Performance Mode Toggle${NC}"
    echo -e "${YELLOW}Uso: $0 [MODO]${NC}"
    echo ""
    echo "Modos disponibles:"
    echo -e "  ${GREEN}normal${NC}     - Modo normal con todas las características"
    echo -e "  ${GREEN}gaming${NC}     - Modo gaming (sin blur, animaciones reducidas)"
    echo -e "  ${GREEN}battery${NC}    - Modo ahorro de batería"
    echo -e "  ${GREEN}performance${NC} - Modo alto rendimiento"
    echo -e "  ${GREEN}status${NC}     - Mostrar modo actual"
    echo ""
}

# Función para aplicar modo normal
apply_normal_mode() {
    echo -e "${GREEN}Aplicando modo normal...${NC}"
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword animations:enabled true
    hyprctl keyword decoration:drop_shadow true
    hyprctl keyword general:gaps_in 5
    hyprctl keyword general:gaps_out 20
    echo "normal" > ~/.config/hypr/.current_mode
    notify-send "Hyprland" "Modo normal activado" -i preferences-system
}

# Función para aplicar modo gaming
apply_gaming_mode() {
    echo -e "${RED}Aplicando modo gaming...${NC}"
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:drop_shadow false
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 5
    echo "gaming" > ~/.config/hypr/.current_mode
    notify-send "Hyprland" "Modo gaming activado - Máximo rendimiento" -i applications-games
}

# Función para aplicar modo batería
apply_battery_mode() {
    echo -e "${YELLOW}Aplicando modo ahorro de batería...${NC}"
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:drop_shadow false
    hyprctl keyword general:gaps_in 2
    hyprctl keyword general:gaps_out 5
    echo "battery" > ~/.config/hypr/.current_mode
    notify-send "Hyprland" "Modo ahorro de batería activado" -i battery-low
}

# Función para aplicar modo performance
apply_performance_mode() {
    echo -e "${BLUE}Aplicando modo alto rendimiento...${NC}"
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:blur:passes 1
    hyprctl keyword animations:enabled true
    hyprctl keyword general:gaps_in 3
    hyprctl keyword general:gaps_out 10
    echo "performance" > ~/.config/hypr/.current_mode
    notify-send "Hyprland" "Modo alto rendimiento activado" -i preferences-system-performance
}

# Función para mostrar estado actual
show_status() {
    if [[ -f ~/.config/hypr/.current_mode ]]; then
        current_mode=$(cat ~/.config/hypr/.current_mode)
        echo -e "${GREEN}Modo actual: ${YELLOW}$current_mode${NC}"
    else
        echo -e "${YELLOW}Modo actual: desconocido${NC}"
    fi
    
    # Mostrar configuraciones actuales
    echo ""
    echo "Configuraciones actuales:"
    echo -e "  Blur: $(hyprctl getoption decoration:blur:enabled | grep -o 'int: [0-1]' | cut -d' ' -f2)"
    echo -e "  Animaciones: $(hyprctl getoption animations:enabled | grep -o 'int: [0-1]' | cut -d' ' -f2)"
    echo -e "  Sombras: $(hyprctl getoption decoration:drop_shadow | grep -o 'int: [0-1]' | cut -d' ' -f2)"
}

# Verificar argumentos
if [[ $# -eq 0 ]]; then
    show_help
    exit 1
fi

# Crear directorio si no existe
mkdir -p ~/.config/hypr

# Procesar argumentos
case "$1" in
    "normal")
        apply_normal_mode
        ;;
    "gaming")
        apply_gaming_mode
        ;;
    "battery")
        apply_battery_mode
        ;;
    "performance")
        apply_performance_mode
        ;;
    "status")
        show_status
        ;;
    "-h"|"--help"|"help")
        show_help
        ;;
    *)
        echo -e "${RED}Error: Modo '$1' no reconocido${NC}"
        show_help
        exit 1
        ;;
esac
