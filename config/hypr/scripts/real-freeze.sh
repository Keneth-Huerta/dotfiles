#!/bin/bash

# Script que realmente congela la entrada del sistema para capturar desplegables
# Usa características avanzadas de Hyprland

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
FREEZE_FILE="/tmp/hypr_frozen"

mkdir -p "$SCREENSHOT_DIR"

# Función para congelar entrada
freeze_input() {
    # Crear archivo de estado
    touch "$FREEZE_FILE"
    
    # Deshabilitar toda entrada de teclado y mouse temporalmente
    hyprctl keyword input:sensitivity 0
    hyprctl keyword input:kb_repeat_rate 0
    hyprctl keyword input:kb_repeat_delay 999999
    hyprctl keyword input:follow_mouse 0
    hyprctl keyword input:float_switch_override_focus 0
    
    # Pausar animaciones para evitar cambios
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:blur:enabled false
    
    notify-send " Sistema Congelado" "Input pausado. Usa el segundo script para capturar." --urgency=critical
}

# Función para descongelar entrada
unfreeze_input() {
    # Restaurar configuración normal
    hyprctl keyword input:sensitivity 0.0
    hyprctl keyword input:kb_repeat_rate 25
    hyprctl keyword input:kb_repeat_delay 600
    hyprctl keyword input:follow_mouse 1
    hyprctl keyword input:float_switch_override_focus 1
    
    # Restaurar animaciones
    hyprctl keyword animations:enabled true
    hyprctl keyword decoration:blur:enabled true
    
    # Remover archivo de estado
    rm -f "$FREEZE_FILE"
    
    notify-send " Sistema Activo" "Input restaurado normalmente" --urgency=normal
}

# Función para capturar mientras está congelado
capture_frozen() {
    if [ ! -f "$FREEZE_FILE" ]; then
        notify-send " Error" "Sistema no está congelado. Usa primero el comando freeze." --urgency=critical
        exit 1
    fi
    
    OUTPUT_FILE="$SCREENSHOT_DIR/frozen_dropdown_$(date +%Y%m%d_%H%M%S).png"
    
    # Capturar pantalla completa primero
    grim /tmp/frozen_full.png
    
    # Permitir selección manual sobre imagen congelada
    if command -v slurp &> /dev/null; then
        # Restaurar input mínimo solo para slurp
        hyprctl keyword input:sensitivity 1.0
        hyprctl keyword input:follow_mouse 1
        
        SELECTION=$(slurp -b /tmp/frozen_full.png 2>/dev/null)
        
        if [ -n "$SELECTION" ]; then
            # Recortar región seleccionada
            grim -g "$SELECTION" /tmp/frozen_full.png "$OUTPUT_FILE"
            wl-copy < "$OUTPUT_FILE"
            notify-send " Captura Exitosa" "Dropdown capturado desde estado congelado" --urgency=low
        else
            # Si falla slurp, usar captura completa
            cp /tmp/frozen_full.png "$OUTPUT_FILE"
            wl-copy < "$OUTPUT_FILE"
            notify-send " Captura Completa" "Pantalla completa capturada" --urgency=low
        fi
        
        # Congelar de nuevo
        hyprctl keyword input:sensitivity 0
        hyprctl keyword input:follow_mouse 0
    else
        # Fallback: captura completa
        grim "$OUTPUT_FILE"
        wl-copy < "$OUTPUT_FILE"
        notify-send " Captura Completa" "Pantalla completa capturada" --urgency=low
    fi
    
    # Limpiar
    rm -f /tmp/frozen_full.png
}

# Procesar argumentos
case "$1" in
    "freeze")
        freeze_input
        ;;
    "unfreeze")
        unfreeze_input
        ;;
    "capture")
        capture_frozen
        ;;
    "auto")
        # Modo automático: congela, espera, captura, descongela
        freeze_input
        sleep 0.5
        capture_frozen
        sleep 0.5
        unfreeze_input
        ;;
    *)
        echo "Uso: $0 {freeze|unfreeze|capture|auto}"
        echo ""
        echo "freeze   - Congela toda la entrada del sistema"
        echo "unfreeze - Restaura la entrada del sistema"
        echo "capture  - Captura pantalla mientras está congelado"
        echo "auto     - Hace todo automáticamente"
        exit 1
        ;;
esac
