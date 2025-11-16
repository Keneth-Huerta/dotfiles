#!/usr/bin/env bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para instalar paquetes oficiales
install_official_packages() {
    echo -e "${YELLOW}Instalando paquetes oficiales...${NC}"
    
    local packages=(
        # Sistema base
        base-devel git wget curl
        
        # Hyprland y Wayland
        hyprland waybar rofi-wayland swaybg swaylock-effects
        swayidle wl-clipboard cliphist dunst
        
        # Terminal y shell
        kitty fish zsh starship fzf
        
        # Editores
        neovim
        
        # Herramientas de desarrollo
        nodejs npm python python-pip go rust
        docker docker-compose
        
        # Fuentes
        ttf-jetbrains-mono-nerd ttf-fira-code nerd-fonts-complete
        ttf-font-awesome otf-font-awesome
        
        # Multimedia
        mpv ffmpeg gstreamer
        
        # Utilidades
        htop btop fastfetch ripgrep fd bat exa
        ranger nnn ncdu trash-cli
        
        # Navegadores
        firefox chromium
        
        # File manager
        thunar
        
        # Gestor de archivos comprimidos
        unzip unrar p7zip
        
        # Network
        networkmanager nm-connection-editor
        
        # Audio
        pipewire pipewire-pulse pipewire-alsa pipewire-jack
        pavucontrol
        
        # Bluetooth
        bluez bluez-utils blueman
        
        # Screenshots
        grim slurp
        
        # PDF viewer
        zathura zathura-pdf-mupdf
    )
    
    sudo pacman -S --needed --noconfirm "${packages[@]}"
}

# Función para instalar yay (AUR helper)
install_yay() {
    if command -v yay &> /dev/null; then
        echo -e "${GREEN}yay ya está instalado${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Instalando yay...${NC}"
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
}

# Función para instalar paquetes AUR
install_aur_packages() {
    echo -e "${YELLOW}Instalando paquetes AUR...${NC}"
    
    local aur_packages=(
        # Terminal y shell
        oh-my-posh-bin
        
        # Hyprland extras
        hyprpicker-git
        
        # Fonts
        ttf-meslo-nerd-font-powerlevel10k
        
        # Themes
        catppuccin-gtk-theme-mocha
        papirus-icon-theme
        
        # Herramientas
        postman-bin
        visual-studio-code-bin
        brave-bin
        
        # Otros
        spotify
        discord
        telegram-desktop
    )
    
    yay -S --needed --noconfirm "${aur_packages[@]}"
}

# Función para instalar flatpak y aplicaciones
install_flatpak_packages() {
    echo -e "${YELLOW}Instalando flatpak...${NC}"
    sudo pacman -S --needed --noconfirm flatpak
    
    echo -e "${YELLOW}Agregando repositorio Flathub...${NC}"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    echo -e "${YELLOW}Instalando aplicaciones flatpak...${NC}"
    local flatpak_apps=(
        com.bitwarden.desktop
        org.gimp.GIMP
        org.inkscape.Inkscape
        com.obsproject.Studio
        org.videolan.VLC
    )
    
    for app in "${flatpak_apps[@]}"; do
        flatpak install -y flathub "$app"
    done
}

# Menú principal
main() {
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   INSTALACIÓN DE PAQUETES              ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "1) Instalar todos los paquetes"
    echo "2) Solo paquetes oficiales"
    echo "3) Solo paquetes AUR"
    echo "4) Solo flatpak"
    echo "0) Volver"
    echo ""
    read -p "Selecciona una opción: " option
    
    case $option in
        1)
            install_official_packages
            install_yay
            install_aur_packages
            install_flatpak_packages
            ;;
        2)
            install_official_packages
            ;;
        3)
            install_yay
            install_aur_packages
            ;;
        4)
            install_flatpak_packages
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
