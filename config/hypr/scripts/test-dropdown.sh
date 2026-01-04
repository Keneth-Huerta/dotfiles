#!/bin/bash

# Script de prueba para verificar funcionalidad de capturas

echo "🧪 PROBANDO FUNCIONALIDAD DE CAPTURAS DE DROPDOWN"
echo "=================================================="

# Verificar herramientas necesarias
echo "📋 Verificando herramientas..."

tools=("grim" "slurp" "wl-copy" "imv" "hyprctl" "notify-send")
missing=()

for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "✅ $tool - Disponible"
    else
        echo "❌ $tool - NO disponible"
        missing+=("$tool")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  Herramientas faltantes: ${missing[*]}"
    echo "📥 Para instalar: sudo pacman -S ${missing[*]}"
fi

echo ""
echo "📂 Verificando directorio de screenshots..."
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
if [ -d "$SCREENSHOT_DIR" ]; then
    echo "✅ Directorio existe: $SCREENSHOT_DIR"
    echo "📁 Archivos actuales: $(ls -1 "$SCREENSHOT_DIR" 2>/dev/null | wc -l)"
else
    echo "📁 Creando directorio: $SCREENSHOT_DIR"
    mkdir -p "$SCREENSHOT_DIR"
fi

echo ""
echo "🔧 Verificando scripts..."
scripts=("simple-dropdown.sh" "dropdown-capture.sh" "real-freeze.sh")
for script in "${scripts[@]}"; do
    script_path="$HOME/.config/hypr/scripts/$script"
    if [ -x "$script_path" ]; then
        echo "✅ $script - Ejecutable"
    else
        echo "❌ $script - NO ejecutable"
    fi
done

echo ""
echo "⌨️  NUEVAS TECLAS PARA DROPDOWNS:"
echo "================================"
echo "F9           - Captura simple (RECOMENDADA)"
echo "F10          - Captura con selección"
echo "F11          - Congelar sistema"
echo "F12          - Capturar congelado"
echo "Shift + F11  - Descongelar"
echo "Ctrl + F9    - Modo automático"

echo ""
echo "🎯 PRUEBA AHORA:"
echo "1. Abre un desplegable (menú, dropdown, etc.)"
echo "2. Presiona F9"
echo "3. Verifica que se guardó en $SCREENSHOT_DIR"

echo ""
echo "✨ Prueba completada!"
