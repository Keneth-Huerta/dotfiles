#!/bin/bash

# Script para crear un video "ping-pong" (ida y vuelta) para wallpaper sin cortes
# Crea una versión del video que se reproduce normal, luego en reversa, creando un loop suave

INPUT_VIDEO="$HOME/Pictures/Wallpapers/rojo.mp4"
OUTPUT_VIDEO="$HOME/Pictures/Wallpapers/rojo-pingpong.mp4"
TEMP_DIR="/tmp/mpvpaper-pingpong"

# Función para mostrar mensajes
echo_status() {
    echo " [$(date '+%H:%M:%S')] $1"
}

# Verificar que el video original existe
if [[ ! -f "$INPUT_VIDEO" ]]; then
    echo_status " Error: No se encuentra el video original en $INPUT_VIDEO"
    exit 1
fi

# Verificar que ffmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo_status " Error: ffmpeg no está instalado. Instálalo con: sudo pacman -S ffmpeg"
    exit 1
fi

echo_status " Creando video ping-pong desde $INPUT_VIDEO"
echo_status " Salida: $OUTPUT_VIDEO"

# Crear directorio temporal
mkdir -p "$TEMP_DIR"

# Crear video en reversa temporal
echo_status " Creando versión en reversa..."
REVERSE_VIDEO="$TEMP_DIR/rojo-reverse.mp4"

ffmpeg -i "$INPUT_VIDEO" -vf reverse -af areverse "$REVERSE_VIDEO" -y -loglevel warning

if [[ $? -ne 0 ]]; then
    echo_status " Error al crear el video en reversa"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Crear lista de videos para concatenar
CONCAT_LIST="$TEMP_DIR/concat_list.txt"
echo "file '$INPUT_VIDEO'" > "$CONCAT_LIST"
echo "file '$REVERSE_VIDEO'" >> "$CONCAT_LIST"

echo_status " Concatenando video original + reversa..."

# Concatenar video original + reversa
ffmpeg -f concat -safe 0 -i "$CONCAT_LIST" -c copy "$OUTPUT_VIDEO" -y -loglevel warning

if [[ $? -eq 0 ]]; then
    echo_status " Video ping-pong creado exitosamente: $OUTPUT_VIDEO"
    
    # Obtener información del archivo
    ORIGINAL_SIZE=$(du -h "$INPUT_VIDEO" | cut -f1)
    PINGPONG_SIZE=$(du -h "$OUTPUT_VIDEO" | cut -f1)
    
    echo_status " Tamaño original: $ORIGINAL_SIZE"
    echo_status " Tamaño ping-pong: $PINGPONG_SIZE"
    
    # Limpiar archivos temporales
    rm -rf "$TEMP_DIR"
    
    echo_status " Para usar el video ping-pong, ejecuta:"
    echo "   ~/.config/hypr/scripts/mpvpaper-manager.sh use-pingpong"
    
else
    echo_status " Error al concatenar los videos"
    rm -rf "$TEMP_DIR"
    exit 1
fi
