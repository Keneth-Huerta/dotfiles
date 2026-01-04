#!/bin/bash

# 🎮 Gaming Mode Optimizer for Hyprland
# Maximizes performance for gaming sessions

MODE="${1:-status}"
LOG_FILE="/tmp/gaming-mode.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Log function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if Hyprland is running
is_hyprland_running() {
    pgrep -x Hyprland >/dev/null 2>&1
}

# Enable gaming mode
enable_gaming_mode() {
    log_message "🎮 Activando Gaming Mode..."
    
    if ! is_hyprland_running; then
        echo -e "${RED}❌ Hyprland no está ejecutándose${NC}"
        return 1
    fi
    
    # 1. Disable animations
    log_message "⚡ Desactivando animaciones..."
    hyprctl keyword animations:enabled false
    
    # 2. Disable blur
    log_message "🔲 Desactivando blur..."
    hyprctl keyword decoration:blur:enabled false
    
    # 3. Disable shadows
    log_message "🌑 Desactivando sombras..."
    hyprctl keyword decoration:drop_shadow false
    
    # 4. Set VRR (Variable Refresh Rate)
    log_message "📺 Habilitando VRR..."
    hyprctl keyword misc:vrr 2
    
    # 5. Disable VFR (Variable Frame Rate) - use full refresh always
    log_message "🎯 Desactivando VFR para máximo rendimiento..."
    hyprctl keyword misc:vfr false
    
    # 6. Set border size to minimum
    log_message "🖼️ Minimizando bordes..."
    hyprctl keyword general:border_size 1
    
    # 7. Stop unnecessary services
    log_message "🛑 Deteniendo servicios innecesarios..."
    pkill -STOP waybar 2>/dev/null
    pkill -STOP dunst 2>/dev/null
    pkill -STOP mako 2>/dev/null
    
    # 8. Set CPU governor to performance (requires sudo)
    if command -v cpupower &> /dev/null; then
        log_message "🚀 Configurando CPU governor a performance..."
        sudo cpupower frequency-set -g performance 2>/dev/null || log_message "⚠️ No se pudo cambiar CPU governor (sudo requerido)"
    fi
    
    # 9. Disable compositor effects for fullscreen
    log_message "🎬 Desactivando compositor en fullscreen..."
    hyprctl keyword decoration:dim_inactive false
    
    # 10. Notify user
    notify-send "🎮 Gaming Mode" "Modo gaming activado\n• Sin animaciones\n• Sin blur\n• VRR habilitado\n• CPU optimizado" --urgency=low
    
    log_message "✅ Gaming Mode activado completamente"
    echo -e "${GREEN}✅ Gaming Mode ACTIVADO${NC}"
    echo -e "${YELLOW}Optimizaciones aplicadas:${NC}"
    echo -e "  • Animaciones: OFF"
    echo -e "  • Blur: OFF"
    echo -e "  • Sombras: OFF"
    echo -e "  • VRR: ON (máxima velocidad)"
    echo -e "  • Servicios pausados"
    echo -e "  • Bordes minimizados"
}

# Disable gaming mode (restore normal)
disable_gaming_mode() {
    log_message "🎨 Restaurando modo normal..."
    
    if ! is_hyprland_running; then
        echo -e "${RED}❌ Hyprland no está ejecutándose${NC}"
        return 1
    fi
    
    # 1. Enable animations
    log_message "✨ Habilitando animaciones..."
    hyprctl keyword animations:enabled true
    
    # 2. Enable blur
    log_message "🌫️ Habilitando blur..."
    hyprctl keyword decoration:blur:enabled true
    
    # 3. Enable shadows
    log_message "🌓 Habilitando sombras..."
    hyprctl keyword decoration:drop_shadow true
    
    # 4. Set VRR to adaptive
    log_message "📺 VRR adaptativo..."
    hyprctl keyword misc:vrr 1
    
    # 5. Enable VFR
    log_message "🎯 Habilitando VFR..."
    hyprctl keyword misc:vfr true
    
    # 6. Restore border size
    log_message "🖼️ Restaurando bordes..."
    hyprctl keyword general:border_size 2
    
    # 7. Resume services
    log_message "▶️ Reanudando servicios..."
    pkill -CONT waybar 2>/dev/null
    pkill -CONT dunst 2>/dev/null
    pkill -CONT mako 2>/dev/null
    
    # 8. Set CPU governor back to powersave/schedutil
    if command -v cpupower &> /dev/null; then
        log_message "🔋 Restaurando CPU governor..."
        sudo cpupower frequency-set -g schedutil 2>/dev/null || log_message "⚠️ No se pudo restaurar CPU governor"
    fi
    
    # 9. Re-enable compositor effects
    log_message "🎨 Habilitando efectos del compositor..."
    hyprctl keyword decoration:dim_inactive true
    
    # 10. Notify user
    notify-send "🎨 Normal Mode" "Modo normal restaurado\n• Animaciones ON\n• Blur ON\n• Efectos visuales restaurados" --urgency=low
    
    log_message "✅ Modo normal restaurado"
    echo -e "${BLUE}✅ Modo Normal RESTAURADO${NC}"
    echo -e "${YELLOW}Configuración restaurada:${NC}"
    echo -e "  • Animaciones: ON"
    echo -e "  • Blur: ON"
    echo -e "  • Sombras: ON"
    echo -e "  • VRR: Adaptativo"
    echo -e "  • Servicios reanudados"
}

# Show status
show_status() {
    echo -e "${CYAN}🎮 Estado del Gaming Mode${NC}"
    echo -e "${YELLOW}========================${NC}"
    
    if ! is_hyprland_running; then
        echo -e "${RED}❌ Hyprland no está ejecutándose${NC}"
        return 1
    fi
    
    local animations=$(hyprctl getoption animations:enabled -j | jq -r '.int')
    local blur=$(hyprctl getoption decoration:blur:enabled -j | jq -r '.int')
    local shadows=$(hyprctl getoption decoration:drop_shadow -j | jq -r '.int')
    local vrr=$(hyprctl getoption misc:vrr -j | jq -r '.int')
    local vfr=$(hyprctl getoption misc:vfr -j | jq -r '.int')
    
    echo -e "${BLUE}Configuración actual:${NC}"
    echo -e "  Animaciones: $([[ $animations -eq 1 ]] && echo -e "${GREEN}ON${NC}" || echo -e "${RED}OFF${NC}")"
    echo -e "  Blur: $([[ $blur -eq 1 ]] && echo -e "${GREEN}ON${NC}" || echo -e "${RED}OFF${NC}")"
    echo -e "  Sombras: $([[ $shadows -eq 1 ]] && echo -e "${GREEN}ON${NC}" || echo -e "${RED}OFF${NC}")"
    echo -e "  VRR: $vrr (0=off, 1=adaptive, 2=always)"
    echo -e "  VFR: $([[ $vfr -eq 1 ]] && echo -e "${GREEN}ON${NC}" || echo -e "${RED}OFF${NC}")"
    echo ""
    
    if [[ $animations -eq 0 ]] && [[ $blur -eq 0 ]]; then
        echo -e "${GREEN}✅ Gaming Mode ACTIVO${NC}"
    else
        echo -e "${BLUE}🎨 Modo Normal ACTIVO${NC}"
    fi
}

# Main
case "$MODE" in
    on|enable|gaming)
        enable_gaming_mode
        ;;
    off|disable|normal)
        disable_gaming_mode
        ;;
    toggle)
        # Check current state and toggle
        animations=$(hyprctl getoption animations:enabled -j 2>/dev/null | jq -r '.int')
        if [[ $animations -eq 1 ]]; then
            enable_gaming_mode
        else
            disable_gaming_mode
        fi
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        echo -e "${CYAN}🎮 Gaming Mode Optimizer${NC}"
        echo -e "${YELLOW}========================${NC}"
        echo ""
        echo -e "${GREEN}Uso:${NC} $0 {on|off|toggle|status}"
        echo ""
        echo -e "${BLUE}Comandos:${NC}"
        echo -e "  ${GREEN}on${NC}, enable, gaming  - Activar modo gaming"
        echo -e "  ${GREEN}off${NC}, disable, normal - Desactivar modo gaming"
        echo -e "  ${GREEN}toggle${NC}               - Alternar entre modos"
        echo -e "  ${GREEN}status${NC}               - Ver estado actual"
        echo ""
        echo -e "${YELLOW}Optimizaciones del Gaming Mode:${NC}"
        echo -e "  • Desactiva animaciones (más FPS)"
        echo -e "  • Desactiva blur (menos uso de GPU)"
        echo -e "  • Desactiva sombras (mejor rendimiento)"
        echo -e "  • Habilita VRR siempre activo"
        echo -e "  • Desactiva VFR (máxima velocidad)"
        echo -e "  • Pausa servicios innecesarios"
        echo -e "  • CPU governor a performance"
        echo -e "  • Bordes minimizados"
        ;;
    *)
        echo -e "${RED}❌ Opción inválida: $MODE${NC}"
        echo -e "Usa: $0 {on|off|toggle|status|help}"
        exit 1
        ;;
esac
