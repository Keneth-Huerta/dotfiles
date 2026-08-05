#!/usr/bin/env bash
# ============================================================================
# DOTFILES INSTALLER - Script Principal
# ============================================================================
# Sistema de instalación modular para múltiples distribuciones Linux
# (Arch, Ubuntu/Debian, Fedora, openSUSE, Void, Termux)
# Uso interactivo: ./install.sh
# Uso con flags:   ./install.sh [--full|--gui|--cli|--configs-only|--custom|--dry-run|--help]
# ============================================================================

# No usar set -e aquí para permitir mejor manejo de errores
# set -e  

# ============================================================================
# VARIABLES GLOBALES
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$HOME/.dotfiles-install.log"
CONFIG_DIR="$SCRIPT_DIR/config"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
PACKAGES_DIR="$SCRIPT_DIR/packages"
PROFILES_DIR="$SCRIPT_DIR/scripts/profiles"

# Cargar utilidades de distribución
if [ -f "$SCRIPTS_DIR/distro-utils.sh" ]; then
    source "$SCRIPTS_DIR/distro-utils.sh"
else
    echo "Error: No se encontró distro-utils.sh"
    exit 1
fi

# Directorio de dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Modo dry-run
DRY_RUN=false

# Perfil seleccionado
SELECTED_PROFILE=""

# Control de sudo
SUDO_CACHED=false
SUDO_TIMESTAMP=0

# ============================================================================
# FUNCIONES DE MANEJO DE PERMISOS
# ============================================================================

# Verificar si el usuario tiene permisos sudo
check_sudo_access() {
    # En Termux (pkg) no existe sudo: no hace falta elevación de privilegios
    if [ "$PKG_MANAGER" = "pkg" ]; then
        SUDO_CACHED=true
        return 0
    fi

    if ! sudo -n true 2>/dev/null; then
        # Usuario no tiene sudo cacheado, verificar si puede usarlo
        if ! groups | grep -q '\(wheel\|sudo\)'; then
            log_error "Tu usuario no está en el grupo 'wheel' o 'sudo'"
            log_error "Necesitas permisos de administrador para instalar paquetes"
            echo ""
            echo -e "${YELLOW}Solución:${NC}"
            echo "  1. Agrega tu usuario al grupo wheel:"
            echo "     su -c 'usermod -aG wheel $USER'"
            echo "  2. Asegúrate que wheel tiene permisos en /etc/sudoers:"
            echo "     su -c 'visudo'  # Descomenta: %wheel ALL=(ALL:ALL) ALL"
            echo "  3. Cierra sesión y vuelve a entrar"
            return 1
        fi
    fi
    return 0
}

# Cachear contraseña sudo al inicio
cache_sudo() {
    # En Termux (pkg) no existe sudo: no hace falta elevación de privilegios
    if [ "$PKG_MANAGER" = "pkg" ]; then
        SUDO_CACHED=true
        SUDO_TIMESTAMP=$(date +%s)
        return 0
    fi

    if [[ "$SUDO_CACHED" == true ]]; then
        # Verificar si el caché sigue válido (por defecto 5 minutos)
        local current_time=$(date +%s)
        local elapsed=$((current_time - SUDO_TIMESTAMP))
        
        # Si han pasado más de 4 minutos, renovar
        if [[ $elapsed -gt 240 ]]; then
            if sudo -v 2>/dev/null; then
                SUDO_TIMESTAMP=$(date +%s)
                return 0
            else
                SUDO_CACHED=false
                return 1
            fi
        fi
        return 0
    fi
    
    log_info "Este script necesita permisos de administrador para instalar paquetes"
    echo -e "${YELLOW}Por favor, ingresa tu contraseña sudo:${NC}"
    
    if sudo -v; then
        SUDO_CACHED=true
        SUDO_TIMESTAMP=$(date +%s)
        
        # Mantener sudo activo en segundo plano
        (
            while true; do
                sleep 240  # Cada 4 minutos
                sudo -n true 2>/dev/null || exit
            done
        ) &
        SUDO_KEEPALIVE_PID=$!
        
        log_success "Credenciales sudo verificadas y cacheadas"
        return 0
    else
        log_error "No se pudieron verificar las credenciales sudo"
        return 1
    fi
}

# Ejecutar comando con sudo de forma segura
run_sudo() {
    local cmd="$*"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} sudo $cmd"
        return 0
    fi
    
    # Verificar que tenemos sudo cacheado
    if [[ "$SUDO_CACHED" != true ]]; then
        if ! cache_sudo; then
            log_error "No se pudo obtener permisos sudo"
            return 1
        fi
    fi
    
    # Ejecutar comando
    if sudo $cmd; then
        return 0
    else
        local exit_code=$?
        log_error "Comando con sudo falló (código: $exit_code): $cmd"
        return $exit_code
    fi
}

# Limpiar proceso de keepalive al salir
cleanup_sudo() {
    if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi
}

# Trap para limpiar al salir
trap cleanup_sudo EXIT INT TERM

# Funciones de utilidad
log_info() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
    echo "[$timestamp] [INFO] $1" >> "$LOG_FILE"
}

log_success() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[OK]${NC} $1" | tee -a "$LOG_FILE"
    echo "[$timestamp] [SUCCESS] $1" >> "$LOG_FILE"
}

log_warn() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
    echo "[$timestamp] [WARN] $1" >> "$LOG_FILE"
}

log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    echo "[$timestamp] [ERROR] $1" >> "$LOG_FILE"
}

log_debug() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    if [ "${DEBUG:-false}" = true ]; then
        echo -e "${MAGENTA}[DEBUG]${NC} $1"
        echo "[$timestamp] [DEBUG] $1" >> "$LOG_FILE"
    else
        echo "[$timestamp] [DEBUG] $1" >> "$LOG_FILE"
    fi
}

command_exists() {
    command -v "$1" &> /dev/null
}

# Ejecutar comando (respeta DRY_RUN)
run_command() {
    local cmd="$*"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY-RUN]${NC} $cmd"
        return 0
    else
        log_info "Ejecutando: $cmd"
        eval "$cmd"
    fi
}

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
║                  Multi-Distribution Edition                  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Verificar sistema (ahora multi-distro)
check_system() {
    log_info "Sistema detectado: $DISTRO_NAME ($DISTRO_ID)"
    log_info "Gestor de paquetes: $PKG_MANAGER"
    
    if [ "$PKG_MANAGER" != "pacman" ]; then
        echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║  ADVERTENCIA: No estás en Arch Linux                           ║${NC}"
        echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Este script está optimizado para Arch Linux con Hyprland.${NC}"
        echo -e "${YELLOW}Algunas características pueden no estar disponibles:${NC}"
        echo -e "  - Instalación de Hyprland (compositor Wayland)"
        echo -e "  - Paquetes de AUR"
        echo -e "  - Configuraciones específicas de Arch"
        echo ""
        echo -e "${BLUE}Las herramientas CLI se instalarán normalmente.${NC}"
        echo -e "${BLUE}Las configuraciones se vincularán pero puede requerir ajustes.${NC}"
        echo ""
        echo -e "${YELLOW}¿Deseas continuar? (s/n)${NC}"
        read -r response
        if [[ ! "$response" =~ ^([sS][iI]|[sS])$ ]]; then
            echo -e "${RED}Instalación cancelada${NC}"
            echo ""
            echo -e "${BLUE}Para instalar solo herramientas CLI, usa:${NC}"
            echo -e "  ./scripts/install-cli-tools.sh"
            exit 0
        fi
        echo ""
    fi
    
    echo -e "${GREEN}✓ Sistema compatible detectado${NC}"
}

# ============================================================================
# SISTEMA DE PERFILES
# ============================================================================

list_profiles() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     PERFILES DISPONIBLES${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local i=1
    for profile in "$PROFILES_DIR"/*.profile; do
        if [ -f "$profile" ]; then
            source "$profile"
            echo -e "${GREEN}$i.${NC} ${YELLOW}$PROFILE_NAME${NC}"
            echo -e "   $PROFILE_DESC"
            echo ""
            ((i++))
        fi
    done
}

load_profile() {
    local profile_name="$1"
    local profile_file="$PROFILES_DIR/${profile_name}.profile"
    
    if [ ! -f "$profile_file" ]; then
        log_error "Perfil no encontrado: $profile_name"
        return 1
    fi
    
    log_info "Cargando perfil: $profile_name"
    source "$profile_file"
    SELECTED_PROFILE="$profile_name"
    
    log_success "Perfil cargado: $PROFILE_NAME"
    echo -e "${BLUE}Descripción:${NC} $PROFILE_DESC"
    return 0
}

select_profile_interactive() {
    list_profiles
    
    echo -e "${YELLOW}Selecciona un perfil (número) o presiona Enter para instalación personalizada:${NC}"
    read -r profile_choice
    
    if [ -z "$profile_choice" ]; then
        log_info "Instalación personalizada seleccionada"
        return 0
    fi
    
    # Convertir número a nombre de perfil
    local profiles=("minimal" "desktop" "gaming" "developer" "pentesting" "full")
    local index=$((profile_choice - 1))
    
    if [ $index -ge 0 ] && [ $index -lt ${#profiles[@]} ]; then
        load_profile "${profiles[$index]}"
    else
        log_error "Opción inválida"
        return 1
    fi
}

# ============================================================================
# SISTEMA DE HOOKS
# ============================================================================

run_hook() {
    local hook_name="$1"
    local hook_path="$DOTFILES_DIR/hooks/$hook_name.sh"
    
    if [ -f "$hook_path" ] && [ -x "$hook_path" ]; then
        log_info "Ejecutando hook: $hook_name"
        bash "$hook_path"
        
        if [ $? -eq 0 ]; then
            log_success "Hook $hook_name completado"
        else
            log_warn "Hook $hook_name falló (código: $?)"
        fi
    fi
}

# Verificar conexión a internet
check_internet() {
    log_info "Verificando conexión a internet..."

    # Termux puede no tener ping; usar curl como respaldo
    local test_hosts=("archlinux.org" "google.com" "1.1.1.1")

    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 2 "$host" &> /dev/null; then
            log_success "Conexión a internet disponible"
            return 0
        fi
        if command_exists curl && curl -fsS -m 5 -o /dev/null "https://$host/" 2>/dev/null; then
            log_success "Conexión a internet disponible (via curl)"
            return 0
        fi
    done

    log_error "No hay conexión a internet"
    log_warn "Configura la red antes de continuar"
    log_info "Puedes usar: nmtui, nmcli o wifi-menu para configurar la red"
    return 1
}

# ============================================================================
# VERIFICACIÓN DE ESPACIO EN DISCO
# ============================================================================

check_disk_space() {
    local required_gb=${1:-20}  # Default: 20GB requeridos
    
    log_info "Verificando espacio en disco..."
    
    local available_gb=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G//')
    
    echo -e "${BLUE}Espacio disponible:${NC} ${available_gb}GB"
    echo -e "${BLUE}Espacio requerido:${NC} ${required_gb}GB"
    
    if [ $available_gb -lt $required_gb ]; then
        log_error "Espacio insuficiente en disco"
        log_warn "Se requieren al menos ${required_gb}GB, pero solo hay ${available_gb}GB disponibles"
        
        read -p "¿Deseas continuar de todos modos? (s/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Ss]$ ]] && return 0 || return 1
    else
        log_success "Espacio en disco suficiente"
        return 0
    fi
}

# ============================================================================
# DETECCIÓN DE CONFLICTOS
# ============================================================================

check_conflicts() {
    log_info "Detectando posibles conflictos..."
    
    local conflicts_found=false
    
    # Conflicto: Display Managers
    local dm_count=0
    local installed_dms=()
    
    if systemctl is-enabled gdm &> /dev/null; then
        installed_dms+=("GDM")
        ((dm_count++))
    fi
    
    if systemctl is-enabled sddm &> /dev/null; then
        installed_dms+=("SDDM")
        ((dm_count++))
    fi
    
    if systemctl is-enabled lightdm &> /dev/null; then
        installed_dms+=("LightDM")
        ((dm_count++))
    fi
    
    if [ $dm_count -gt 1 ]; then
        conflicts_found=true
        log_warn "Múltiples display managers detectados: ${installed_dms[*]}"
        log_info "Esto puede causar conflictos al iniciar el sistema"
    fi
    
    # Conflicto: Shells en .bashrc/.zshrc
    if [ -f "$HOME/.bashrc" ] && grep -q "zsh" "$HOME/.bashrc"; then
        log_warn "Referencia a zsh encontrada en .bashrc"
    fi
    
    if [ "$conflicts_found" = false ]; then
        log_success "No se detectaron conflictos"
    fi
    
    return 0
}

# Actualizar sistema
update_system() {
    log_info "Actualizando el sistema..."

    # Multi-distro: pkg_update elige el gestor (pacman/apt/dnf/zypper/xbps/pkg)
    if pkg_update 2>&1 | tee -a "$LOG_FILE"; then
        log_success "Sistema actualizado"
        return 0
    else
        log_error "Error al actualizar el sistema"
        log_warn "Puedes continuar, pero se recomienda resolver este problema primero"
        read -p "¿Deseas continuar de todos modos? (s/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Ss]$ ]] && return 0 || return 1
    fi
}

# Menú principal
show_menu() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║       DOTFILES — MENÚ PRINCIPAL              ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}INSTALACIÓN${NC}"
    echo -e "  ${MAGENTA}1)${NC}  Instalación completa (Todo)"
    echo -e "  ${MAGENTA}2)${NC}  Instalar paquetes ${CYAN}(pacman + AUR + flatpak)${NC}"
    echo -e "  ${MAGENTA}3)${NC}  Entorno gráfico ${CYAN}(Hyprland + Waybar)${NC}"
    echo -e "  ${MAGENTA}4)${NC}  Herramientas CLI ${CYAN}(nvim, zsh, bat, eza...)${NC}"
    echo -e "  ${MAGENTA}5)${NC}  Configuración rápida ${CYAN}(vim, zsh, starship)${NC}"
    echo ""
    echo -e "  ${CYAN}CONFIGURACIÓN${NC}"
    echo -e "  ${MAGENTA}6)${NC}  Enlazar configuraciones ${CYAN}(crear symlinks)${NC}"
    echo -e "  ${MAGENTA}7)${NC}  Backup de configuraciones actuales"
    echo -e "  ${MAGENTA}8)${NC}  Actualizar configuraciones en el repo"
    echo -e "  ${MAGENTA}9)${NC}  Exportar lista de paquetes instalados"
    echo ""
    echo -e "  ${CYAN}GESTIÓN${NC}"
    echo -e "  ${MAGENTA}10)${NC} Inicializar dotfiles ${CYAN}(copiar configs al repo)${NC}"
    echo -e "  ${MAGENTA}11)${NC} Gestionar repositorios"
    echo -e "  ${MAGENTA}12)${NC} Gestionar claves SSH"
    echo -e "  ${MAGENTA}13)${NC} Restaurar backup"
    echo ""
    echo -e "  ${CYAN}DIAGNÓSTICO${NC}"
    echo -e "  ${MAGENTA}14)${NC} Actualizar sistema"
    echo -e "  ${MAGENTA}15)${NC} Detectar hardware"
    echo -e "  ${MAGENTA}16)${NC} Verificar salud del sistema"
    echo -e "  ${MAGENTA}17)${NC} Verificar instalación"
    echo -e "  ${MAGENTA}18)${NC} Estado de enlaces simbólicos"
    echo -e "  ${MAGENTA}19)${NC} Auto-detectar repositorios existentes"
    echo ""
    echo -e "  ${RED}0)${NC}  Salir"
    echo ""
}

# Instalación rápida para usar en escuela u otras computadoras
quick_install() {
    echo -e "${YELLOW}Instalación rápida de herramientas esenciales...${NC}"
    
    # Herramientas básicas (multi-distro: pkg_install elige el gestor)
    pkg_install \
        vim neovim \
        zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting \
        starship \
        fzf ripgrep fd bat exa \
        git \
        htop \
        tmux
    
    # Configurar zsh
    if [ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]; then
        cp "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
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
    
    # Cambiar shell a zsh
    if [ -n "$DEFAULT_SHELL" ]; then
        chsh -s $(which $DEFAULT_SHELL)
        echo -e "${GREEN}✓ Shell cambiada a $DEFAULT_SHELL${NC}"
    fi
    
    echo -e "${GREEN}✓ Instalación rápida completada${NC}"
}

# Instalación completa
full_install() {
    echo -e "${YELLOW}Iniciando instalación completa...${NC}"
    echo ""
    
    # Pre-install hook
    run_hook "pre-install"
    
    # Verificaciones iniciales
    check_disk_space 25
    check_conflicts
    
    # Detección de hardware (si está disponible)
    if [ -f "$DOTFILES_DIR/scripts/detect-hardware.sh" ]; then
        source "$DOTFILES_DIR/scripts/detect-hardware.sh"
        detect_hardware
        echo ""
        read -p "$(echo -e ${YELLOW}Presiona ENTER para continuar...${NC})"
    fi
    
    update_system
    
    # Ejecutar scripts de instalación
    log_info "Iniciando instalación de paquetes..."
    bash "$DOTFILES_DIR/scripts/install-packages.sh" --all || true
    
    log_info "Iniciando instalación de GUI..."
    bash "$DOTFILES_DIR/scripts/install-gui.sh" || true
    
    log_info "Iniciando instalación de herramientas CLI..."
    bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" --all || true
    
    # Pre-config hook
    run_hook "pre-config"
    
    log_info "Creando symlinks de configuración..."
    bash "$DOTFILES_DIR/scripts/link-configs.sh" --all || true
    
    # Post-config hook
    run_hook "post-config"
    
    # Verificación post-instalación
    echo ""
    log_info "Verificando instalación..."
    bash "$DOTFILES_DIR/scripts/post-install-verify.sh" "$DOTFILES_DIR/packages/pacman-explicit.txt"
    
    # Post-install hook
    run_hook "post-install"
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ¡INSTALACIÓN COMPLETADA!             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Logs guardados en:${NC} $LOG_FILE"
    echo -e "${YELLOW}Se recomienda reiniciar el sistema${NC}"
    echo ""
    echo -e "${CYAN}Para activar ZSH en esta terminal ahora mismo:${NC}"
    echo -e "  ${YELLOW}exec zsh${NC}"
    echo ""
    read -p "¿Deseas reiniciar ahora? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        log_info "Reiniciando sistema..."
        run_sudo reboot
    fi
}

# ============================================================================
# FUNCIÓN PARA MOSTRAR ESTADO DE ENLACES SIMBÓLICOS
# ============================================================================

show_symlink_status() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   ESTADO DE ENLACES SIMBÓLICOS (SYMLINKS)                     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local linked=0
    local not_linked=0
    local not_exists=0
    
    # Función helper para verificar symlink
    check_symlink() {
        local path="$1"
        local name="$2"
        
        if [ -L "$path" ]; then
            local target=$(readlink -f "$path")
            if [[ "$target" == "$DOTFILES_DIR"* ]]; then
                echo -e "${GREEN}✓${NC} $name ${BLUE}→${NC} ${target#$DOTFILES_DIR/}"
                ((linked++))
            else
                echo -e "${YELLOW}⚠${NC} $name ${BLUE}→${NC} $target ${YELLOW}(no apunta al repo)${NC}"
                ((not_linked++))
            fi
        elif [ -e "$path" ]; then
            echo -e "${RED}✗${NC} $name ${YELLOW}(existe pero NO es symlink)${NC}"
            ((not_linked++))
        else
            echo -e "${YELLOW}⊘${NC} $name ${YELLOW}(no existe)${NC}"
            ((not_exists++))
        fi
    }
    
    echo -e "${CYAN}[Terminal y Shell]${NC}"
    check_symlink "$HOME/.config/kitty" "Kitty"
    check_symlink "$HOME/.zshrc" ".zshrc"
    check_symlink "$HOME/.zshenv" ".zshenv"
    check_symlink "$HOME/.p10k.zsh" ".p10k.zsh"
    echo ""
    
    echo -e "${CYAN}[Editores]${NC}"
    check_symlink "$HOME/.config/nvim" "Neovim"
    echo ""
    
    echo -e "${CYAN}[CLI Tools]${NC}"
    check_symlink "$HOME/.config/starship.toml" "Starship"
    check_symlink "$HOME/.tmux.conf" "Tmux"
    check_symlink "$HOME/.gitconfig" "Git"
    echo ""
    
    if [ -d "$HOME/.config/hypr" ]; then
        echo -e "${CYAN}[Wayland/Hyprland]${NC}"
        check_symlink "$HOME/.config/hypr" "Hyprland"
        check_symlink "$HOME/.config/waybar" "Waybar"
        check_symlink "$HOME/.config/wofi" "Wofi"
        check_symlink "$HOME/.config/swaylock" "Swaylock"
        echo ""
    fi
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   RESUMEN                                                      ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}✓${NC} Enlazados correctamente: ${GREEN}$linked${NC}"
    echo -e "  ${RED}✗${NC} No enlazados:            ${RED}$not_linked${NC}"
    echo -e "  ${YELLOW}⊘${NC} No existen:              ${YELLOW}$not_exists${NC}"
    echo ""
    
    if [ $not_linked -gt 0 ]; then
        echo -e "${YELLOW}💡 Archivos sin enlazar detectados${NC}"
        echo ""
        echo -e "${YELLOW}¿Deseas arreglarlos ahora? (s/n)${NC}"
        read -r fix_response
        
        if [[ "$fix_response" =~ ^[sS]$ ]]; then
            echo ""
            echo -e "${CYAN}Arreglando enlaces...${NC}"
            
            # Función para crear symlink con backup
            fix_symlink() {
                local source="$1"
                local target="$2"
                local name="$3"
                
                if [ -e "$target" ] && [ ! -L "$target" ]; then
                    # Hacer backup
                    mv "$target" "${target}.backup-$(date +%Y%m%d-%H%M%S)"
                    echo -e "${BLUE}  Backup: ${target}.backup${NC}"
                fi
                
                # Eliminar si es symlink incorrecto
                if [ -L "$target" ]; then
                    rm "$target"
                fi
                
                # Crear directorio padre si no existe
                mkdir -p "$(dirname "$target")"
                
                # Crear symlink
                if [ -e "$source" ] || [ -d "$source" ]; then
                    ln -s "$source" "$target"
                    echo -e "${GREEN}✓ $name enlazado${NC}"
                else
                    echo -e "${YELLOW}⊘ $name: origen no existe en el repo${NC}"
                fi
            }
            
            # Arreglar .p10k.zsh
            if [ -e "$HOME/.p10k.zsh" ] && [ ! -L "$HOME/.p10k.zsh" ]; then
                fix_symlink "$DOTFILES_DIR/config/zsh/.p10k.zsh" "$HOME/.p10k.zsh" ".p10k.zsh"
            fi
            
            # Arreglar Wofi
            if [ -e "$HOME/.config/wofi" ] && [ ! -L "$HOME/.config/wofi" ]; then
                fix_symlink "$DOTFILES_DIR/config/wofi" "$HOME/.config/wofi" "Wofi"
            fi
            
            echo ""
            echo -e "${GREEN}✓ Enlaces arreglados${NC}"
            echo ""
        else
            echo -e "${YELLOW}💡 Para enlazar configuraciones manualmente, usa:${NC}"
            echo -e "   Opción 5) Enlazar configuraciones"
            echo ""
        fi
    fi
    
    if [ $linked -gt 0 ]; then
        echo -e "${GREEN}✓ Los archivos enlazados se actualizan automáticamente${NC}"
        echo -e "${BLUE}  Cualquier cambio que hagas se refleja en el repo${NC}"
        echo ""
    fi
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}ℹ  ¿Qué es un enlace simbólico (symlink)?${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Un symlink es como un \"atajo\" que apunta a otro archivo."
    echo -e "Cuando tu ${YELLOW}~/.zshrc${NC} es un symlink a ${BLUE}~/Documents/repos/dotfiles/config/zsh/.zshrc${NC}:"
    echo ""
    echo -e "  ${GREEN}✓${NC} Los cambios en ${YELLOW}~/.zshrc${NC} se guardan automáticamente en el repo"
    echo -e "  ${GREEN}✓${NC} Git puede trackear los cambios"
    echo -e "  ${GREEN}✓${NC} Puedes sincronizar entre computadoras fácilmente"
    echo ""
}

# ============================================================================
# VERIFICAR Y MOVER REPOSITORIO A LA UBICACIÓN CORRECTA
# ============================================================================

ensure_correct_location() {
    local TARGET_DIR="$HOME/Documents/repos/dotfiles"

    # Si ya está en la ubicación correcta, no hacer nada
    if [ "$DOTFILES_DIR" = "$TARGET_DIR" ]; then
        return 0
    fi

    echo -e "${YELLOW}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  REUBICANDO REPOSITORIO                              ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Ubicación actual:  ${NC}$DOTFILES_DIR"
    echo -e "${BLUE}Ubicación correcta:${NC}$TARGET_DIR"
    echo ""

    # Crear directorio padre si no existe
    mkdir -p "$HOME/Documents/repos"

    # Si el destino ya existe, hacer backup
    if [ -d "$TARGET_DIR" ]; then
        local backup="${TARGET_DIR}.backup-$(date +%Y%m%d-%H%M%S)"
        echo -e "${YELLOW}El destino ya existe, creando backup:${NC} $backup"
        mv "$TARGET_DIR" "$backup"
    fi

    # Mover el repositorio
    mv "$DOTFILES_DIR" "$TARGET_DIR"

    echo -e "${GREEN}✓ Repositorio movido a: $TARGET_DIR${NC}"
    echo -e "${CYAN}Reiniciando instalador desde la nueva ubicación...${NC}"
    echo ""
    sleep 1

    # Re-ejecutar el instalador desde la nueva ubicación
    exec bash "$TARGET_DIR/install.sh" "$@"
}

# Ayuda de línea de comandos
show_cli_help() {
    echo "Uso: $0 [OPCIÓN]"
    echo ""
    echo "Opciones:"
    echo "  --full           Instalación completa (elegir perfil)"
    echo "  --gui            Solo entorno gráfico (Hyprland + Waybar, solo Arch)"
    echo "  --cli            Solo herramientas CLI"
    echo "  --configs-only   Solo enlazar configuraciones (symlinks)"
    echo "  --custom         Instalación personalizada (elegir perfil)"
    echo "  --dry-run        Simular instalación (no instala nada)"
    echo "  --help           Mostrar esta ayuda"
    echo ""
    echo "Sin opción, se abre el menú interactivo."
}

# Main loop
main() {
    show_banner
    ensure_correct_location "$@"
    check_system
    check_internet

    # Flags de línea de comandos
    if [ $# -gt 0 ]; then
        case "$1" in
            --full)
                full_install
                ;;
            --gui)
                if [ "$PKG_MANAGER" != "pacman" ]; then
                    log_warn "El entorno gráfico solo está disponible en Arch Linux"
                else
                    bash "$DOTFILES_DIR/scripts/install-gui.sh"
                fi
                ;;
            --cli)
                bash "$DOTFILES_DIR/scripts/install-cli-tools.sh" --all
                ;;
            --configs-only)
                bash "$DOTFILES_DIR/scripts/link-configs.sh" --all
                ;;
            --custom)
                select_profile_interactive
                [ -n "$SELECTED_PROFILE" ] && full_install
                ;;
            --dry-run)
                DRY_RUN=true
                ;;
            --help)
                show_cli_help
                return 0
                ;;
            *)
                log_warn "Opción desconocida: $1"
                show_cli_help
                return 1
                ;;
        esac
        return 0
    fi

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
                quick_install
                ;;
            6)
                bash "$DOTFILES_DIR/scripts/link-configs.sh"
                ;;
            7)
                bash "$DOTFILES_DIR/scripts/backup-configs.sh"
                ;;
            8)
                bash "$DOTFILES_DIR/scripts/update-dotfiles.sh"
                ;;
            9)
                bash "$DOTFILES_DIR/scripts/export-packages.sh"
                ;;
            10)
                bash "$DOTFILES_DIR/scripts/init-dotfiles.sh"
                ;;
            11)
                bash "$DOTFILES_DIR/scripts/repo-manager.sh"
                ;;
            12)
                bash "$DOTFILES_DIR/scripts/ssh-manager.sh"
                ;;
            13)
                bash "$DOTFILES_DIR/scripts/restore-backup.sh"
                ;;
            14)
                update_system
                ;;
            15)
                source "$DOTFILES_DIR/scripts/detect-hardware.sh"
                detect_hardware
                read -p "Presiona ENTER para continuar..."
                ;;
            16)
                bash "$DOTFILES_DIR/scripts/health-check.sh"
                ;;
            17)
                bash "$DOTFILES_DIR/scripts/post-install-verify.sh"
                ;;
            18)
                show_symlink_status
                ;;
            19)
                bash "$DOTFILES_DIR/scripts/auto-detect-repos.sh"
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

main "$@"
