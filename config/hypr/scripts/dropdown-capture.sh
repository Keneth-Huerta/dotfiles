#!/bin/bash

# Script mejorado para capturar desplegables
# Toma captura inmediata y permite selección posterior sobre imagen estática

TEMP_DIR="/tmp/dropdown_capture"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# Crear directorios
mkdir -p "$TEMP_DIR" "$SCREENSHOT_DIR"

# Función de limpieza
cleanup() {
    pkill -f "imv.*dropdown_frozen"
    pkill -f "feh.*dropdown_frozen" 
    rm -rf "$TEMP_DIR"
    # Restaurar entrada por si acaso
    hyprctl keyword input:kb_repeat_rate 25 > /dev/null 2>&1
    hyprctl keyword input:repeat_delay 600 > /dev/null 2>&1
}

trap cleanup EXIT

# PASO 1: Captura inmediata sin interfaz
notify-send "📸 Dropdown Capture" "Capturando pantalla..." --urgency=normal
grim "$TEMP_DIR/dropdown_frozen.png"

# Verificar captura
if [ ! -f "$TEMP_DIR/dropdown_frozen.png" ]; then
    notify-send "❌ Error" "No se pudo capturar la pantalla" --urgency=critical
    exit 1
fi

# PASO 2: Mostrar imagen en overlay para selección
notify-send "📸 Dropdown Capture" "Imagen capturada. Selecciona la región..." --urgency=normal

# Crear un script temporal para manejar la selección sobre la imagen
cat > "$TEMP_DIR/select_region.sh" << 'EOF'
#!/bin/bash
TEMP_DIR="/tmp/dropdown_capture"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# Usar slurp para seleccionar región con la imagen de fondo
SELECTION=$(slurp -b "$TEMP_DIR/dropdown_frozen.png")

if [ -n "$SELECTION" ]; then
    # Extraer coordenadas y tamaño
    OUTPUT_FILE="$SCREENSHOT_DIR/dropdown_$(date +%Y%m%d_%H%M%S).png"
    
    # Recortar la región seleccionada de la imagen capturada
    grim -g "$SELECTION" "$TEMP_DIR/dropdown_frozen.png" "$OUTPUT_FILE"
    
    # Copiar al clipboard
    wl-copy < "$OUTPUT_FILE"
    
    notify-send "📸 Screenshot" "Dropdown capturado y copiado al clipboard" --urgency=low
    
    # Mostrar preview rápido
    if command -v imv &> /dev/null; then
        imv "$OUTPUT_FILE" &
        sleep 2
        pkill -f "imv.*dropdown_"
    fi
else
    notify-send "📸 Screenshot" "Captura cancelada" --urgency=low
fi
EOF

chmod +x "$TEMP_DIR/select_region.sh"

# PASO 3: Ejecutar selección
"$TEMP_DIR/select_region.sh"
