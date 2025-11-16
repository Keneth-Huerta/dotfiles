#!/usr/bin/env bash
# ============================================================================
# DOTFILES INSTALLER - Script Principal
# ============================================================================
# Sistema de instalación modular para restaurar entorno completo en Arch Linux
# Uso: ./install.sh [--full|--gui|--cli|--dev|--configs-only|--custom]
# ============================================================================

set -e  # Salir si hay errores

# ============================================================================
# VARIABLES GLOBALES
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$HOME/.dotfiles-install.log"
CONFIG_DIR="$SCRIPT_DIR/config"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
PACKAGES_DIR="$SCRIPT_DIR/packages"

#!/usr/bin/env bash

# Script de instalación de dotfiles
# Autor: Keneth Isaac Huerta Galindo
# Descripción: Instalador modular para Arch Linux con menú interactivo

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directorio de dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cargar configuración si existe
if [ -f "$DOTFILES_DIR/config.sh" ]; then
    source "$DOTFILES_DIR/config.sh"
fi

# Banner de bienvenida con estilo moderno y colores rojos
show_banner() {
    clear
    echo -e "${RED}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
║   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
║   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
║   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
║   ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
║   ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
║                                                              ║
║              Sistema de Instalación Automática               ║
║                      Arch Linux Edition                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Verificar que estamos en Arch Linux
check_system() {
    if [ ! -f /etc/arch-release ]; then
        echo -e "${RED}Error: Este script está diseñado para Arch Linux${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Sistema Arch Linux detectado${NC}"
}

# Verificar conexión a internet
check_internet() {
    echo -e "${YELLOW}Verificando conexión a internet...${NC}"
    if ping -c 1 archlinux.org &> /dev/null; then
        echo -e "${GREEN}✓ Conexión a internet disponible${NC}"
    else
        echo -e "${RED}Error: No hay conexión a internet${NC}"
        echo -e "${YELLOW}Configura la red antes de continuar${NC}"
        exit 1
    fi
}

# Actualizar sistema
update_system() {
    echo -e "${YELLOW}Actualizando el sistema...${NC}"
    sudo pacman -Syu --noconfirm
    echo -e "${GREEN}✓ Sistema actualizado${NC}"
}

# Menú principal
show_menu() {
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         MENÚ PRINCIPAL                 ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${MAGENTA}1)${NC} Instalación completa (Todo)"
    echo -e "${MAGENTA}2)${NC} Instalar paquetes"
    echo -e "${MAGENTA}3)${NC} Instalar entorno gráfico (Hyprland)"
    echo -e "${MAGENTA}4)${NC} Instalar herramientas CLI"
    echo -e "${MAGENTA}5)${NC} Enlazar configuraciones"
    echo -e "${MAGENTA}6)${NC} Hacer backup de configuraciones actuales"
    echo -e "${MAGENTA}7)${NC} Exportar lista de paquetes instalados"
    echo -e "${MAGENTA}8)${NC} Actualizar sistema"
    echo -e "${MAGENTA}9)${NC} Configuración rápida (solo vim, zsh, fish, starship)"
    echo ""
    echo -e "${CYAN}Avanzado:${NC}"
    echo -e "${MAGENTA}10)${NC} Inicializar dotfiles (copiar configs actuales al repo)"
    echo ""
    echo -e "${RED}0)${NC} Salir"
    echo ""
}

# Instalación rápida para usar en escuela u otras computadoras
quick_install() {
    echo -e "${YELLOW}Instalación rápida de herramientas esenciales...${NC}"
    
    # Herramientas básicas
    sudo pacman -S --needed --noconfirm \
        vim neovim \
        zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting \
        fish \
        starship \
        fzf ripgrep fd bat exa \
        git \
        htop \
        tmux
    
    # Configurar zsh
    if [ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]; then
        cp "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
    fi
    
    # Configurar fish
    if [ -d "$DOTFILES_DIR/config/fish" ]; then
        mkdir -p "$HOME/.config/fish"
        cp -r "$DOTFILES_DIR/config/fish/"* "$HOME/.config/fish/"
    fi
    
    # Configurar vim/neovim
    if [ -d "$DOTFILES_DIR/config/nvim" ]; then
        mkdir -p "$HOME/.config/nvim"
        cp -r "$DOTFILES_DIR/config/nvim/"* "$HOME/.config/nvim/"
    fi
    
    # Configurar starship
    if [ -f "$DOTFILES_DIR/config/starship/starship.toml" ]; then
        mkdir -p "$HOME/.config"
        cp "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"
    fi
    
    # Cambiar shell a fish o zsh
    if [ -n "$DEFAULT_SHELL" ]; then
        chsh -s $(which $DEFAULT_SHELL)
        echo -e "${GREEN}✓ Shell cambiada a $DEFAULT_SHELL${NC}"
    fi
    
    echo -e "${GREEN}✓ Instalación rápida completada${NC}"
}

# Instalación completa
full_install() {
    echo -e "${YELLOW}Iniciando instalación completa...${NC}"
    
    update_system
    
    # Ejecutar scripts de instalación
    bash "$DOTFILES_DIR/scripts/install-packages.sh" || true
    bash "$DOTFILES_DIR/scripts/install-gui.sh" || true
    bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" || true
    bash "$DOTFILES_DIR/scripts/link-configs.sh" || true
    
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ¡INSTALACIÓN COMPLETADA!             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Se recomienda reiniciar el sistema${NC}"
    echo ""
    read -p "¿Deseas reiniciar ahora? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        sudo reboot
    fi
}

# Main loop
main() {
    show_banner
    check_system
    check_internet
    
    while true; do
        show_menu
        read -p "Selecciona una opción: " choice
        
        case $choice in
            1)
                full_install
                ;;
            2)
                bash "$DOTFILES_DIR/scripts/install-packages.sh"
                ;;
            3)
                bash "$DOTFILES_DIR/scripts/install-gui.sh"
                ;;
            4)
                bash "$DOTFILES_DIR/scripts/install-cli-tools.sh"
                ;;
            5)
                bash "$DOTFILES_DIR/scripts/link-configs.sh"
                ;;
            6)
                bash "$DOTFILES_DIR/scripts/backup-configs.sh"
                ;;
            7)
                bash "$DOTFILES_DIR/scripts/export-packages.sh"
                ;;
            8)
                update_system
                ;;
            9)
                quick_install
                ;;
            10)
                bash "$DOTFILES_DIR/scripts/init-dotfiles.sh"
                ;;
            0)
                echo -e "${GREEN}¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida${NC}"
                sleep 2
                ;;
        esac
        
        echo ""
        read -p "Presiona ENTER para continuar..."
        clear
    done
}

main
BOLD='\033[1m'

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

header() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${MAGENTA}  $*${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "No ejecutes este script como root. Usa tu usuario normal."
        log_error "El script pedirá sudo cuando sea necesario."
        exit 1
    fi
}

check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        log_error "Este script está diseñado para Arch Linux"
        exit 1
    fi
}

check_internet() {
    log_info "Verificando conexión a internet..."
    if ! ping -c 1 archlinux.org &> /dev/null; then
        log_error "No hay conexión a internet. Conéctate y vuelve a intentar."
        exit 1
    fi
    log "✓ Conexión a internet OK"
}

check_dependencies() {
    log_info "Verificando dependencias básicas..."
    local deps=("git" "curl" "wget")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "Instalando dependencias faltantes: ${missing[*]}"
        sudo pacman -S --noconfirm --needed "${missing[@]}"
    fi
    log "✓ Dependencias OK"
}

create_backup() {
    log_info "Creando backup de configuraciones existentes..."
    mkdir -p "$BACKUP_DIR"
    
    # Backup de configs importantes
    local configs=(".config/hypr" ".config/waybar" ".config/kitty" ".config/nvim" ".config/fish")
    
    for config in "${configs[@]}"; do
        if [[ -e "$HOME/$config" ]]; then
            log_info "  Respaldando $config"
            mkdir -p "$BACKUP_DIR/$(dirname "$config")"
            cp -r "$HOME/$config" "$BACKUP_DIR/$(dirname "$config")/" 2>/dev/null || true
        fi
    done
    
    log "✓ Backup creado en: $BACKUP_DIR"
}

# ============================================================================
# MENÚ INTERACTIVO
# ============================================================================

show_menu() {
    clear
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║          🚀 INSTALADOR DE DOTFILES - ARCH LINUX 🚀          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

    echo ""
    echo -e "${BOLD}Selecciona el tipo de instalación:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} 🖥️  Instalación Completa ${CYAN}(Entorno + Apps + Configs)${NC}"
    echo -e "  ${GREEN}2)${NC} 💻 Solo Entorno Gráfico ${CYAN}(Hyprland + Waybar + GUI)${NC}"
    echo -e "  ${GREEN}3)${NC} ⌨️  Solo Herramientas CLI ${CYAN}(Nvim + Fish + Tools)${NC}"
    echo -e "  ${GREEN}4)${NC} 👨‍💻 Herramientas de Desarrollo ${CYAN}(Docker + IDEs + Languages)${NC}"
    echo -e "  ${GREEN}5)${NC} 📝 Solo Aplicar Configuraciones ${CYAN}(Sin instalar paquetes)${NC}"
    echo -e "  ${GREEN}6)${NC} 🎨 Instalación Personalizada ${CYAN}(Escoger componentes)${NC}"
    echo -e "  ${GREEN}7)${NC} 🔍 Mostrar lo que se instalará ${CYAN}(Dry run)${NC}"
    echo -e "  ${GREEN}8)${NC} ❌ Salir"
    echo ""
    echo -ne "${BOLD}Opción [1-8]: ${NC}"
}

# ============================================================================
# INSTALACIÓN POR COMPONENTES
# ============================================================================

install_full() {
    header "INSTALACIÓN COMPLETA"
    
    log "Instalando sistema completo..."
    
    source "$SCRIPTS_DIR/utils.sh"
    source "$SCRIPTS_DIR/packages.sh"
    
    install_base_packages
    install_aur_helper
    install_gui_packages
    install_cli_packages
    install_dev_packages
    
    source "$SCRIPTS_DIR/configs.sh"
    apply_all_configs
    
    source "$SCRIPTS_DIR/gui.sh"
    setup_gui_environment
    
    log "✓ Instalación completa finalizada"
    show_finish_message
}

install_gui() {
    header "INSTALACIÓN ENTORNO GRÁFICO"
    
    source "$SCRIPTS_DIR/utils.sh"
    source "$SCRIPTS_DIR/packages.sh"
    source "$SCRIPTS_DIR/gui.sh"
    
    install_gui_packages
    apply_gui_configs
    setup_gui_environment
    
    log "✓ Entorno gráfico instalado"
}

install_cli() {
    header "INSTALACIÓN HERRAMIENTAS CLI"
    
    source "$SCRIPTS_DIR/utils.sh"
    source "$SCRIPTS_DIR/packages.sh"
    source "$SCRIPTS_DIR/configs.sh"
    
    install_cli_packages
    apply_cli_configs
    
    log "✓ Herramientas CLI instaladas"
}

install_dev() {
    header "INSTALACIÓN HERRAMIENTAS DE DESARROLLO"
    
    source "$SCRIPTS_DIR/utils.sh"
    source "$SCRIPTS_DIR/packages.sh"
    
    install_dev_packages
    
    log "✓ Herramientas de desarrollo instaladas"
}

install_configs_only() {
    header "APLICANDO SOLO CONFIGURACIONES"
    
    source "$SCRIPTS_DIR/configs.sh"
    apply_all_configs
    
    log "✓ Configuraciones aplicadas"
}

install_custom() {
    header "INSTALACIÓN PERSONALIZADA"
    
    echo ""
    echo -e "${BOLD}Selecciona los componentes a instalar:${NC}"
    echo ""
    
    # Menú de checkboxes simulado
    declare -A components
    components=(
        ["base"]="Paquetes base del sistema"
        ["gui"]="Entorno gráfico (Hyprland + Waybar)"
        ["cli"]="Herramientas CLI (Nvim, Fish, etc)"
        ["dev"]="Herramientas de desarrollo"
        ["apps"]="Aplicaciones (Brave, Discord, etc)"
        ["configs"]="Aplicar configuraciones"
    )
    
    local selected=()
    
    for key in base gui cli dev apps configs; do
        echo -ne "${YELLOW}¿Instalar ${components[$key]}? [S/n]: ${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Nn]$ ]]; then
            selected+=("$key")
        fi
    done
    
    # Instalar componentes seleccionados
    source "$SCRIPTS_DIR/utils.sh"
    source "$SCRIPTS_DIR/packages.sh"
    source "$SCRIPTS_DIR/configs.sh"
    
    for component in "${selected[@]}"; do
        case "$component" in
            base) install_base_packages ;;
            gui) install_gui_packages; setup_gui_environment ;;
            cli) install_cli_packages ;;
            dev) install_dev_packages ;;
            apps) install_app_packages ;;
            configs) apply_all_configs ;;
        esac
    done
    
    log "✓ Instalación personalizada completada"
}

dry_run() {
    header "MODO DRY RUN - Mostrando paquetes a instalar"
    
    echo ""
    echo -e "${BOLD}${CYAN}=== PAQUETES BASE ===${NC}"
    [[ -f "$PACKAGES_DIR/base.txt" ]] && cat "$PACKAGES_DIR/base.txt"
    
    echo ""
    echo -e "${BOLD}${CYAN}=== PAQUETES GUI ===${NC}"
    [[ -f "$PACKAGES_DIR/gui.txt" ]] && cat "$PACKAGES_DIR/gui.txt"
    
    echo ""
    echo -e "${BOLD}${CYAN}=== HERRAMIENTAS CLI ===${NC}"
    [[ -f "$PACKAGES_DIR/cli.txt" ]] && cat "$PACKAGES_DIR/cli.txt"
    
    echo ""
    echo -e "${BOLD}${CYAN}=== DESARROLLO ===${NC}"
    [[ -f "$PACKAGES_DIR/dev.txt" ]] && cat "$PACKAGES_DIR/dev.txt"
    
    echo ""
    echo -e "${BOLD}${CYAN}=== AUR PACKAGES ===${NC}"
    [[ -f "$PACKAGES_DIR/aur.txt" ]] && cat "$PACKAGES_DIR/aur.txt"
    
    echo ""
}

show_finish_message() {
    clear
    cat << "EOF"

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              ✨ INSTALACIÓN COMPLETADA ✨                    ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF

    echo -e "${GREEN}¡Todo listo!${NC} Tu sistema ha sido configurado correctamente."
    echo ""
    echo -e "${YELLOW}Próximos pasos:${NC}"
    echo ""
    echo "  1. Reinicia tu sesión: logout y vuelve a entrar"
    echo "  2. Si instalaste Hyprland, selecciónalo en el login manager"
    echo "  3. Revisa los logs: tail -f $LOG_FILE"
    echo "  4. Backup guardado en: $BACKUP_DIR"
    echo ""
    echo -e "${CYAN}Tips:${NC}"
    echo "  - Configuraciones en ~/.config/"
    echo "  - Para actualizar: cd ~/dotfiles && git pull && ./install.sh --configs-only"
    echo "  - Reporta issues en GitHub si encuentras problemas"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    # Validaciones iniciales
    check_root
    check_arch
    check_internet
    check_dependencies
    
    # Crear backup
    create_backup
    
    # Iniciar log
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "Inicio de instalación de dotfiles"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Procesar argumentos o mostrar menú
    if [[ $# -eq 0 ]]; then
        # Modo interactivo
        while true; do
            show_menu
            read -r choice
            
            case $choice in
                1) install_full; break ;;
                2) install_gui; break ;;
                3) install_cli; break ;;
                4) install_dev; break ;;
                5) install_configs_only; break ;;
                6) install_custom; break ;;
                7) dry_run; echo ""; read -p "Presiona Enter para continuar..."; continue ;;
                8) echo "Saliendo..."; exit 0 ;;
                *) echo -e "${RED}Opción inválida${NC}"; sleep 2; continue ;;
            esac
        done
    else
        # Modo línea de comandos
        case "$1" in
            --full) install_full ;;
            --gui) install_gui ;;
            --cli) install_cli ;;
            --dev) install_dev ;;
            --configs-only) install_configs_only ;;
            --custom) install_custom ;;
            --dry-run) dry_run ;;
            --help)
                echo "Uso: $0 [OPCIÓN]"
                echo ""
                echo "Opciones:"
                echo "  --full          Instalación completa"
                echo "  --gui           Solo entorno gráfico"
                echo "  --cli           Solo herramientas CLI"
                echo "  --dev           Solo herramientas de desarrollo"
                echo "  --configs-only  Solo aplicar configuraciones"
                echo "  --custom        Instalación personalizada"
                echo "  --dry-run       Mostrar paquetes sin instalar"
                echo "  --help          Mostrar esta ayuda"
                exit 0
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Usa --help para ver opciones disponibles"
                exit 1
                ;;
        esac
    fi
}

# Ejecutar script
main "$@"
