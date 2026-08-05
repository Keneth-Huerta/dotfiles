#!/bin/bash
# #######################################################################################
# SYSTEM HEALTH CHECK for Hyprland
# Diagnóstico completo del sistema
# #######################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

ISSUES=0

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        SYSTEM HEALTH CHECK - Hyprland Setup          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ─── SYSTEM INFO ───
echo -e "${BLUE}📊 Información del Sistema${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"
echo -e "  OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo -e "  Kernel: $(uname -r)"
echo -e "  Uptime: $(uptime -p | sed 's/up //')"
echo -e "  Hostname: $(hostname)"
echo ""

# ─── MEMORY ───
echo -e "${BLUE}💾 Memoria${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"
free -h | grep "^Mem:" | awk '{printf "  Usado: %s / %s (%.1f%%)\n", $3, $2, ($3/$2)*100}'
echo ""

# ─── DISK ───
echo -e "${BLUE}💿 Espacio en Disco${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"
df -h / | tail -1 | awk '{printf "  / : %s usado de %s (%s)\n", $3, $2, $5}'
df -h /home | tail -1 | awk '{printf "  /home : %s usado de %s (%s)\n", $3, $2, $5}'

# Top 5 largest directories in home
echo -e "\n  ${CYAN}Directorios más grandes en ~/ :${NC}"
du -sh ~/* 2>/dev/null | sort -rh | head -5 | while read size dir; do
    echo -e "    ${YELLOW}$dir${NC}: $size"
done
echo ""

# ─── PROCESSES ───
echo -e "${BLUE}⚡ Procesos Principales${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"
echo -e "  CPU más alto:"
ps aux --sort=-%cpu | head -4 | tail -3 | awk '{printf "    • %s (%.1f%% CPU, %.1f%% MEM)\n", $11, $3, $4}'

echo -e "\n  Memoria más alta:"
ps aux --sort=-%mem | head -4 | tail -3 | awk '{printf "    • %s (%.1f%% MEM)\n", $11, $4}'
echo ""

# ─── HYPRLAND STATUS ───
echo -e "${BLUE}🖥️  Hyprland${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"
if pgrep -x Hyprland >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Hyprland ejecutándose"
    hyprctl version | head -1 | sed 's/^/  /'
    
    echo -e "\n  ${CYAN}Monitores:${NC}"
    hyprctl monitors | grep "^Monitor" | awk '{print "    • " $2 " @ " $5}'
    
    echo -e "\n  ${CYAN}Workspaces activos:${NC} $(hyprctl workspaces -j | jq 'length')"
    
    echo -e "\n  ${CYAN}Ventanas abiertas:${NC} $(hyprctl clients | grep -c "Window")"
else
    echo -e "  ${RED}✗${NC} Hyprland NO está ejecutándose"
    ((ISSUES++))
fi
echo ""

# ─── SERVICES ───
echo -e "${BLUE}🔧 Servicios Críticos${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"

services=(
    "pipewire:Audio"
    "NetworkManager:Red"
    "bluetooth:Bluetooth"
)

for svc_info in "${services[@]}"; do
    svc="${svc_info%%:*}"
    name="${svc_info##*:}"
    
    if systemctl --user is-active --quiet "$svc" 2>/dev/null || systemctl is-active --quiet "$svc" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $name ($svc)"
    else
        echo -e "  ${YELLOW}⚠${NC} $name ($svc) - Inactivo"
        ((ISSUES++))
    fi
done

# Check hypridle
if pgrep -x hypridle >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Gestor de inactividad (hypridle)"
else
    echo -e "  ${YELLOW}⚠${NC} Gestor de inactividad (hypridle) - No ejecutándose"
    ((ISSUES++))
fi

# Check for conflicting idle managers
if [[ -f ~/.config/hypr/scripts/idle-manager.sh ]]; then
    echo -e "  ${YELLOW}⚠${NC} idle-manager.sh existe (puede conflictar con hypridle)"
fi

echo ""

# ─── WAYLAND / GRAPHICS ───
echo -e "${BLUE}🎨 Gráficos y Wayland${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"
echo -e "  Session: ${WAYLAND_DISPLAY:-no establecida}"
echo -e "  XDG_CURRENT_DESKTOP: ${XDG_CURRENT_DESKTOP:-no establecida}"

if command -v glxinfo &>/dev/null; then
    glxinfo | grep "OpenGL renderer" | sed 's/^/  /' 2>/dev/null
fi

if [[ -n "$MESA_LOADER_DRIVER_OVERRIDE" ]]; then
    echo -e "  Driver override: $MESA_LOADER_DRIVER_OVERRIDE"
fi
echo ""

# ─── BATTERY (if laptop) ───
if [[ -d /sys/class/power_supply/BAT0 ]]; then
    echo -e "${BLUE}🔋 Batería${NC}"
    echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"
    cat /sys/class/power_supply/BAT0/capacity 2>/dev/null | xargs -I{} echo -e "  Capacidad: {}%"
    cat /sys/class/power_supply/BAT0/status 2>/dev/null | xargs -I{} echo -e "  Estado: {}"
    echo ""
fi

# ─── PACMAN / UPDATES ───
echo -e "${BLUE}📦 Paquetes${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"
echo -e "  Paquetes instalados: $(pacman -Q | wc -l)"

# Check for orphaned packages
orphans=$(pacman -Qtdq 2>/dev/null | wc -l)
if [[ $orphans -gt 0 ]]; then
    echo -e "  ${YELLOW}⚠${NC} Paquetes huérfanos: $orphans"
else
    echo -e "  ${GREEN}✓${NC} Sin paquetes huérfanos"
fi

# Check cache size
cache_size=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
echo -e "  Caché de paquetes: $cache_size"
echo ""

# ─── TEMPERATURES ───
if command -v sensors &>/dev/null; then
    echo -e "${BLUE}🌡️  Temperaturas${NC}"
    echo -e "${YELLOW}─────────────────────────────────────────────────────────${NC}"
    sensors 2>/dev/null | grep -E "Core|Package|Tctl" | sed 's/^/  /'
    echo ""
fi

# ─── SUMMARY ───
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                      RESUMEN                           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"

if [[ $ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✅ Sistema en óptimas condiciones${NC}"
else
    echo -e "${YELLOW}⚠️  $ISSUES problemas detectados${NC}"
fi

echo ""
