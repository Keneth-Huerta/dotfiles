#!/usr/bin/env bash

set -e  # Salir en caso de error (excepto en comprobaciones específicas)

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Función para verificar si un paquete está instalado
package_installed() {
    pacman -Q "$1" &> /dev/null
}

# Función para verificar si un servicio existe
service_exists() {
    systemctl list-unit-files | grep -q "^$1"
}

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
    
    # Verificar e instalar herramientas de temas
    local theme_engines=("gtk-engine-murrine" "gtk-engines")
    for engine in "${theme_engines[@]}"; do
        if ! package_installed "$engine"; then
            log_info "Instalando $engine..."
            if ! sudo pacman -S --needed --noconfirm "$engine" 2>/dev/null; then
                echo -e "${YELLOW}[WARN]${NC} No se pudo instalar $engine, continuando..."
            fi
        else
            log_info "$engine ya está instalado"
        fi
    done
    
    # Verificar si yay está disponible antes de instalar temas de AUR
    if ! command_exists yay; then
        echo -e "${YELLOW}[WARN]${NC} yay no está instalado. Omitiendo temas de AUR."
        echo -e "${BLUE}[INFO]${NC} Puedes instalar yay más tarde con: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    else
        # Instalar temas
        local aur_themes=("catppuccin-gtk-theme-mocha" "papirus-icon-theme" "bibata-cursor-theme")
        for theme in "${aur_themes[@]}"; do
            if ! package_installed "$theme"; then
                log_info "Instalando $theme..."
                yay -S --needed --noconfirm "$theme" || echo -e "${YELLOW}[WARN]${NC} No se pudo instalar $theme"
            fi
        done
    fi
    
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
    echo -e "${YELLOW}Verificando Display Manager...${NC}"
    
    # Verificar si ya hay un display manager instalado o habilitado
    local active_dm=$(systemctl list-units --type service --state=running | grep -E "(gdm|sddm|lightdm|lxdm)" | awk '{print $1}' | head -n1)
    local enabled_dm=$(systemctl list-unit-files | grep -E "(gdm|sddm|lightdm|lxdm)" | grep enabled | awk '{print $1}' | head -n1)
    
    if [ -n "$active_dm" ] || [ -n "$enabled_dm" ]; then
        local dm_name="${active_dm:-$enabled_dm}"
        echo -e "${GREEN}✓ Ya tienes un Display Manager instalado: ${dm_name}${NC}"
        echo ""
        echo -e "${BLUE}[INFO]${NC} ${dm_name} funciona perfectamente con Hyprland."
        echo -e "${BLUE}[INFO]${NC} Para usar Hyprland, selecciónalo en la pantalla de login (ícono de configuración)."
        echo ""
        read -p "¿Realmente deseas reemplazarlo con SDDM? (s/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            log_info "Manteniendo tu Display Manager actual"
            log_info "No se necesita SDDM, tu sistema está configurado correctamente"
            return 0
        fi
        
        log_info "Deshabilitando $dm_name..."
        sudo systemctl disable "$dm_name" 2>/dev/null || true
    fi
    
    if ! package_installed sddm; then
        sudo pacman -S --needed --noconfirm sddm || handle_error "No se pudo instalar SDDM"
    fi
    
    # Instalar tema si yay está disponible
    if command_exists yay; then
        log_info "Instalando tema para SDDM..."
        yay -S --needed --noconfirm sddm-sugar-candy-git 2>/dev/null || echo -e "${YELLOW}[WARN]${NC} No se pudo instalar tema de SDDM"
        
        # Configurar SDDM con tema
        sudo mkdir -p /etc/sddm.conf.d
        sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << EOF
[Theme]
Current=sugar-candy
EOF
    fi
    
    # Habilitar SDDM
    log_info "Habilitando SDDM..."
    sudo systemctl enable sddm 2>/dev/null || log_warn "No se pudo habilitar SDDM automáticamente"
    
    echo -e "${GREEN}SDDM instalado y configurado${NC}"
}

# Función para instalar GDM
install_gdm() {
    echo -e "${YELLOW}Verificando Display Manager...${NC}"
    
    # Verificar si ya hay un display manager instalado o habilitado
    local active_dm=$(systemctl list-units --type service --state=running | grep -E "(gdm|sddm|lightdm|lxdm)" | awk '{print $1}' | head -n1)
    local enabled_dm=$(systemctl list-unit-files | grep -E "(gdm|sddm|lightdm|lxdm)" | grep enabled | awk '{print $1}' | head -n1)
    
    if [ -n "$active_dm" ] || [ -n "$enabled_dm" ]; then
        local dm_name="${active_dm:-$enabled_dm}"
        
        # Si ya es GDM, no hacer nada
        if [[ "$dm_name" == *"gdm"* ]]; then
            echo -e "${GREEN}✓ GDM ya está instalado y configurado${NC}"
            return 0
        fi
        
        echo -e "${GREEN}✓ Ya tienes un Display Manager instalado: ${dm_name}${NC}"
        echo ""
        read -p "¿Deseas reemplazarlo con GDM? (s/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            log_info "Manteniendo tu Display Manager actual"
            return 0
        fi
        
        log_info "Deshabilitando $dm_name..."
        sudo systemctl disable "$dm_name" 2>/dev/null || true
    fi
    
    if ! package_installed gdm; then
        log_info "Instalando GDM..."
        sudo pacman -S --needed --noconfirm gdm || handle_error "No se pudo instalar GDM"
    fi
    
    # Habilitar GDM
    log_info "Habilitando GDM..."
    sudo systemctl enable gdm 2>/dev/null || log_warn "No se pudo habilitar GDM automáticamente"
    
    echo -e "${GREEN}GDM instalado y configurado${NC}"
}

# Función para configurar servicios del sistema
configure_system_services() {
    echo -e "${YELLOW}Configurando servicios del sistema...${NC}"
    
    # NetworkManager
    if service_exists "NetworkManager.service"; then
        log_info "Habilitando NetworkManager..."
        sudo systemctl enable NetworkManager 2>/dev/null || true
        sudo systemctl start NetworkManager 2>/dev/null || echo -e "${YELLOW}[WARN]${NC} NetworkManager ya está ejecutándose"
    else
        echo -e "${YELLOW}[WARN]${NC} NetworkManager no está instalado"
    fi
    
    # Bluetooth (verificar si existe antes de habilitar)
    if service_exists "bluetooth.service"; then
        log_info "Habilitando Bluetooth..."
        sudo systemctl enable bluetooth 2>/dev/null || true
        sudo systemctl start bluetooth 2>/dev/null || echo -e "${YELLOW}[WARN]${NC} Bluetooth ya está ejecutándose o no está disponible"
    else
        echo -e "${YELLOW}[WARN]${NC} Servicio bluetooth no encontrado. Si tienes bluetooth, instala 'bluez'"
    fi
    
    # Docker
    if command_exists docker; then
        if service_exists "docker.service"; then
            log_info "Habilitando Docker..."
            sudo systemctl enable docker 2>/dev/null || true
            
            # Agregar usuario al grupo docker si no está
            if ! groups $USER | grep -q docker; then
                log_info "Agregando usuario al grupo docker..."
                sudo usermod -aG docker $USER
                echo -e "${BLUE}[INFO]${NC} Necesitarás cerrar sesión y volver a entrar para usar docker sin sudo"
            fi
        else
            echo -e "${YELLOW}[WARN]${NC} Docker instalado pero servicio no encontrado"
        fi
    else
        log_info "Docker no está instalado, omitiendo..."
    fi
    
    echo -e "${GREEN}Servicios configurados${NC}"
}

# Menú principal
main() {
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   INSTALACIÓN DE ENTORNO GRÁFICO      ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Detectar si hay algún display manager instalado
    local has_dm=false
    local current_dm=""
    
    if systemctl list-unit-files | grep -qE "(gdm|sddm|lightdm|lxdm).service"; then
        has_dm=true
        current_dm=$(systemctl list-unit-files | grep -E "(gdm|sddm|lightdm|lxdm).service" | awk '{print $1}' | head -n1)
        echo -e "${GREEN}✓ Display Manager detectado: ${current_dm}${NC}"
    else
        echo -e "${YELLOW}⚠ No se detectó ningún Display Manager instalado${NC}"
    fi
    echo ""
    
    if [ "$has_dm" = true ]; then
        echo -e "${BLUE}Tu sistema YA tiene un Display Manager (${current_dm}).${NC}"
        echo -e "${BLUE}Funcionará perfectamente con Hyprland.${NC}"
        echo ""
        echo -e "${GREEN}→ RECOMENDADO:${NC} Opción 1 (no necesitas instalar otro Display Manager)"
    else
        echo -e "${YELLOW}Tu sistema NO tiene Display Manager instalado.${NC}"
        echo -e "${YELLOW}Necesitas uno para tener login gráfico.${NC}"
        echo ""
        echo -e "${GREEN}→ RECOMENDADO:${NC} Opción 3 (Hyprland + GDM) para sistema nuevo"
    fi
    
    echo ""
    echo -e "${CYAN}═══ Opciones de Instalación ═══${NC}"
    echo "1) Solo Hyprland + Temas (si YA tienes Display Manager)"
    echo "2) Hyprland + SDDM + Temas (alternativa ligera)"
    echo "3) Hyprland + GDM + Temas (recomendado para sistema nuevo)"
    echo "4) Solo Hyprland (sin temas ni Display Manager)"
    echo "5) Solo SDDM (Display Manager)"
    echo "6) Solo GDM (Display Manager)"
    echo "7) Solo temas GTK/Qt"
    echo "8) Configurar servicios del sistema"
    echo "0) Volver"
    echo ""
    read -p "Selecciona una opción: " option
    
    case $option in
        1)
            install_hyprland_full
            configure_themes
            configure_system_services
            echo ""
            echo -e "${GREEN}✓ Instalación completada${NC}"
            echo -e "${BLUE}Para iniciar Hyprland desde tu Display Manager actual:${NC}"
            echo "  1. Cierra sesión (logout)"
            echo "  2. En la pantalla de login, click en el ícono de configuración"
            echo "  3. Selecciona 'Hyprland'"
            echo "  4. Ingresa tu contraseña"
            ;;
        2)
            install_hyprland_full
            install_sddm
            configure_themes
            configure_system_services
            echo ""
            echo -e "${GREEN}✓ Instalación completada${NC}"
            echo -e "${YELLOW}IMPORTANTE: Necesitas reiniciar para usar SDDM${NC}"
            echo "  Después del reinicio verás la pantalla de login gráfica"
            ;;
        3)
            install_hyprland_full
            install_gdm
            configure_themes
            configure_system_services
            echo ""
            echo -e "${GREEN}✓ Instalación completada${NC}"
            echo -e "${YELLOW}IMPORTANTE: Necesitas reiniciar para usar GDM${NC}"
            echo "  Después del reinicio verás la pantalla de login de GNOME"
            ;;
        4)
            install_hyprland_full
            configure_system_services
            ;;
        5)
            install_sddm
            ;;
        6)
            install_gdm
            ;;
        7)
            configure_themes
            ;;
        8)
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
