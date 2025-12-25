#!/bin/bash

# Script ultra-simple para capturar desplegables
# Usa una sola tecla que no interfiera con desplegables

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Notificar inicio silenciosamente
echo "Iniciando captura de dropdown..." > /tmp/dropdown_log

# Esperar micro-delay para estabilizar
sleep 0.1

# Captura inmediata sin interfaz
OUTPUT_FILE="$SCREENSHOT_DIR/dropdown_simple_$(date +%Y%m%d_%H%M%S).png"

# Método 1: Captura completa inmediata
if grim "$OUTPUT_FILE.full"; then
    # Método 2: Usar ImageMagick para permitir selección sobre imagen estática
    if command -v convert &> /dev/null; then
        # Mostrar imagen y permitir clic para seleccionar
        notify-send " Dropdown" "Pantalla capturada. Abre el archivo para ver." --urgency=low
        wl-copy < "$OUTPUT_FILE.full"
        
        # Abrir con visor predeterminado para que usuario pueda ver
        if command -v imv &> /dev/null; then
            imv "$OUTPUT_FILE.full" &
        elif command -v eog &> /dev/null; then
            eog "$OUTPUT_FILE.full" &
        elif command -v feh &> /dev/null; then
            feh "$OUTPUT_FILE.full" &
        fi
        
        # Renombrar archivo final
        mv "$OUTPUT_FILE.full" "$OUTPUT_FILE"
        
    else
        # Fallback simple
        mv "$OUTPUT_FILE.full" "$OUTPUT_FILE"
        wl-copy < "$OUTPUT_FILE"
        notify-send " Screenshot" "Captura completa realizada" --urgency=low
    fi
else
    notify-send " Error" "No se pudo capturar" --urgency=critical
fi
