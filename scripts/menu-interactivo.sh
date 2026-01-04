#!/usr/bin/env bash
# ============================================================================
# MENÚ INTERACTIVO MEJORADO - Con selección múltiple
# ============================================================================
# Usa whiptail/dialog para un menú más moderno y funcional
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Detectar herramienta de diálogo disponible
if command -v whiptail &> /dev/null; then
    DIALOG="whiptail"
elif command -v dialog &> /dev/null; then
    DIALOG="dialog"
else
    echo -e "${YELLOW}Instalando whiptail para menús interactivos...${NC}"
    sudo pacman -S --noconfirm libnewt 2>/dev/null || sudo apt-get install -y whiptail 2>/dev/null
    DIALOG="whiptail"
fi

# ============================================================================
# MENÚ PRINCIPAL CON SELECCIÓN MÚLTIPLE
# ============================================================================

show_main_menu() {
    local options=(
        "1" "Instalación completa (Todo)" OFF
        "2" "Herramientas de terminal (kitty, alacritty)" OFF
        "3" "Shells (zsh, fish, oh-my-zsh, powerlevel10k)" OFF
        "4" "Editores (neovim, vim, NvChad)" OFF
        "5" "Utilidades CLI (fzf, ripgrep, bat, etc)" OFF
        "6" "Herramientas de desarrollo (node, python, docker)" OFF
        "7" "Entorno gráfico (Hyprland, Waybar)" OFF
        "8" "Bases de datos (postgresql, redis)" OFF
        "9" "Enlazar configuraciones" OFF
        "10" "Actualizar configuraciones al repo" OFF
    )
    
    local selected
    selected=$($DIALOG --title "Instalador de Dotfiles" \
        --checklist "Selecciona qué instalar (Espacio=Seleccionar, Enter=Confirmar):" \
        20 70 10 \
        "${options[@]}" \
        3>&1 1>&2 2>&3)
    
    local exitstatus=$?
    
    if [ $exitstatus != 0 ]; then
        echo -e "${YELLOW}Instalación cancelada${NC}"
        exit 0
    fi
    
    # Ejecutar opciones seleccionadas
    if [ -n "$selected" ]; then
        for choice in $selected; do
            choice=$(echo $choice | tr -d '"')
            execute_option "$choice"
        done
        
        echo ""
        echo -e "${GREEN}✓ Instalación completada${NC}"
        echo ""
    else
        echo -e "${YELLOW}No se seleccionó nada${NC}"
    fi
}

# ============================================================================
# EJECUTAR OPCIÓN
# ============================================================================

execute_option() {
    local option="$1"
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $option in
        1)
            echo -e "${YELLOW}Instalación completa...${NC}"
            bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" --all
            bash "$DOTFILES_DIR/scripts/install-gui.sh" 2>/dev/null || true
            bash "$DOTFILES_DIR/scripts/link-configs.sh"
            ;;
        2)
            echo -e "${YELLOW}Instalando herramientas de terminal...${NC}"
            bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" --terminal
            ;;
        3)
            echo -e "${YELLOW}Instalando shells...${NC}"
            bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" --shells
            ;;
        4)
            echo -e "${YELLOW}Instalando editores...${NC}"
            bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" --editors
            ;;
        5)
            echo -e "${YELLOW}Instalando utilidades CLI...${NC}"
            bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" --cli
            ;;
        6)
            echo -e "${YELLOW}Instalando herramientas de desarrollo...${NC}"
            bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" --dev
            ;;
        7)
            echo -e "${YELLOW}Instalando entorno gráfico...${NC}"
            bash "$DOTFILES_DIR/scripts/install-gui.sh" 2>/dev/null || echo "Script de GUI no disponible"
            ;;
        8)
            echo -e "${YELLOW}Instalando bases de datos...${NC}"
            bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" --databases
            ;;
        9)
            echo -e "${YELLOW}Enlazando configuraciones...${NC}"
            bash "$DOTFILES_DIR/scripts/link-configs.sh"
            ;;
        10)
            echo -e "${YELLOW}Actualizando configuraciones...${NC}"
            bash "$DOTFILES_DIR/scripts/update-dotfiles.sh"
            ;;
    esac
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================================================
# MENÚ DE GESTIÓN
# ============================================================================

show_management_menu() {
    local choice
    choice=$($DIALOG --title "Gestión de Dotfiles" \
        --menu "Selecciona una opción:" 15 60 8 \
        "1" "Ver estado de symlinks" \
        "2" "Hacer backup de configs" \
        "3" "Actualizar configs al repo" \
        "4" "Gestionar repositorios" \
        "5" "Gestionar claves SSH" \
        "6" "Verificar salud del sistema" \
        "7" "Volver al menú principal" \
        3>&1 1>&2 2>&3)
    
    case $choice in
        1)
            bash "$DOTFILES_DIR/install.sh" --symlink-status
            ;;
        2)
            bash "$DOTFILES_DIR/scripts/backup-configs.sh"
            ;;
        3)
            bash "$DOTFILES_DIR/scripts/update-dotfiles.sh"
            ;;
        4)
            bash "$DOTFILES_DIR/scripts/repo-manager.sh"
            ;;
        5)
            bash "$DOTFILES_DIR/scripts/ssh-manager.sh"
            ;;
        6)
            bash "$DOTFILES_DIR/scripts/health-check.sh"
            ;;
        7)
            return
            ;;
    esac
}

# ============================================================================
# MENÚ PRINCIPAL
# ============================================================================

main() {
    clear
    
    # Banner
    echo -e "${RED}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
║   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
║   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
║   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
║   ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
║   ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
║                                                              ║
║              Menú Interactivo Mejorado                       ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Menú de tipo
    local menu_type
    menu_type=$($DIALOG --title "Instalador de Dotfiles" \
        --menu "¿Qué deseas hacer?" 12 60 4 \
        "1" "Instalar componentes (selección múltiple)" \
        "2" "Gestión y mantenimiento" \
        "3" "Salir" \
        3>&1 1>&2 2>&3)
    
    case $menu_type in
        1)
            show_main_menu
            ;;
        2)
            show_management_menu
            ;;
        3)
            echo -e "${GREEN}¡Hasta luego!${NC}"
            exit 0
            ;;
    esac
}

# Ejecutar
main
