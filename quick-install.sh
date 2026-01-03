#!/usr/bin/env bash
# ============================================================================
# INSTALADOR RÁPIDO - Compatible con todas las distribuciones
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                      DOTFILES INSTALLER                      ║
║                  Multi-Distribution Edition                  ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo ""

# Detectar distribución
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${BLUE}Distribución detectada:${NC} ${GREEN}$NAME${NC}"
    echo ""
fi

# Mensaje informativo
cat << EOF
${YELLOW}════════════════════════════════════════════════════════════════${NC}
${YELLOW}  IMPORTANTE: Nuevo Sistema de Instalación${NC}
${YELLOW}════════════════════════════════════════════════════════════════${NC}

${BLUE}El script install.sh está optimizado para Arch Linux con Hyprland.${NC}

${GREEN}Para instalar herramientas CLI en cualquier distribución (Fedora, Ubuntu, etc.):${NC}

  ${CYAN}1. Instalación Rápida:${NC}
     cd $SCRIPT_DIR/scripts
     ./install-cli-tools.sh --packages kitty zsh neovim git starship

  ${CYAN}2. Modo Interactivo (Recomendado):${NC}
     cd $SCRIPT_DIR/scripts
     ./install-cli-tools.sh

  ${CYAN}3. Ver Guía Rápida:${NC}
     ./QUICK-START.sh

  ${CYAN}4. Instalación por Categorías:${NC}
     ./scripts/install-cli-tools.sh --shells      # zsh + oh-my-zsh
     ./scripts/install-cli-tools.sh --editors     # vim, neovim
     ./scripts/install-cli-tools.sh --cli         # utilidades CLI

${YELLOW}════════════════════════════════════════════════════════════════${NC}

EOF

# Preguntar si quiere ejecutar el instalador CLI
echo -e "${YELLOW}¿Deseas ejecutar el instalador CLI ahora? (s/n)${NC}"
read -r response

if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
    exec "$SCRIPT_DIR/scripts/install-cli-tools.sh"
else
    echo ""
    echo -e "${BLUE}Para más información:${NC}"
    echo "  - Guía completa: docs/CLI-INSTALL-GUIDE.md"
    echo "  - Guía rápida: ./QUICK-START.sh"
    echo "  - Ayuda: ./scripts/install-cli-tools.sh --help"
    echo ""
fi
