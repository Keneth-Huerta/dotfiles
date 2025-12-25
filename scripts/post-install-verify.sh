#!/usr/bin/env bash

# ============================================================================
# POST-INSTALLATION VERIFICATION
# ============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

verify_installation() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     VERIFICACIÓN POST-INSTALACIÓN${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local total_checks=0
    local passed_checks=0
    local failed_packages=()
    
    # Leer paquetes instalados desde pacman-explicit.txt
    if [ -f "$1" ]; then
        local packages_file="$1"
        
        echo -e "${BLUE}Verificando paquetes desde: $packages_file${NC}"
        echo ""
        
        while IFS= read -r package; do
            # Ignorar líneas vacías y comentarios
            [[ -z "$package" || "$package" =~ ^# ]] && continue
            
            ((total_checks++))
            
            # Verificar si el paquete está instalado
            if pacman -Q "$package" &> /dev/null; then
                echo -e "${GREEN}✓${NC} $package"
                ((passed_checks++))
            else
                echo -e "${RED}✗${NC} $package ${YELLOW}(no instalado)${NC}"
                failed_packages+=("$package")
            fi
        done < "$packages_file"
    else
        echo -e "${RED}Error: Archivo de paquetes no encontrado${NC}"
        return 1
    fi
    
    # Resumen
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Total de paquetes:${NC} $total_checks"
    echo -e "${GREEN}Instalados correctamente:${NC} $passed_checks"
    echo -e "${RED}Faltantes:${NC} ${#failed_packages[@]}"
    
    local success_rate=$((passed_checks * 100 / total_checks))
    echo -e "${BLUE}Tasa de éxito:${NC} $success_rate%"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    
    # Reintentar paquetes faltantes
    if [ ${#failed_packages[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Paquetes faltantes:${NC}"
        for pkg in "${failed_packages[@]}"; do
            echo -e "  ${RED}→${NC} $pkg"
        done
        
        echo ""
        read -p "$(echo -e ${YELLOW}¿Deseas intentar instalarlos ahora? [y/N]: ${NC})" retry
        
        if [[ "$retry" =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${BLUE}Reintentando instalación de paquetes faltantes...${NC}"
            
            for pkg in "${failed_packages[@]}"; do
                echo -e "${BLUE}Instalando $pkg...${NC}"
                if sudo pacman -S --noconfirm "$pkg" 2>&1; then
                    echo -e "${GREEN}✓ $pkg instalado${NC}"
                else
                    echo -e "${RED}✗ Error al instalar $pkg${NC}"
                fi
            done
            
            # Verificar nuevamente
            echo ""
            echo -e "${BLUE}Verificando instalación nuevamente...${NC}"
            verify_installation "$packages_file"
        fi
    else
        echo ""
        echo -e "${GREEN}✓ Todos los paquetes se instalaron correctamente${NC}"
    fi
}

# Verificar servicios
verify_services() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     VERIFICACIÓN DE SERVICIOS${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local services=("NetworkManager" "bluetooth" "docker")
    
    for service in "${services[@]}"; do
        if systemctl is-enabled "$service" &> /dev/null 2>&1; then
            if systemctl is-active "$service" &> /dev/null 2>&1; then
                echo -e "${GREEN}✓${NC} $service ${GREEN}(activo)${NC}"
            else
                echo -e "${YELLOW}⚠${NC} $service ${YELLOW}(habilitado pero no activo)${NC}"
            fi
        else
            echo -e "${BLUE}○${NC} $service ${BLUE}(no habilitado)${NC}"
        fi
    done
}

# Verificar configuraciones
verify_configs() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     VERIFICACIÓN DE CONFIGURACIONES${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local configs=(
        "$HOME/.config/hypr:Hyprland"
        "$HOME/.config/waybar:Waybar"
        "$HOME/.config/kitty:Kitty"
        "$HOME/.zshrc:Zsh"
    )
    
    for config_entry in "${configs[@]}"; do
        IFS=':' read -r path name <<< "$config_entry"
        
        if [ -e "$path" ]; then
            if [ -L "$path" ]; then
                echo -e "${GREEN}✓${NC} $name ${CYAN}(symlink)${NC}"
            else
                echo -e "${GREEN}✓${NC} $name ${BLUE}(archivo)${NC}"
            fi
        else
            echo -e "${RED}✗${NC} $name ${RED}(no encontrado)${NC}"
        fi
    done
}

# Main
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Uso: $0 <archivo-de-paquetes>${NC}"
    echo -e "${BLUE}Ejemplo: $0 packages/pacman-explicit.txt${NC}"
    exit 1
fi

verify_installation "$1"
verify_services
verify_configs

echo ""
echo -e "${GREEN}✓ Verificación completada${NC}"
