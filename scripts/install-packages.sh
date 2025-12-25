#!/usr/bin/env bash

set -e  # Salir en caso de error

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Control de sudo
SUDO_CACHED=false

# Función para cachear sudo
cache_sudo() {
    if [[ "$SUDO_CACHED" == true ]]; then
        return 0
    fi
    
    if sudo -v 2>/dev/null; then
        SUDO_CACHED=true
        # Mantener sudo activo
        (while true; do sleep 240; sudo -n true 2>/dev/null || exit; done) &
        return 0
    else
        handle_error "No se pudieron verificar las credenciales sudo"
        return 1
    fi
}

# Ejecutar comando con sudo
run_sudo() {
    if [[ "$SUDO_CACHED" != true ]]; then
        cache_sudo || return 1
    fi
    sudo "$@"
}

# Función para manejar errores
handle_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    return 1
}

# Función para log de información
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Función para habilitar el repositorio multilib (32-bit)
enable_multilib() {
    echo -e "${YELLOW}Verificando repositorio multilib...${NC}"
    
    # Verificar si ya está habilitado
    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo -e "${GREEN}✓ Repositorio multilib ya está habilitado${NC}"
        return 0
    fi
    
    log_info "Habilitando repositorio multilib (32-bit)..."
    
    # Habilitar multilib descomentando las líneas en pacman.conf
    run_sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
    
    echo -e "${GREEN}✓ Repositorio multilib habilitado${NC}"
    echo -e "${BLUE}[INFO]${NC} Actualizando base de datos de paquetes..."
    run_sudo pacman -Sy
    
    echo -e "${GREEN}✓ Ahora puedes instalar paquetes de 32-bit (steam, wine32, etc.)${NC}"
}

# Función para configurar el repositorio de BlackArch
setup_blackarch_repo() {
    echo -e "${YELLOW}Configurando repositorio de BlackArch...${NC}"
    
    # Verificar si ya está configurado
    if grep -q "\[blackarch\]" /etc/pacman.conf; then
        echo -e "${GREEN}✓ Repositorio BlackArch ya está configurado${NC}"
        return 0
    fi
    
    log_info "Descargando e instalando blackarch-keyring..."
    
    # Descargar y ejecutar el script de instalación de BlackArch
    cd /tmp
    curl -O https://blackarch.org/strap.sh
    
    # Verificar checksum
    echo "26849980b35a42e6e192c6d9ed8c46f0d6d06047 strap.sh" | sha1sum -c - || {
        log_warn "Checksum no coincide, descargando nuevamente..."
        rm strap.sh
        curl -O https://blackarch.org/strap.sh
    }
    
    # Hacer ejecutable y ejecutar
    chmod +x strap.sh
    run_sudo ./strap.sh
    
    # Limpiar
    rm strap.sh
    
    echo -e "${GREEN}✓ Repositorio BlackArch configurado${NC}"
    echo -e "${BLUE}[INFO]${NC} Actualizando base de datos de paquetes..."
    run_sudo pacman -Sy
    
    echo -e "${GREEN}✓ Ahora puedes instalar paquetes de BlackArch con: run_sudo pacman -S <paquete>${NC}"
    echo -e "${BLUE}[INFO]${NC} Lista de herramientas: https://blackarch.org/tools.html"
}

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
        kitty zsh starship fzf
        
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
    
    run_sudo pacman -S --needed --noconfirm "${packages[@]}"
}

# Función para instalar yay (AUR helper)
install_yay() {
    if command_exists yay; then
        echo -e "${GREEN}yay ya está instalado${NC}"
        return 0
    fi
    
    log_info "Instalando yay (AUR helper)..."
    
    # Verificar que git está instalado
    if ! command_exists git; then
        echo -e "${YELLOW}[WARN]${NC} Git no está instalado. Instalando git primero..."
        run_sudo pacman -S --needed --noconfirm git || handle_error "No se pudo instalar git"
    fi
    
    # Verificar que base-devel está instalado
    if ! pacman -Qg base-devel &> /dev/null; then
        log_info "Instalando base-devel..."
        run_sudo pacman -S --needed --noconfirm base-devel || handle_error "No se pudo instalar base-devel"
    fi
    
    local tmpdir=$(mktemp -d)
    cd "$tmpdir"
    
    if git clone https://aur.archlinux.org/yay.git; then
        cd yay
        if makepkg -si --noconfirm; then
            echo -e "${GREEN}yay instalado correctamente${NC}"
            cd - > /dev/null
            rm -rf "$tmpdir"
            return 0
        else
            handle_error "Error al compilar yay"
        fi
    else
        handle_error "Error al clonar repositorio de yay"
    fi
    
    rm -rf "$tmpdir"
    return 1
}

# Función para instalar paru (AUR helper alternativo)
install_paru() {
    if command_exists paru; then
        echo -e "${GREEN}paru ya está instalado${NC}"
        return 0
    fi
    
    log_info "Instalando paru (AUR helper)..."
    
    # Verificar que git está instalado
    if ! command_exists git; then
        echo -e "${YELLOW}[WARN]${NC} Git no está instalado. Instalando git primero..."
        run_sudo pacman -S --needed --noconfirm git || handle_error "No se pudo instalar git"
    fi
    
    # Verificar que base-devel está instalado
    if ! pacman -Qg base-devel &> /dev/null; then
        log_info "Instalando base-devel..."
        run_sudo pacman -S --needed --noconfirm base-devel || handle_error "No se pudo instalar base-devel"
    fi
    
    local tmpdir=$(mktemp -d)
    cd "$tmpdir"
    
    if git clone https://aur.archlinux.org/paru.git; then
        cd paru
        if makepkg -si --noconfirm; then
            echo -e "${GREEN}paru instalado correctamente${NC}"
            cd - > /dev/null
            rm -rf "$tmpdir"
            return 0
        else
            handle_error "Error al compilar paru"
        fi
    else
        handle_error "Error al clonar repositorio de paru"
    fi
    
    rm -rf "$tmpdir"
    return 1
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
    run_sudo pacman -S --needed --noconfirm flatpak
    
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
    echo "5) Instalar yay (AUR helper)"
    echo "6) Instalar paru (AUR helper alternativo)"
    echo ""
    echo -e "${CYAN}Repositorios:${NC}"
    echo "7) Habilitar multilib (32-bit: Steam, Wine, etc.)"
    echo "8) Configurar repositorio BlackArch (pentesting)"
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
        5)
            install_yay
            ;;
        6)
            enable_multilib
            ;;
        8)
            install_paru
            ;;
        7)
            setup_blackarch_repo
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
