#!/usr/bin/env bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para instalar herramientas de terminal
install_terminal_tools() {
    echo -e "${YELLOW}Instalando herramientas de terminal...${NC}"
    
    local packages=(
        kitty
        alacritty
        tmux
    )
    
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    echo -e "${GREEN}Herramientas de terminal instaladas${NC}"
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
    
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # Instalar oh-my-fish
    if [ ! -d ~/.local/share/omf ]; then
        curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
    fi
    
    # Instalar oh-my-zsh
    if [ ! -d ~/.oh-my-zsh ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    echo -e "${GREEN}Shells instalados${NC}"
}

# Función para instalar prompts
install_prompts() {
    echo -e "${YELLOW}Instalando prompts...${NC}"
    
    sudo pacman -S --needed --noconfirm starship
    yay -S --needed --noconfirm oh-my-posh-bin
    
    echo -e "${GREEN}Prompts instalados${NC}"
}

# Función para instalar editores
install_editors() {
    echo -e "${YELLOW}Instalando editores...${NC}"
    
    local packages=(
        neovim
        vim
    )
    
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # Instalar LazyVim
    echo -e "${YELLOW}¿Deseas instalar LazyVim? (s/n)${NC}"
    read -r response
    if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
        # Backup de configuración existente
        mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
        mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
        
        # Clonar LazyVim
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
    fi
    
    echo -e "${GREEN}Editores instalados${NC}"
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
        exa
        
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
    
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    echo -e "${GREEN}Utilidades CLI instaladas${NC}"
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
        
        # Bases de datos
        postgresql
        redis
        
        # Contenedores
        docker
        docker-compose
        
        # Build tools
        base-devel
        cmake
        make
    )
    
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # Configurar npm global sin sudo
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'
    
    echo -e "${GREEN}Herramientas de desarrollo instaladas${NC}"
}

# Menú principal
main() {
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   INSTALACIÓN DE HERRAMIENTAS CLI     ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "1) Instalar todo"
    echo "2) Herramientas de terminal"
    echo "3) Shells (fish, zsh)"
    echo "4) Prompts (starship, oh-my-posh)"
    echo "5) Editores (vim, neovim)"
    echo "6) Utilidades CLI (htop, fzf, ripgrep, etc)"
    echo "7) Herramientas de desarrollo"
    echo "0) Volver"
    echo ""
    read -p "Selecciona una opción: " option
    
    case $option in
        1)
            install_terminal_tools
            install_shells
            install_prompts
            install_editors
            install_cli_utilities
            install_dev_tools
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
        0)
            return
            ;;
        *)
            echo -e "${RED}Opción inválida${NC}"
            ;;
    esac
    
    echo -e "${GREEN}¡Instalación completada!${NC}"
}

main
