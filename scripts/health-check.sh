#!/usr/bin/env bash
# ============================================================================
# HEALTH CHECK - Verificación de salud del sistema
# ============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables
ISSUES=0
WARNINGS=0
OK=0
TOTAL_CHECKS=0

check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

ok() {
    echo -e "${GREEN}  ✓${NC} $1"
    OK=$((OK + 1))
}

warn() {
    echo -e "${YELLOW}  ⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

error() {
    echo -e "${RED}  ✗${NC} $1"
    ISSUES=$((ISSUES + 1))
}

section() {
    echo ""
    echo -e "${CYAN}━━━ $1 ━━━${NC}"
}

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     VERIFICACIÓN DE SALUD DEL SISTEMA              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"

# ============================================================================
# SISTEMA
# ============================================================================
section "Sistema"

check
if [ -f /etc/arch-release ]; then
    ok "Arch Linux detectado"
else
    error "No es Arch Linux"
fi

check
if ping -c 1 archlinux.org &> /dev/null; then
    ok "Conexión a internet disponible"
else
    error "Sin conexión a internet"
fi

check
if command -v pacman &> /dev/null; then
    ok "Pacman funcional"
else
    error "Pacman no encontrado"
fi

# ============================================================================
# REPOSITORIOS
# ============================================================================
section "Repositorios"

check
if grep -q "^\[multilib\]" /etc/pacman.conf; then
    ok "Multilib habilitado"
else
    warn "Multilib no habilitado (necesario para Steam, Wine)"
fi

check
if grep -q "\[blackarch\]" /etc/pacman.conf; then
    ok "BlackArch configurado"
else
    warn "BlackArch no configurado"
fi

# ============================================================================
# DISPLAY MANAGER
# ============================================================================
section "Display Manager"

check
if systemctl is-enabled gdm &> /dev/null; then
    ok "GDM habilitado"
    check
    if systemctl is-active gdm &> /dev/null; then
        ok "GDM en ejecución"
    else
        warn "GDM habilitado pero no activo"
    fi
elif systemctl is-enabled sddm &> /dev/null; then
    ok "SDDM habilitado"
    check
    if systemctl is-active sddm &> /dev/null; then
        ok "SDDM en ejecución"
    else
        warn "SDDM habilitado pero no activo"
    fi
else
    warn "Ningún display manager habilitado"
fi

# ============================================================================
# HYPRLAND
# ============================================================================
section "Hyprland"

check
if pacman -Q hyprland &> /dev/null; then
    ok "Hyprland instalado"
else
    error "Hyprland NO instalado"
fi

check
if pacman -Q waybar &> /dev/null; then
    ok "Waybar instalado"
else
    warn "Waybar NO instalado"
fi

check
if pacman -Q dunst &> /dev/null; then
    ok "Dunst instalado"
else
    warn "Dunst NO instalado"
fi

# ============================================================================
# SHELL Y TERMINAL
# ============================================================================
section "Shell y Terminal"

check
if pacman -Q zsh &> /dev/null; then
    ok "Zsh instalado"
else
    warn "Zsh NO instalado"
fi

check
if pacman -Q kitty &> /dev/null; then
    ok "Kitty instalado"
else
    warn "Kitty NO instalado"
fi

check
if [ -f "$HOME/.zshrc" ]; then
    ok "~/.zshrc existe"
else
    warn "~/.zshrc NO existe"
fi

# ============================================================================
# CONFIGURACIONES
# ============================================================================
section "Configuraciones"

check
if [ -L "$HOME/.config/hypr" ]; then
    ok "~/.config/hypr enlazado correctamente"
elif [ -d "$HOME/.config/hypr" ]; then
    warn "~/.config/hypr existe pero no es symlink"
else
    error "~/.config/hypr NO EXISTE"
fi

check
if [ -L "$HOME/.config/kitty" ]; then
    ok "~/.config/kitty enlazado correctamente"
elif [ -d "$HOME/.config/kitty" ]; then
    warn "~/.config/kitty existe pero no es symlink"
else
    warn "~/.config/kitty NO EXISTE"
fi

check
if [ -L "$HOME/.config/waybar" ]; then
    ok "~/.config/waybar enlazado correctamente"
elif [ -d "$HOME/.config/waybar" ]; then
    warn "~/.config/waybar existe pero no es symlink"
else
    warn "~/.config/waybar NO EXISTE"
fi

# ============================================================================
# SERVICIOS
# ============================================================================
section "Servicios"

check
if systemctl is-active NetworkManager &> /dev/null; then
    ok "NetworkManager activo"
else
    error "NetworkManager inactivo"
fi

check
if systemctl is-active docker &> /dev/null; then
    ok "Docker activo"
else
    warn "Docker inactivo"
fi

check
if systemctl is-active bluetooth &> /dev/null; then
    ok "Bluetooth activo"
else
    warn "Bluetooth inactivo"
fi

# ============================================================================
# AUR HELPERS
# ============================================================================
section "AUR Helpers"

check
if command -v yay &> /dev/null; then
    ok "yay instalado"
else
    warn "yay NO instalado"
fi

check
if command -v paru &> /dev/null; then
    ok "paru instalado"
else
    warn "paru NO instalado"
fi

# ============================================================================
# RESUMEN
# ============================================================================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Resumen:${NC}"
echo -e "  ${GREEN}✓ OK:${NC} $OK"
echo -e "  ${YELLOW}⚠ Advertencias:${NC} $WARNINGS"
echo -e "  ${RED}✗ Errores:${NC} $ISSUES"

PERCENTAGE=$(( (OK * 100) / TOTAL_CHECKS ))
echo ""
echo -e "${BLUE}Estado general:${NC} ${PERCENTAGE}% ${GREEN}✓${NC}"

if [ $ISSUES -gt 0 ]; then
    echo ""
    echo -e "${RED}Se encontraron $ISSUES errores críticos.${NC}"
    echo -e "${YELLOW}Ejecuta './install.sh' para corregirlos.${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Se encontraron $WARNINGS advertencias.${NC}"
    echo -e "${BLUE}El sistema funciona pero podría mejorarse.${NC}"
    exit 0
else
    echo ""
    echo -e "${GREEN}✓ ¡Todo está perfecto!${NC}"
    exit 0
fi
