#!/usr/bin/env bash
# ============================================================================
# PACKAGE INSTALLER - Compatible con múltiples distribuciones
# ============================================================================
# Instala paquetes desde archivos de texto
# Soporta: Arch, Ubuntu/Debian, Fedora y más
# ============================================================================

set -e  # Salir en caso de error

# Obtener directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/../packages"

# Cargar utilidades de distribución
if [ -f "$SCRIPT_DIR/distro-utils.sh" ]; then
    source "$SCRIPT_DIR/distro-utils.sh"
else
    echo "Error: No se encontró distro-utils.sh"
    exit 1
fi

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

# Función para habilitar el repositorio multilib (32-bit) - Solo Arch
enable_multilib() {
    if [ "$PKG_MANAGER" != "pacman" ]; then
        log_warn "multilib solo está disponible en Arch Linux"
        return 0
    fi
    
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

# Función para configurar el repositorio de BlackArch - Solo Arch
setup_blackarch_repo() {
    if [ "$PKG_MANAGER" != "pacman" ]; then
        log_warn "BlackArch solo está disponible en Arch Linux"
        return 0
    fi
    
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
    
    local common_packages=(
        # Sistema base
        git wget curl
        
        # Terminal y shell
        kitty zsh fzf
        
        # Editores
        neovim
        
        # Herramientas de desarrollo
        nodejs npm python python-pip go rust
        docker docker-compose
        
        # Multimedia
        mpv ffmpeg
        
        # Utilidades
        htop btop ripgrep fd bat
        ranger nnn ncdu trash-cli
        
        # Navegadores
        firefox
        
        # Gestor de archivos comprimidos
        unzip p7zip
        
        # Network
        networkmanager
        
        # Screenshots (solo en distros con Wayland)
        # grim slurp
    )
    
    local arch_specific=(
        # Build tools
        base-devel
        
        # Hyprland y Wayland (principalmente en Arch)
        hyprland waybar rofi-wayland swaybg swaylock-effects
        swayidle wl-clipboard cliphist dunst
        
        # Prompts
        starship
        
        # Fuentes
        ttf-jetbrains-mono-nerd ttf-fira-code
        ttf-font-awesome otf-font-awesome
        
        # File tools
        exa
        
        # File manager
        thunar
        
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
    
    local ubuntu_specific=(
        # Build tools
        build-essential
        
        # Prompts
        starship
        
        # Network
        network-manager
        
        # Audio
        pipewire pipewire-audio-client-libraries
        pavucontrol
        
        # Bluetooth
        bluez blueman
        
        # File manager
        thunar
        
        # Compression
        unrar
    )
    
    # Instalar paquetes comunes
    log_info "Instalando paquetes comunes..."
    pkg_install "${common_packages[@]}"
    
    # Instalar paquetes específicos de la distribución
    case "$PKG_MANAGER" in
        pacman)
            log_info "Instalando paquetes específicos de Arch..."
            pkg_install "${arch_specific[@]}"
            ;;
        apt)
            log_info "Instalando paquetes específicos de Ubuntu/Debian..."
            pkg_install "${ubuntu_specific[@]}"
            ;;
        dnf)
            log_info "Instalando paquetes para Fedora..."
            # Fedora tiene su propia selección de paquetes
            pkg_install "${common_packages[@]}"
            ;;
    esac
    
    log_success "Paquetes oficiales instalados"
}

# Función para instalar yay (AUR helper) - Solo Arch
install_yay() {
    if [ "$PKG_MANAGER" != "pacman" ]; then
        log_warn "yay (AUR helper) solo está disponible en Arch Linux"
        return 0
    fi
    
    if command_exists yay; then
        echo -e "${GREEN}yay ya está instalado${NC}"
        return 0
    fi
    
    log_info "Instalando yay (AUR helper)..."
    install_yay  # Función de distro-utils.sh
    
    log_success "yay instalado correctamente"
}
    
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
