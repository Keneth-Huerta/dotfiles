#!/bin/bash
# #######################################################################################
# HYPRLAND CONFIG VALIDATOR
# Valida la configuración ANTES de hacer reload
# Uso: validate-hypr-config.sh [--fix]
# #######################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_DIR="$HOME/.config/hypr"
ERRORS=0
WARNINGS=0

header() {
    echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Hyprland Config Validator${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
    echo ""
}

check_file_exists() {
    local file="$1"
    local desc="$2"
    if [[ -f "$file" ]]; then
        echo -e "  ${GREEN}✓${NC} $desc"
        return 0
    else
        echo -e "  ${RED}✗${NC} $desc (NO ENCONTRADO: $file)"
        ((ERRORS++))
        return 1
    fi
}

check_syntax() {
    local file="$1"
    local desc="$2"
    
    # Check for common syntax issues
    local issues=0
    
    # Check for multiple misc blocks
    local misc_count=$(grep -c "^misc {" "$file" 2>/dev/null || echo "0")
    misc_count=$(echo "$misc_count" | tr -d '\n')
    if [[ "$misc_count" -gt 1 ]]; then
        echo -e "  ${YELLOW}⚠${NC} $desc: Tiene $misc_count bloques 'misc {}' (puede causar conflictos)"
        ((WARNINGS++))
        ((issues++))
    fi
    
    # Check for old broken keywords (ignoring comments)
    # Nota: dim_inactive es VÁLIDO en Hyprland (decoration:dim_inactive)
    if grep -v "^[[:space:]]*#" "$file" 2>/dev/null | grep -q "drop_shadow"; then
        echo -e "  ${RED}✗${NC} $desc: Contiene keyword roto (drop_shadow - no existe en Hyprland)"
        ((ERRORS++))
        ((issues++))
    fi
    
    # Check for duplicate source statements
    local dup_sources=$(grep "^source = " "$file" 2>/dev/null | sort | uniq -d | wc -l)
    if [[ $dup_sources -gt 0 ]]; then
        echo -e "  ${YELLOW}⚠${NC} $desc: Tiene source statements duplicados"
        ((WARNINGS++))
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        echo -e "  ${GREEN}✓${NC} $desc: Sin problemas detectados"
    fi
}

check_dependencies() {
    echo -e "${BLUE}📦 Verificando dependencias...${NC}"
    
    local deps=("hyprctl" "jq" "grim" "slurp" "wl-copy" "notify-send" "brightnessctl" "wpctl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $dep"
        else
            echo -e "  ${RED}✗${NC} $dep (NO INSTALADO)"
            missing+=("$dep")
            ((WARNINGS++))
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}💡 Instalar faltantes:${NC}"
        echo -e "  sudo pacman -S ${missing[*]}"
    fi
}

check_scripts() {
    echo -e "${BLUE}🔧 Verificando scripts...${NC}"
    
    local scripts=(
        "scripts/reload-hyprland.sh"
        "scripts/monitor-manager.sh"
        "scripts/monitor-watcher.sh"
        "scripts/mpvpaper-manager.sh"
        "scripts/system-optimizer.sh"
        "scripts/gaming-mode.sh"
        "toggle-mode.sh"
    )
    
    for script in "${scripts[@]}"; do
        local path="$CONFIG_DIR/$script"
        if [[ -x "$path" ]]; then
            echo -e "  ${GREEN}✓${NC} $script"
        elif [[ -f "$path" ]]; then
            echo -e "  ${YELLOW}⚠${NC} $script (no ejecutable)"
            ((WARNINGS++))
        else
            echo -e "  ${RED}✗${NC} $script (no encontrado)"
            ((ERRORS++))
        fi
    done
}

check_monitor_config() {
    echo -e "${BLUE}🖥️  Verificando configuración de monitores...${NC}"
    
    if [[ -f "$CONFIG_DIR/monitors.conf" ]]; then
        echo -e "  ${GREEN}✓${NC} monitors.conf existe"
        
        # Check if it has actual monitor configurations
        if grep -q "monitor=" "$CONFIG_DIR/monitors.conf"; then
            echo -e "  ${GREEN}✓${NC} Tiene configuraciones de monitor"
        else
            echo -e "  ${YELLOW}⚠${NC} No tiene configuraciones de monitor (podría estar vacío)"
            ((WARNINGS++))
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} monitors.conf no existe (se generará automáticamente)"
    fi
}

# Main
header

echo -e "${BLUE}📁 Verificando archivos de configuración...${NC}"
check_file_exists "$CONFIG_DIR/hyprland.conf" "hyprland.conf"
check_file_exists "$CONFIG_DIR/appearance.conf" "appearance.conf"
check_file_exists "$CONFIG_DIR/keybinds.conf" "keybinds.conf"
check_file_exists "$CONFIG_DIR/windowrules.conf" "windowrules.conf"
check_file_exists "$CONFIG_DIR/autostart.conf" "autostart.conf"
check_file_exists "$CONFIG_DIR/variables.conf" "variables.conf"
check_file_exists "$CONFIG_DIR/advanced.conf" "advanced.conf"
check_file_exists "$CONFIG_DIR/hypridle.conf" "hypridle.conf"
echo ""

echo -e "${BLUE}🔍 Verificando sintaxis de configs...${NC}"
check_syntax "$CONFIG_DIR/appearance.conf" "appearance.conf"
check_syntax "$CONFIG_DIR/advanced.conf" "advanced.conf"
check_syntax "$CONFIG_DIR/hyprland.conf" "hyprland.conf"
echo ""

check_dependencies
echo ""

check_scripts
echo ""

check_monitor_config
echo ""

# Summary
echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  RESUMEN${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✅ Todo OK - La configuración es válida${NC}"
    echo ""
    echo -e "${GREEN}Puedes recargar Hyprland con confianza:${NC}"
    echo -e "  hyprctl reload"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  $WARNINGS advertencias encontradas${NC}"
    echo -e "${YELLOW}Es seguro recargar, pero revisa las advertencias${NC}"
    exit 0
else
    echo -e "${RED}❌ $ERRORS errores encontrados${NC}"
    [[ $WARNINGS -gt 0 ]] && echo -e "${YELLOW}⚠️  $WARNINGS advertencias adicionales${NC}"
    echo ""
    echo -e "${RED}NO recargues Hyprland hasta arreglar los errores${NC}"
    exit 1
fi
