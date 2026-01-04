#!/usr/bin/env bash
# ============================================================================
# DISTRO UTILS - Utilidades multiplataforma para gestión de paquetes
# ============================================================================
# Detecta automáticamente la distribución y proporciona funciones unificadas
# para instalación de paquetes que funcionan en Arch, Ubuntu, Fedora, etc.
# ============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables globales
DISTRO_ID=""
DISTRO_VERSION=""
DISTRO_NAME=""
PKG_MANAGER=""
PKG_INSTALL_CMD=""
PKG_UPDATE_CMD=""
PKG_SEARCH_CMD=""
AUR_HELPER=""

# Log de paquetes fallidos
FAILED_PACKAGES=()
FAILED_LOG_FILE="$HOME/.dotfiles-failed-packages.log"
SCRIPT_START_TIME=$(date +%s)

# ============================================================================
# DETECCIÓN DE DISTRIBUCIÓN
# ============================================================================

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="$ID"
        DISTRO_VERSION="${VERSION_ID:-unknown}"
        DISTRO_NAME="$NAME"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO_ID="$DISTRIB_ID"
        DISTRO_VERSION="$DISTRIB_RELEASE"
        DISTRO_NAME="$DISTRIB_DESCRIPTION"
    else
        echo -e "${RED}Error: No se pudo detectar la distribución${NC}"
        return 1
    fi
    
    # Normalizar ID de distro
    DISTRO_ID=$(echo "$DISTRO_ID" | tr '[:upper:]' '[:lower:]')
    
    # Detectar gestor de paquetes
    detect_package_manager
    
    log_info "Distribución detectada: $DISTRO_NAME ($DISTRO_ID $DISTRO_VERSION)"
    log_info "Gestor de paquetes: $PKG_MANAGER"
    
    return 0
}

detect_package_manager() {
    case "$DISTRO_ID" in
        arch|manjaro|endeavouros|garuda)
            PKG_MANAGER="pacman"
            PKG_INSTALL_CMD="sudo pacman -S --needed --noconfirm"
            PKG_UPDATE_CMD="sudo pacman -Syu --noconfirm"
            PKG_SEARCH_CMD="pacman -Ss"
            detect_aur_helper
            ;;
        ubuntu|debian|pop|linuxmint|elementary)
            PKG_MANAGER="apt"
            PKG_INSTALL_CMD="sudo apt-get install -y"
            PKG_UPDATE_CMD="sudo apt-get update && sudo apt-get upgrade -y"
            PKG_SEARCH_CMD="apt-cache search"
            ;;
        fedora|rhel|centos|rocky|alma)
            PKG_MANAGER="dnf"
            PKG_INSTALL_CMD="sudo dnf install -y"
            PKG_UPDATE_CMD="sudo dnf upgrade -y"
            PKG_SEARCH_CMD="dnf search"
            ;;
        opensuse*|suse)
            PKG_MANAGER="zypper"
            PKG_INSTALL_CMD="sudo zypper install -y"
            PKG_UPDATE_CMD="sudo zypper update -y"
            PKG_SEARCH_CMD="zypper search"
            ;;
        void)
            PKG_MANAGER="xbps"
            PKG_INSTALL_CMD="sudo xbps-install -y"
            PKG_UPDATE_CMD="sudo xbps-install -Su"
            PKG_SEARCH_CMD="xbps-query -Rs"
            ;;
        *)
            echo -e "${YELLOW}Advertencia: Distribución '$DISTRO_ID' no reconocida${NC}"
            echo -e "${YELLOW}Intentando detectar gestor de paquetes...${NC}"
            
            if command -v pacman &> /dev/null; then
                PKG_MANAGER="pacman"
                PKG_INSTALL_CMD="sudo pacman -S --needed --noconfirm"
                PKG_UPDATE_CMD="sudo pacman -Syu --noconfirm"
                PKG_SEARCH_CMD="pacman -Ss"
            elif command -v apt-get &> /dev/null; then
                PKG_MANAGER="apt"
                PKG_INSTALL_CMD="sudo apt-get install -y"
                PKG_UPDATE_CMD="sudo apt-get update && sudo apt-get upgrade -y"
                PKG_SEARCH_CMD="apt-cache search"
            elif command -v dnf &> /dev/null; then
                PKG_MANAGER="dnf"
                PKG_INSTALL_CMD="sudo dnf install -y"
                PKG_UPDATE_CMD="sudo dnf upgrade -y"
                PKG_SEARCH_CMD="dnf search"
            else
                echo -e "${RED}Error: No se pudo detectar un gestor de paquetes conocido${NC}"
                return 1
            fi
            ;;
    esac
    
    return 0
}

detect_aur_helper() {
    AUR_HELPER=""
    
    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
    elif command -v pikaur &> /dev/null; then
        AUR_HELPER="pikaur"
    fi
    
    if [ -n "$AUR_HELPER" ]; then
        log_info "AUR helper detectado: $AUR_HELPER"
    fi
}

# ============================================================================
# FUNCIONES DE UTILIDAD
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# Registrar paquete fallido
log_failed_package() {
    local pkg="$1"
    local reason="${2:-No se pudo instalar}"
    
    FAILED_PACKAGES+=("$pkg")
    
    # Guardar en archivo de log
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $DISTRO_ID | $pkg | $reason" >> "$FAILED_LOG_FILE"
}

# Mostrar resumen de paquetes fallidos
show_failed_packages_summary() {
    if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
        return 0
    fi
    
    echo ""
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⚠  PAQUETES QUE NO SE PUDIERON INSTALAR${NC}"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    for pkg in "${FAILED_PACKAGES[@]}"; do
        echo -e "  ${RED}✗${NC} $pkg"
        
        # Intentar sugerir alternativas
        suggest_alternative "$pkg"
    done
    
    echo ""
    echo -e "${BLUE}ℹ  Log completo guardado en:${NC} $FAILED_LOG_FILE"
    echo ""
    echo -e "${YELLOW}Para instalar manualmente, intenta:${NC}"
    
    case "$PKG_MANAGER" in
        pacman)
            echo -e "  ${GREEN}sudo pacman -S ${FAILED_PACKAGES[*]}${NC}"
            if [ -n "$AUR_HELPER" ]; then
                echo -e "  ${GREEN}$AUR_HELPER -S ${FAILED_PACKAGES[*]}${NC}"
            fi
            ;;
        apt)
            echo -e "  ${GREEN}sudo apt-get install ${FAILED_PACKAGES[*]}${NC}"
            echo -e "  ${GREEN}apt-cache search <nombre-paquete>${NC}"
    local installed_count=0
    local failed_count=0
    
    # Mapear nombres de paquetes según la distribución
    for pkg in "${packages[@]}"; do
        local mapped_pkg=$(map_package_name "$pkg")
        if [ -n "$mapped_pkg" ] && [ "$mapped_pkg" != "SKIP" ]; then
            mapped_packages+=("$mapped_pkg")
        else
            log_warn "Paquete '$pkg' no disponible en esta distribución"
        fi
    done
    
    if [ ${#mapped_packages[@]} -eq 0 ]; then
        log_warn "No hay paquetes para instalar después del mapeo"
        return 0
    fi
    
    log_info "Instalando paquetes: ${mapped_packages[*]}"
    echo ""
    
    # Intentar instalar cada paquete individualmente para mejor control
    for pkg in "${mapped_packages[@]}"; do
        if pkg_is_installed "$pkg"; then
            log_success "$pkg ya está instalado ✓"
            ((installed_count++))
            continue
        fi
        
        # Intentar instalar con búsqueda inteligente
        if try_install_with_search "$pkg"; then
            log_success "$pkg instalado ✓"
            ((installed_count++))
        else
            log_error "No se pudo instalar: $pkg"
            ((failed_count++))
        fi
    done
    
    echo ""
    echo -e "${BLUE}Resumen:${NC}"
    echo -e "  ${GREEN}✓${NC} Instalados/Ya instalados: $installed_count"
    
    if [ $failed_count -gt 0 ]; then
        echo -e "  ${RED}✗${NC} Fallidos: $failed_count"
    fi
    
    return 0;
    esac
    
    if [ ${#suggestions[@]} -gt 0 ]; then
        echo -e "    ${BLUE}→${NC} Alternativas: ${suggestions[*]}"
    fi
}

# Intentar instalar con búsqueda inteligente
try_install_with_search() {
    local pkg="$1"
    local original_pkg="$pkg"
    
    # Intentar instalar normalmente primero
    log_info "Intentando instalar: $pkg"
    
    case "$PKG_MANAGER" in
        pacman)
            if sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null; then
                return 0
            fi
            ;;
        apt)
            if sudo apt-get install -y "$pkg" 2>/dev/null; then
                return 0
            fi
            ;;
        dnf)
            if sudo dnf install -y "$pkg" 2>/dev/null; then
                return 0
            fi
            ;;
        zypper)
            if sudo zypper install -y "$pkg" 2>/dev/null; then
                return 0
            fi
            ;;
        xbps)
            if sudo xbps-install -y "$pkg" 2>/dev/null; then
                return 0
            fi
            ;;
    esac
    
    # Si falló, intentar buscar alternativas
    log_warn "Paquete '$pkg' no encontrado, buscando alternativas..."
    
    local alternatives=()
    case "$pkg" in
        fastfetch)
            alternatives=("neofetch" "screenfetch")
            ;;
        exa)
            alternatives=("eza" "lsd")
            ;;
        eza)
            alternatives=("exa" "lsd")
            ;;
        bat)
            alternatives=("batcat")
            ;;
        fd)
            alternatives=("fd-find")
            ;;
        python-pip)
            alternatives=("python3-pip")
            ;;
        python)
            alternatives=("python3")
            ;;
    esac
    
    # Intentar instalar alternativas
    for alt in "${alternatives[@]}"; do
        log_info "Intentando alternativa: $alt"
        
        case "$PKG_MANAGER" in
            pacman)
                if sudo pacman -S --needed --noconfirm "$alt" 2>/dev/null; then
                    log_success "Instalado alternativa: $alt (en lugar de $original_pkg)"
                    return 0
                fi
                ;;
            apt)
                if sudo apt-get install -y "$alt" 2>/dev/null; then
                    log_success "Instalado alternativa: $alt (en lugar de $original_pkg)"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf install -y "$alt" 2>/dev/null; then
                    log_success "Instalado alternativa: $alt (en lugar de $original_pkg)"
                    return 0
                fi
                ;;
        esac
    done
    
    # Si todo falló, buscar en los repositorios
    log_warn "Buscando '$original_pkg' en repositorios..."
    local search_results=""
    
    case "$PKG_MANAGER" in
        pacman)
            search_results=$(pacman -Ss "^$pkg$" 2>/dev/null | head -5)
            ;;
        apt)
            search_results=$(apt-cache search "^$pkg" 2>/dev/null | head -5)
            ;;
        dnf)
            search_results=$(dnf search "$pkg" 2>/dev/null | grep "^[a-z]" | head -5)
            ;;
    esac
    
    if [ -n "$search_results" ]; then
        echo -e "${BLUE}Posibles coincidencias:${NC}"
        echo "$search_results"
    fi
    
    # Registrar como fallido
    log_failed_package "$original_pkg" "No se encontró en repositorios"
    return 1
}

# ============================================================================
# FUNCIONES DE GESTIÓN DE PAQUETES MULTIPLATAFORMA
# ============================================================================

# Actualizar sistema
pkg_update() {
    log_info "Actualizando sistema..."
    
    case "$PKG_MANAGER" in
        apt)
            sudo apt-get update
            sudo apt-get upgrade -y
            ;;
        dnf)
            sudo dnf upgrade -y
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            ;;
        zypper)
            sudo zypper refresh
            sudo zypper update -y
            ;;
        xbps)
            sudo xbps-install -Su
            ;;
        *)
            log_error "Gestor de paquetes no soportado: $PKG_MANAGER"
            return 1
            ;;
    esac
    
    log_success "Sistema actualizado"
}

# Instalar paquetes
# Uso: pkg_install package1 package2 package3...
pkg_install() {
    if [ $# -eq 0 ]; then
        log_error "pkg_install: No se especificaron paquetes"
        return 1
    fi
    
    local packages=("$@")
    local mapped_packages=()
    
    # Mapear nombres de paquetes según la distribución
    for pkg in "${packages[@]}"; do
        local mapped_pkg=$(map_package_name "$pkg")
        if [ -n "$mapped_pkg" ] && [ "$mapped_pkg" != "SKIP" ]; then
            mapped_packages+=("$mapped_pkg")
        fi
    done
    
    if [ ${#mapped_packages[@]} -eq 0 ]; then
        log_warn "No hay paquetes para instalar después del mapeo"
        return 0
    fi
    
    log_info "Instalando: ${mapped_packages[*]}"
    
    case "$PKG_MANAGER" in
        pacman)
            sudo pacman -S --needed --noconfirm "${mapped_packages[@]}"
            ;;
        apt)
            sudo apt-get install -y "${mapped_packages[@]}"
            ;;
        dnf)
            sudo dnf install -y "${mapped_packages[@]}"
            ;;
        zypper)
            sudo zypper install -y "${mapped_packages[@]}"
            ;;
        xbps)
            sudo xbps-install -y "${mapped_packages[@]}"
            ;;
        *)
            log_error "Gestor de paquetes no soportado: $PKG_MANAGER"
            return 1
            ;;
    esac
    
    return $?
}

# Instalar desde AUR (solo Arch)
aur_install() {
    if [ "$PKG_MANAGER" != "pacman" ]; then
        log_warn "AUR solo está disponible en distribuciones basadas en Arch"
        return 1
    fi
    
    if [ -z "$AUR_HELPER" ]; then
        log_error "No hay AUR helper instalado. Instala yay o paru primero."
        return 1
    fi
    
    local packages=("$@")
    log_info "Instalando desde AUR: ${packages[*]}"
    
    $AUR_HELPER -S --needed --noconfirm "${packages[@]}"
    return $?
}

# Verificar si un paquete está instalado
pkg_is_installed() {
    local package="$1"
    
    case "$PKG_MANAGER" in
        pacman)
            pacman -Q "$package" &> /dev/null
            ;;
        apt)
            dpkg -l "$package" 2>/dev/null | grep -q "^ii"
            ;;
        dnf)
            rpm -q "$package" &> /dev/null
            ;;
        zypper)
            rpm -q "$package" &> /dev/null
            ;;
        xbps)
            xbps-query "$package" &> /dev/null
            ;;
        *)
            return 1
            ;;
    esac
    
    return $?
}

# Buscar paquetes
pkg_search() {
    local query="$1"
    
    case "$PKG_MANAGER" in
        pacman)
            pacman -Ss "$query"
            ;;
        apt)
            apt-cache search "$query"
            ;;
        dnf)
            dnf search "$query"
            ;;
        zypper)
            zypper search "$query"
            ;;
        xbps)
            xbps-query -Rs "$query"
            ;;
        *)
            log_error "Gestor de paquetes no soportado: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# ============================================================================
# MAPEO DE NOMBRES DE PAQUETES
# ============================================================================

map_package_name() {
    local pkg="$1"
    
    # Si el paquete tiene un mapeo específico, usarlo
    case "$pkg" in
        # Terminales
        kitty|alacritty)
            echo "$pkg"  # Mismo nombre en todas las distros
            ;;
        
        # Shells
        fish|zsh)
            echo "$pkg"
            ;;
        zsh-completions)
            [ "$PKG_MANAGER" = "apt" ] && echo "zsh-common" || echo "$pkg"
            ;;
        zsh-autosuggestions)
            echo "$pkg"
            ;;
        zsh-syntax-highlighting)
            echo "$pkg"
            ;;
        
        # Editores
        neovim)
            echo "$pkg"
            ;;
        vim)
            echo "$pkg"
            ;;
        
        # Utilidades
        htop|btop)
            echo "$pkg"
            ;;
        fastfetch)
            # fastfetch no está en repos oficiales de Ubuntu/Debian
            if [ "$PKG_MANAGER" = "apt" ]; then
                echo "neofetch"  # Alternativa
            else
                echo "$pkg"
            fi
            ;;
        neofetch)
            echo "$pkg"
            ;;
        fzf|ripgrep|fd|bat)
            echo "$pkg"
            ;;
        exa)
            # exa fue renombrado a eza
            if [ "$PKG_MANAGER" = "apt" ]; then
                command_exists exa && echo "exa" || echo "SKIP"
            else
                echo "eza"
            fi
            ;;
        eza)
            [ "$PKG_MANAGER" = "apt" ] && echo "SKIP" || echo "$pkg"
            ;;
        
        # File managers
        ranger|nnn)
            echo "$pkg"
            ;;
        
        # Network tools
        curl|wget|aria2)
            echo "$pkg"
            ;;
        
        # Git
        git)
            echo "$pkg"
            ;;
        git-delta)
            [ "$PKG_MANAGER" = "apt" ] && echo "git-delta" || echo "$pkg"
            ;;
        lazygit)
            echo "$pkg"
            ;;
        
        # Tmux
        tmux)
            echo "$pkg"
            ;;
        
        # Otros
        jq|tree|tldr)
            echo "$pkg"
            ;;
        ncdu)
            echo "$pkg"
            ;;
        trash-cli)
            echo "$pkg"
            ;;
        
        # Prompts
        starship)
            echo "$pkg"
            ;;
        
        # Build tools
        base-devel)
            case "$PKG_MANAGER" in
                apt)
                    echo "build-essential"
                    ;;
                dnf)
                    echo "Development Tools"
                    ;;
                *)
                    echo "$pkg"
                    ;;
            esac
            ;;
        
        # Desarrollo
        nodejs|npm|python|python-pip|go|rust|cmake|make)
            case "$pkg" in
                python)
                    [ "$PKG_MANAGER" = "apt" ] && echo "python3" || echo "$pkg"
                    ;;
                python-pip)
                    [ "$PKG_MANAGER" = "apt" ] && echo "python3-pip" || echo "$pkg"
                    ;;
                *)
                    echo "$pkg"
                    ;;
            esac
            ;;
        
        # Docker
        docker)
            [ "$PKG_MANAGER" = "apt" ] && echo "docker.io" || echo "$pkg"
            ;;
        docker-compose)
            [ "$PKG_MANAGER" = "apt" ] && echo "docker-compose" || echo "$pkg"
            ;;
        
        # Bases de datos
        postgresql|redis)
            echo "$pkg"
            ;;
        
        # Por defecto, usar el mismo nombre
        *)
            echo "$pkg"
            ;;
    esac
}

# ============================================================================
# INSTALACIÓN DE HERRAMIENTAS ADICIONALES
# ============================================================================

# Instalar Oh My Zsh
install_oh_my_zsh() {
    if [ -d ~/.oh-my-zsh ]; then
        log_info "Oh My Zsh ya está instalado"
        return 0
    fi
    
    log_info "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh instalado"
}

# Instalar Powerlevel10k
install_powerlevel10k() {
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [ -d "$p10k_dir" ]; then
        log_info "Powerlevel10k ya está instalado"
        return 0
    fi
    
    log_info "Instalando Powerlevel10k..."
    
    # Crear directorio custom si no existe
    mkdir -p "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
    
    # Clonar Powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    
    log_success "Powerlevel10k instalado"
    log_info "Para configurar, ejecuta: p10k configure"
}

# Instalar Oh My Fish
install_oh_my_fish() {
    if [ -d ~/.local/share/omf ]; then
        log_info "Oh My Fish ya está instalado"
        return 0
    fi
    
    log_info "Instalando Oh My Fish..."
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
    log_success "Oh My Fish instalado"
}

# Instalar Starship
install_starship() {
    if command_exists starship; then
        log_info "Starship ya está instalado"
        return 0
    fi
    
    log_info "Instalando Starship..."
    
    # Intentar instalar desde repositorio primero
    if ! pkg_install starship 2>/dev/null; then
        # Si falla, usar el instalador oficial
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    log_success "Starship instalado"
}

# Instalar AUR helper (yay)
install_yay() {
    if [ "$PKG_MANAGER" != "pacman" ]; then
        log_warn "yay solo está disponible en distribuciones basadas en Arch"
        return 1
    fi
    
    if command_exists yay; then
        log_info "yay ya está instalado"
        return 0
    fi
    
    log_info "Instalando yay..."
    
    # Instalar dependencias
    pkg_install base-devel git
    
    # Clonar y compilar yay
    local temp_dir="/tmp/yay-install-$$"
    git clone https://aur.archlinux.org/yay.git "$temp_dir"
    cd "$temp_dir" || return 1
    makepkg -si --noconfirm
    cd - > /dev/null || return 1
    rm -rf "$temp_dir"
    
    detect_aur_helper
    log_success "yay instalado"
}

# ============================================================================
# INICIALIZACIÓN
# ============================================================================

# Detectar distribución automáticamente al cargar el script
if [ -z "$DISTRO_ID" ]; then
    detect_distro
fi

# Trap para mostrar resumen al salir
cleanup_and_show_summary() {
    show_failed_packages_summary
}

# Registrar trap solo si no es source
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    trap cleanup_and_show_summary EXIT
fi

# Exportar funciones
export -f log_info
export -f log_success
export -f log_warn
export -f log_error
export -f command_exists
export -f log_failed_package
export -f show_failed_packages_summary
export -f suggest_alternative
export -f try_install_with_search
export -f pkg_update
export -f pkg_install
export -f aur_install
export -f pkg_is_installed
export -f pkg_search
export -f map_package_name
export -f install_oh_my_zsh
export -f install_powerlevel10k
export -f install_oh_my_fish
export -f install_starship
export -f install_yay
export -f cleanup_and_show_summary
