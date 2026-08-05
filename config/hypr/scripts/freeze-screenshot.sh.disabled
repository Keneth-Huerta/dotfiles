#!/bin/bash

# Script para "congelar" pantalla y capturar desplegables
# Crea una captura completa, la muestra como overlay y permite seleccionar región

TEMP_DIR="/tmp/frozen_screenshot"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# Crear directorios necesarios
mkdir -p "$TEMP_DIR"
mkdir -p "$SCREENSHOT_DIR"

# Función para limpiar archivos temporales
cleanup() {
    rm -rf "$TEMP_DIR"
    pkill -f "imv.*frozen_screen"
    pkill -f "feh.*frozen_screen"
}

# Configurar limpieza al salir
trap cleanup EXIT

# Paso 1: Tomar captura completa de la pantalla actual
notify-send "📸 Freeze Screenshot" "Congelando pantalla..." --urgency=normal
grim "$TEMP_DIR/frozen_screen.png"

# Verificar que la captura se creó correctamente
if [ ! -f "$TEMP_DIR/frozen_screen.png" ]; then
    notify-send "❌ Error" "No se pudo congelar la pantalla" --urgency=critical
    exit 1
fi

# Paso 2: Mostrar la imagen congelada en pantalla completa usando imv o feh
if command -v imv &> /dev/null; then
    # Usar imv si está disponible
    imv -f -s stretch "$TEMP_DIR/frozen_screen.png" &
    VIEWER_PID=$!
elif command -v feh &> /dev/null; then
    # Usar feh como alternativa
    feh -F -Z "$TEMP_DIR/frozen_screen.png" &
    VIEWER_PID=$!
else
    notify-send "❌ Error" "Necesitas instalar 'imv' o 'feh' para usar esta función" --urgency=critical
    exit 1
fi

# Esperar un momento para que se abra el visor
sleep 0.5

# Paso 3: Notificar al usuario que puede seleccionar
notify-send "📸 Pantalla Congelada" "Presiona ENTER para seleccionar región, ESC para cancelar" --urgency=normal

# Paso 4: Esperar input del usuario
echo "Pantalla congelada. Presiona ENTER para continuar con la selección..."
read -r

# Paso 5: Cerrar el visor
kill $VIEWER_PID 2>/dev/null

# Paso 6: Usar slurp para seleccionar región en la imagen congelada
SELECTION=$(slurp)

if [ -n "$SELECTION" ]; then
    # Paso 7: Recortar la región seleccionada de la imagen congelada
    OUTPUT_FILE="$SCREENSHOT_DIR/frozen_capture_$(date +%Y%m%d_%H%M%S).png"
    grim -g "$SELECTION" "$TEMP_DIR/frozen_screen.png" "$OUTPUT_FILE"
    
    # Copiar al clipboard
    wl-copy < "$OUTPUT_FILE"
    
    notify-send "📸 Screenshot" "Captura de región congelada guardada y copiada" --urgency=low
else
    notify-send "📸 Screenshot" "Captura cancelada" --urgency=low
fi
