#!/usr/bin/env bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para instalar Hyprland completo
install_hyprland_full() {
    echo -e "${YELLOW}Instalando Hyprland y componentes...${NC}"
    
    local packages=(
        hyprland
        waybar
        rofi-wayland
        swaybg
        swaylock-effects
        swayidle
        wl-clipboard
        cliphist
        dunst
        grim
        slurp
        xdg-desktop-portal-hyprland
        qt5-wayland
        qt6-wayland
        polkit-kde-agent
    )
    
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    echo -e "${GREEN}Hyprland instalado correctamente${NC}"
}

# Función para configurar temas GTK/Qt
configure_themes() {
    echo -e "${YELLOW}Configurando temas...${NC}"
    
    # Instalar herramientas de temas
    sudo pacman -S --needed --noconfirm gtk-engine-murrine gtk-engines
    
    # Instalar temas
    yay -S --needed --noconfirm \
        catppuccin-gtk-theme-mocha \
        papirus-icon-theme \
        bibata-cursor-theme
    
    # Configurar GTK
    mkdir -p ~/.config/gtk-3.0
    cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Red-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrains Mono Nerd Font 10
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-application-prefer-dark-theme=1
EOF
    
    echo -e "${GREEN}Temas configurados${NC}"
}

# Función para instalar SDDM
install_sddm() {
    echo -e "${YELLOW}Instalando SDDM...${NC}"
    
    sudo pacman -S --needed --noconfirm sddm
    
    # Instalar tema
    yay -S --needed --noconfirm sddm-sugar-candy-git
    
    # Configurar SDDM
    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << EOF
[Theme]
Current=sugar-candy
EOF
    
    # Habilitar SDDM
    sudo systemctl enable sddm
    
    echo -e "${GREEN}SDDM instalado y configurado${NC}"
}

# Función para configurar servicios del sistema
configure_system_services() {
    echo -e "${YELLOW}Configurando servicios del sistema...${NC}"
    
    # NetworkManager
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
    
    # Bluetooth
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
    
    # Docker
    if command -v docker &> /dev/null; then
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
    fi
    
    echo -e "${GREEN}Servicios configurados${NC}"
}

# Menú principal
main() {
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   INSTALACIÓN DE ENTORNO GRÁFICO      ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "1) Instalación completa (Hyprland + SDDM + Temas)"
    echo "2) Solo Hyprland"
    echo "3) Solo SDDM"
    echo "4) Solo temas"
    echo "5) Configurar servicios del sistema"
    echo "0) Volver"
    echo ""
    read -p "Selecciona una opción: " option
    
    case $option in
        1)
            install_hyprland_full
            install_sddm
            configure_themes
            configure_system_services
            ;;
        2)
            install_hyprland_full
            ;;
        3)
            install_sddm
            ;;
        4)
            configure_themes
            ;;
        5)
            configure_system_services
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
