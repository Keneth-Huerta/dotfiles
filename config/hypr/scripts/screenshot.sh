#!/bin/bash
# #######################################################################################
# UNIFIED SCREENSHOT TOOL for Hyprland
# Reemplaza: freeze-screenshot.sh, real-freeze.sh, hypr-freeze.sh, 
#            simple-dropdown.sh, dropdown-capture.sh, delayed-screenshot.sh
# #######################################################################################

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

MODE="${1:-region}"
DELAY="${2:-0}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

show_help() {
    cat << 'EOF'
📸 Hyprland Screenshot Tool
═══════════════════════════════════════
Uso: screenshot.sh [MODO] [DELAY]

Modos:
  region        - Seleccionar región (por defecto)
  window        - Ventana activa
  fullscreen    - Pantalla completa
  freeze        - Congelar pantalla y seleccionar (para desplegables)
  delayed       - Captura con delay (default 3 segundos)
  menu          - Menú interactivo wofi

Ejemplos:
  screenshot.sh                    # Región, sin delay
  screenshot.sh freeze             # Congelar pantalla
  screenshot.sh delayed 5          # Delay de 5 segundos
  screenshot.sh window             # Ventana activa
EOF
}

notify() {
    local icon="$1"
    local title="$2"
    local body="$3"
    notify-send "$icon $title" "$body" --urgency=low
}

copy_and_save() {
    local src="$1"
    local filename="$2"
    
    if [[ ! -f "$src" ]]; then
        notify "❌" "Error" "No se pudo capturar"
        return 1
    fi
    
    local dest="$SCREENSHOT_DIR/${filename}_${TIMESTAMP}.png"
    cp "$src" "$dest"
    wl-copy < "$src"
    
    notify "📸" "Screenshot" "Guardado: ${dest##*/}"
    echo "$dest"
    return 0
}

capture_region() {
    local output="/tmp/screenshot_region.png"
    if grim -g "$(slurp)" "$output" 2>/dev/null; then
        copy_and_save "$output" "region"
    else
        notify "❌" "Cancelado" "No se seleccionó ninguna región"
    fi
}

capture_window() {
    local output="/tmp/screenshot_window.png"
    local geometry=$(hyprctl activewindow -j 2>/dev/null | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    
    if [[ -n "$geometry" && "$geometry" != ", x" ]]; then
        grim -g "$geometry" "$output"
        copy_and_save "$output" "window"
    else
        notify "❌" "Error" "No hay ventana activa"
    fi
}

capture_fullscreen() {
    local output="/tmp/screenshot_fullscreen.png"
    grim "$output"
    copy_and_save "$output" "fullscreen"
}

capture_freeze() {
    local frozen="/tmp/screenshot_frozen.png"
    
    # Take full screenshot immediately
    grim "$frozen"
    
    # Show it fullscreen with imv for selection reference
    if command -v imv &>/dev/null; then
        imv -f "$frozen" &
        local viewer_pid=$!
        sleep 0.3
    fi
    
    # Select region from frozen image
    notify "🧊" "Pantalla Congelada" "Selecciona la región a capturar..."
    local selection=$(slurp 2>/dev/null)
    
    # Close viewer
    [[ -n "$viewer_pid" ]] && kill "$viewer_pid" 2>/dev/null
    
    if [[ -n "$selection" ]]; then
        local output="/tmp/screenshot_freeze.png"
        grim -g "$selection" "$frozen" "$output" 2>/dev/null || grim -g "$selection" "$output"
        copy_and_save "$output" "freeze"
    else
        notify "❌" "Cancelado" "No se seleccionó ninguna región"
    fi
    
    rm -f "$frozen"
}

capture_delayed() {
    local delay="${1:-3}"
    notify "⏱️" "Screenshot Retardado" "Capturando en ${delay} segundos..."
    
    for ((i=delay; i>0; i--)); do
        notify "⏱️" "Esperando..." "$i segundos restantes"
        sleep 1
    done
    
    capture_region
}

show_menu() {
    echo "📸 Hyprland Screenshot Tool"
    echo "=========================="
    echo "Modos disponibles:"
    echo "  region     - Seleccionar región (default)"
    echo "  window     - Ventana activa"
    echo "  fullscreen - Pantalla completa"
    echo "  freeze     - Congelar pantalla (para desplegables)"
    echo "  delayed N  - Captura con delay de N segundos"
    echo ""
    echo "Uso: screenshot.sh [MODO] [DELAY]"
}

# Main
case "$MODE" in
    "region"|"") capture_region ;;
    "window") capture_window ;;
    "fullscreen"|"full") capture_fullscreen ;;
    "freeze"|"frozen") capture_freeze ;;
    "delayed"|"delay") capture_delayed "$DELAY" ;;
    "menu") show_menu ;;
    "help"|"-h"|"--help") show_help ;;
    *)
        echo "❌ Modo desconocido: $MODE"
        show_help
        exit 1
        ;;
esac
