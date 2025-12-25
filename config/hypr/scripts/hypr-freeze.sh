#!/bin/bash

# Script que usa las características de Hyprland para pausar rendering
# Esto congela efectivamente toda la interfaz

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Función para pausar/reanudar Hyprland
toggle_freeze() {
    if [ "$1" = "freeze" ]; then
        # Pausar animaciones y rendering
        hyprctl keyword animations:enabled false
        hyprctl keyword decoration:blur:enabled false
        hyprctl keyword misc:vfr false
        notify-send " Hyprland" "Pantalla congelada - Presiona Win+Ctrl+F para capturar" --urgency=normal
    else
        # Reanudar animaciones y rendering
        hyprctl keyword animations:enabled true
        hyprctl keyword decoration:blur:enabled true
        hyprctl keyword misc:vfr true
        notify-send " Hyprland" "Pantalla descongelada" --urgency=normal
    fi
}

# Verificar si ya está congelado
if [ "$1" = "unfreeze" ]; then
    toggle_freeze "unfreeze"
    exit 0
fi

# Si no hay argumentos, alternar entre freeze/unfreeze
if [ -z "$1" ]; then
    # Verificar estado actual revisando si las animaciones están habilitadas
    ANIM_STATE=$(hyprctl getoption animations:enabled -j | jq -r '.int')
    if [ "$ANIM_STATE" = "0" ]; then
        toggle_freeze "unfreeze"
    else
        toggle_freeze "freeze"
    fi
    exit 0
fi

# Si el argumento es "capture", tomar captura
if [ "$1" = "capture" ]; then
    OUTPUT_FILE="$SCREENSHOT_DIR/frozen_capture_$(date +%Y%m%d_%H%M%S).png"
    
    # Tomar captura de región
    if grim -g "$(slurp)" "$OUTPUT_FILE"; then
        wl-copy < "$OUTPUT_FILE"
        notify-send " Screenshot" "Captura guardada y copiada al clipboard" --urgency=low
    else
        notify-send " Error" "No se pudo tomar la captura" --urgency=critical
    fi
    
    # Descongelar automáticamente después de capturar
    toggle_freeze "unfreeze"
fi
