#!/usr/bin/env bash
# ============================================================================
# EJEMPLO DE USO - Instalador Multi-Distribución
# ============================================================================
# Ejemplo de cómo usar el instalador en diferentes escenarios
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "════════════════════════════════════════════════════════════════"
echo "  EJEMPLO DE USO - Instalador CLI Multi-Distribución"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Mostrar información del sistema
source "$SCRIPT_DIR/distro-utils.sh"

echo "📋 Información del Sistema:"
echo "   Distribución: $DISTRO_NAME"
echo "   ID: $DISTRO_ID"
echo "   Versión: $DISTRO_VERSION"
echo "   Gestor de paquetes: $PKG_MANAGER"
if [ -n "$AUR_HELPER" ]; then
    echo "   AUR Helper: $AUR_HELPER"
fi
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "  EJEMPLOS DE COMANDOS"
echo "════════════════════════════════════════════════════════════════"
echo ""

echo "1️⃣  Instalación Rápida (Escuela/Trabajo con Ubuntu):"
echo "    ./install-cli-tools.sh --packages kitty zsh neovim git starship fzf ripgrep"
echo ""

echo "2️⃣  Instalar Solo Shells (zsh + oh-my-zsh):"
echo "    ./install-cli-tools.sh --shells"
echo ""

echo "3️⃣  Instalar Herramientas de Desarrollo:"
echo "    ./install-cli-tools.sh --dev"
echo ""

echo "4️⃣  Instalar Todo:"
echo "    ./install-cli-tools.sh --all"
echo ""

echo "5️⃣  Modo Interactivo (Menú):"
echo "    ./install-cli-tools.sh"
echo ""

echo "6️⃣  Ver Ayuda:"
echo "    ./install-cli-tools.sh --help"
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "  COMANDOS DISPONIBLES"
echo "════════════════════════════════════════════════════════════════"
echo ""

cat << 'EOF'
Opciones disponibles:
  --all         Instalar todo
  --terminal    Instalar herramientas de terminal (kitty, alacritty, tmux)
  --shells      Instalar shells (fish, zsh + oh-my-zsh)
  --prompts     Instalar prompts (starship)
  --editors     Instalar editores (vim, neovim, LazyVim)
  --cli         Instalar utilidades CLI (htop, fzf, ripgrep, bat, etc)
  --dev         Instalar herramientas de desarrollo (node, python, go, rust)
  --databases   Instalar bases de datos (postgresql, redis)
  --packages    Instalar paquetes específicos
  --update      Actualizar sistema
  --help        Mostrar ayuda

Ejemplos:
  ./install-cli-tools.sh --packages kitty zsh neovim
  ./install-cli-tools.sh --shells
  ./install-cli-tools.sh --all
EOF

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "¿Deseas ejecutar alguno de estos comandos ahora? (s/n)"
read -r response

if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
    echo ""
    echo "Selecciona una opción:"
    echo "1) Instalación Rápida (kitty, zsh, neovim, git, etc)"
    echo "2) Instalar Shells"
    echo "3) Modo Interactivo"
    echo "0) Cancelar"
    read -r option
    
    case $option in
        1)
            "$SCRIPT_DIR/install-cli-tools.sh" --packages kitty zsh neovim git starship fzf ripgrep bat htop
            ;;
        2)
            "$SCRIPT_DIR/install-cli-tools.sh" --shells
            ;;
        3)
            "$SCRIPT_DIR/install-cli-tools.sh"
            ;;
        0)
            echo "Cancelado"
            ;;
        *)
            echo "Opción inválida"
            ;;
    esac
else
    echo "Para ejecutar manualmente, usa los comandos mostrados arriba"
fi
