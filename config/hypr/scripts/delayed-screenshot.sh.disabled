#!/bin/bash

# Script para capturar pantalla con delay para desplegables
# Uso: delayed-screenshot.sh [delay_segundos] [tipo]

DELAY=${1:-3}  # Delay por defecto: 3 segundos
TYPE=${2:-region}  # Tipo por defecto: region

# Crear directorio si no existe
mkdir -p ~/Pictures/Screenshots

# Notificar inicio
notify-send "📸 Screenshot con Delay" "Captura en ${DELAY} segundos. Prepara tu desplegable..." --urgency=normal

# Esperar el delay
sleep $DELAY

# Tomar captura según el tipo
case $TYPE in
    "region"|"area")
        # Captura de región con slurp
        grim -g "$(slurp)" /tmp/delayed_screenshot.png
        ;;
    "window")
        # Captura de ventana activa
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" /tmp/delayed_screenshot.png
        ;;
    "fullscreen")
        # Captura de pantalla completa
        grim /tmp/delayed_screenshot.png
        ;;
    *)
        # Por defecto, captura de región
        grim -g "$(slurp)" /tmp/delayed_screenshot.png
        ;;
esac

# Verificar si la captura fue exitosa
if [ -f "/tmp/delayed_screenshot.png" ]; then
    # Guardar copia permanente
    cp /tmp/delayed_screenshot.png ~/Pictures/Screenshots/delayed_screenshot_$(date +%Y%m%d_%H%M%S).png
    
    # Copiar al clipboard
    wl-copy < /tmp/delayed_screenshot.png
    
    # Notificar éxito
    notify-send "📸 Screenshot" "Captura guardada y copiada al clipboard" --urgency=low
else
    # Notificar error
    notify-send "❌ Screenshot Error" "No se pudo tomar la captura" --urgency=critical
fi
