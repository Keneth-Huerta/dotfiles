#!/usr/bin/env bash
# ============================================================================
# CLI TOOLS INSTALLER - Compatible con múltiples distribuciones
# ============================================================================
# Instala herramientas de terminal, shells, editores y utilidades CLI
# Soporta: Arch, Ubuntu/Debian, Fedora y más
# ============================================================================

# Obtener directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Cargar utilidades de distribución
if [ -f "$SCRIPT_DIR/distro-utils.sh" ]; then
    source "$SCRIPT_DIR/distro-utils.sh"
else
    echo "Error: No se encontró distro-utils.sh"
    exit 1
fi

# Variables globales
INTERACTIVE=true

# ============================================================================
# FUNCIONES DE ENLACE DE CONFIGURACIONES
# ============================================================================

# Función para crear symlink con backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$target")"
    
    # Si el target existe y no es un symlink, hacer backup
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        log_warn "Haciendo backup de $target"
        mv "$target" "${target}.bak"
    fi
    
    # Si ya es un symlink, eliminarlo
    if [ -L "$target" ]; then
        rm "$target"
    fi
    
    # Crear symlink
    ln -s "$source" "$target"
    log_success "Linked: $target -> $source"
}

# Función para enlazar configuraciones de Kitty
link_kitty_config() {
    if [ -d "$DOTFILES_DIR/config/kitty" ]; then
        log_info "Enlazando configuración de Kitty..."
        create_symlink "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"
    fi
}

# Función para enlazar configuraciones de Zsh
link_zsh_config() {
    if [ -d "$DOTFILES_DIR/config/zsh" ]; then
        log_info "Enlazando configuración de Zsh..."
        
        if [ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]; then
            create_symlink "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
        fi
        
        if [ -f "$DOTFILES_DIR/config/zsh/.zshenv" ]; then
            create_symlink "$DOTFILES_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
        fi
        
        # Enlazar .p10k.zsh si existe
        if [ -f "$DOTFILES_DIR/config/zsh/.p10k.zsh" ]; then
            create_symlink "$DOTFILES_DIR/config/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
        fi
    fi
}

# Función para enlazar configuraciones de Neovim
link_neovim_config() {
    if [ -d "$DOTFILES_DIR/config/nvim" ]; then
        log_info "Enlazando configuración de Neovim..."
        create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
    fi
}

# Función para enlazar configuraciones de Starship
link_starship_config() {
    if [ -f "$DOTFILES_DIR/config/starship/starship.toml" ]; then
        log_info "Enlazando configuración de Starship..."
        create_symlink "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"
    fi
}

# ============================================================================
# FUNCIONES DE INSTALACIÓN
# ============================================================================

# Función para instalar herramientas de terminal
install_terminal_tools() {
    echo -e "${YELLOW}Instalando herramientas de terminal...${NC}"
    
    local packages=(
        kitty
        alacritty
        tmux
    )
    
    pkg_install "${packages[@]}"
    log_success "Herramientas de terminal instaladas"
    
    # Enlazar configuraciones automáticamente
    link_kitty_config
}

# Función para instalar shells
install_shells() {
    echo -e "${YELLOW}Instalando shells...${NC}"
    
    local packages=(
        fish
        zsh
        zsh-completions
        zsh-autosuggestions
        zsh-syntax-highlighting
    )
    
    pkg_install "${packages[@]}"
    
    # Instalar oh-my-zsh
    install_oh_my_zsh
    
    # Instalar powerlevel10k
    install_powerlevel10k
    
    # Instalar oh-my-fish solo si fish está instalado
    if command_exists fish; then
        install_oh_my_fish
    fi
    
    log_success "Shells instalados"
    
    # Enlazar configuraciones automáticamente
    link_zsh_config
}

# Función para instalar prompts
install_prompts() {
    echo -e "${YELLOW}Instalando prompts...${NC}"
    
    # Starship está disponible en la mayoría de distros
    install_starship
    
    # oh-my-posh solo en Arch desde AUR
    if [ "$PKG_MANAGER" = "pacman" ] && [ -n "$AUR_HELPER" ]; then
        aur_install oh-my-posh-bin
    else
        log_info "oh-my-posh: instalación manual disponible en https://ohmyposh.dev"
    fi
    
    log_success "Prompts instalados"
    
    # Enlazar configuraciones automáticamente
    link_starship_config
}

# Función para instalar editores
install_editors() {
    echo -e "${YELLOW}Instalando editores...${NC}"
    
    local packages=(
        neovim
        vim
    )
    
    pkg_install "${packages[@]}"
    
    # Preguntar por NvChad solo en modo interactivo
    if [ "$INTERACTIVE" = true ]; then
        echo -e "${YELLOW}¿Deseas instalar NvChad? (s/n)${NC}"
        read -r response
        if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
            install_nvchad
        fi
    fi
    
    log_success "Editores instalados"
    
    # Enlazar configuraciones automáticamente
    link_neovim_config
}

# Instalar NvChad
install_nvchad() {
    log_info "Instalando NvChad..."
    
    # Backup de configuración existente
    if [ -d ~/.config/nvim ]; then
        log_warn "Respaldando configuración existente de nvim..."
        mv ~/.config/nvim ~/.config/nvim.bak.$(date +%Y%m%d-%H%M%S)
    fi
    if [ -d ~/.local/share/nvim ]; then
        mv ~/.local/share/nvim ~/.local/share/nvim.bak.$(date +%Y%m%d-%H%M%S)
    fi
    if [ -d ~/.local/state/nvim ]; then
        mv ~/.local/state/nvim ~/.local/state/nvim.bak.$(date +%Y%m%d-%H%M%S)
    fi
    if [ -d ~/.cache/nvim ]; then
        mv ~/.cache/nvim ~/.cache/nvim.bak.$(date +%Y%m%d-%H%M%S)
    fi
    
    # Clonar NvChad
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
    
    log_success "NvChad instalado"
    log_info "Para configurar NvChad, ejecuta 'nvim' y espera a que termine la instalación de plugins"
}

# Función para instalar utilidades CLI
install_cli_utilities() {
    echo -e "${YELLOW}Instalando utilidades CLI...${NC}"
    
    local packages=(
        # Monitores de sistema
        htop
        btop
        
        # Información del sistema
        fastfetch
        neofetch
        
        # Búsqueda y navegación
        fzf
        ripgrep
        fd
        bat
        
        # File managers
        ranger
        nnn
        
        # Utilidades de archivos
        ncdu
        trash-cli
        
        # Network tools
        curl
        wget
        aria2
        
        # Git
        git
        git-delta
        lazygit
        
        # Multiplexers
        tmux
        
        # Otros
        jq
        tree
        tldr
    )
    
    # exa/eza según disponibilidad
    if [ "$PKG_MANAGER" = "pacman" ]; then
        packages+=(eza)
    elif command_exists exa; then
        packages+=(exa)
    fi
    
    pkg_install "${packages[@]}"
    log_success "Utilidades CLI instaladas"
}

# Función para instalar herramientas de desarrollo
install_dev_tools() {
    echo -e "${YELLOW}Instalando herramientas de desarrollo...${NC}"
    
    local packages=(
        # Lenguajes
        nodejs
        npm
        python
        python-pip
        go
        rust
        
        # Contenedores
        docker
        docker-compose
        
        # Build tools
        base-devel
        cmake
        make
    )
    
    pkg_install "${packages[@]}"
    
    # Configurar npm global sin sudo
    if command_exists npm; then
        mkdir -p ~/.npm-global
        npm config set prefix '~/.npm-global'
        
        # Agregar a PATH si no está
        if ! grep -q "npm-global/bin" ~/.bashrc 2>/dev/null; then
            echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
        fi
        if [ -f ~/.zshrc ] && ! grep -q "npm-global/bin" ~/.zshrc; then
            echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
        fi
    fi
    
    log_success "Herramientas de desarrollo instaladas"
}

# Instalar bases de datos
install_databases() {
    echo -e "${YELLOW}Instalando bases de datos...${NC}"
    
    local packages=(
        postgresql
        redis
    )
    
    pkg_install "${packages[@]}"
    log_success "Bases de datos instaladas"
}


# ============================================================================
# INSTALACIÓN SELECTIVA
# ============================================================================

# Función para instalar paquetes específicos
install_specific_packages() {
    if [ $# -eq 0 ]; then
        log_error "No se especificaron paquetes"
        echo "Uso: $0 --packages kitty zsh neovim ..."
        return 1
    fi
    
    local packages=("$@")
    log_info "Instalando paquetes específicos: ${packages[*]}"
    
    pkg_install "${packages[@]}"
    log_success "Paquetes instalados"
}

# ============================================================================
# MENÚ PRINCIPAL
# ============================================================================

show_menu() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   INSTALACIÓN DE HERRAMIENTAS CLI                 ║${NC}"
    echo -e "${CYAN}║   Distribución: ${DISTRO_NAME}${NC}"
    echo -e "${CYAN}║   Gestor de paquetes: ${PKG_MANAGER}${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1)  Instalar todo"
    echo "2)  Herramientas de terminal (kitty, alacritty, tmux)"
    echo "3)  Shells (fish, zsh + oh-my-zsh + powerlevel10k)"
    echo "4)  Prompts (starship, oh-my-posh)"
    echo "5)  Editores (vim, neovim, NvChad)"
    echo "6)  Utilidades CLI (htop, fzf, ripgrep, bat, etc)"
    echo "7)  Herramientas de desarrollo (node, python, go, rust)"
    echo "8)  Bases de datos (postgresql, redis)"
    echo "9)  Instalar paquetes específicos"
    echo "10) Actualizar sistema"
    echo "0)  Salir"
    echo ""
}

# Menú principal
main() {
    # Verificar si se detectó la distribución correctamente
    if [ -z "$DISTRO_ID" ]; then
        log_error "No se pudo detectar la distribución"
        exit 1
    fi
    
    # Modo no interactivo con argumentos
    if [ $# -gt 0 ]; then
        INTERACTIVE=false
        
        case "$1" in
            --all)
                install_terminal_tools
                install_shells
                install_prompts
                install_editors
                install_cli_utilities
                install_dev_tools
                install_databases
                ;;
            --terminal)
                install_terminal_tools
                ;;
            --shells)
                install_shells
                ;;
            --prompts)
                install_prompts
                ;;
            --editors)
                install_editors
                ;;
            --cli)
                install_cli_utilities
                ;;
            --dev)
                install_dev_tools
                ;;
            --databases)
                install_databases
                ;;
            --packages)
                shift
                install_specific_packages "$@"
                ;;
            --update)
                pkg_update
                ;;
            --help)
                echo "Uso: $0 [OPCIÓN]"
                echo ""
                echo "Opciones:"
                echo "  --all         Instalar todo"
                echo "  --terminal    Instalar herramientas de terminal"
                echo "  --shells      Instalar shells (fish, zsh + powerlevel10k)"
                echo "  --prompts     Instalar prompts (starship)"
                echo "  --editors     Instalar editores (vim, neovim, NvChad)"
                echo "  --cli         Instalar utilidades CLI"
                echo "  --dev         Instalar herramientas de desarrollo"
                echo "  --databases   Instalar bases de datos"
                echo "  --packages    Instalar paquetes específicos"
                echo "  --update      Actualizar sistema"
                echo "  --help        Mostrar esta ayuda"
                echo ""
                echo "Ejemplos:"
                echo "  $0 --packages kitty zsh neovim"
                echo "  $0 --shells"
                echo "  $0 --all"
                ;;
            *)
                log_error "Opción desconocida: $1"
                echo "Usa --help para ver las opciones disponibles"
                exit 1
                ;;
        esac
        
        log_success "¡Instalación completada!"
        return 0
    fi
    
    # Modo interactivo
    while true; do
        show_menu
        read -p "Selecciona una opción: " option
        
        case $option in
            1)
                install_terminal_tools
                install_shells
                install_prompts
                install_editors
                install_cli_utilities
                install_dev_tools
                install_databases
                ;;
            2)
                install_terminal_tools
                ;;
            3)
                install_shells
                ;;
            4)
                install_prompts
                ;;
            5)
                install_editors
                ;;
            6)
                install_cli_utilities
                ;;
            7)
                install_dev_tools
                ;;
            8)
                install_databases
                ;;
            9)
                echo ""
                echo "Ingresa los nombres de los paquetes separados por espacio:"
                read -r -a packages
                install_specific_packages "${packages[@]}"
                ;;
            10)
                pkg_update
                ;;
            0)
                echo -e "${GREEN}¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                log_error "Opción inválida"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}Presiona Enter para continuar...${NC}"
        read -r
    done
}

# Ejecutar menú principal
main "$@"

# Mostrar resumen de paquetes fallidos al final
show_failed_packages_summary

