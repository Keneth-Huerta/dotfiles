#!/usr/bin/env bash

# Script de verificación del proyecto dotfiles
# Verifica que todos los componentes estén en su lugar

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  VERIFICACIÓN DE DOTFILES              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Función para verificar archivos
check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description (falta)"
        return 1
    fi
}

# Función para verificar directorios
check_dir() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${YELLOW}⊘${NC} $description (no existe)"
        return 1
    fi
}

# Función para verificar permisos de ejecución
check_exec() {
    local file="$1"
    local description="$2"
    
    if [ -x "$file" ]; then
        echo -e "${GREEN}✓${NC} $description (ejecutable)"
        return 0
    else
        echo -e "${RED}✗${NC} $description (sin permisos)"
        return 1
    fi
}

echo "Verificando archivos principales..."
check_file "$DOTFILES_DIR/install.sh" "Script principal de instalación"
check_file "$DOTFILES_DIR/config.sh" "Archivo de configuración"
check_file "$DOTFILES_DIR/README.md" "Documentación principal"
check_file "$DOTFILES_DIR/QUICK_START.md" "Guía rápida"
check_file "$DOTFILES_DIR/.gitignore" "Archivo gitignore"

echo ""
echo "Verificando permisos de ejecución..."
check_exec "$DOTFILES_DIR/install.sh" "install.sh"

echo ""
echo "Verificando scripts..."
check_exec "$DOTFILES_DIR/scripts/install-packages.sh" "install-packages.sh"
check_exec "$DOTFILES_DIR/scripts/install-gui.sh" "install-gui.sh"
check_exec "$DOTFILES_DIR/scripts/install-cli-tools.sh" "install-cli-tools.sh"
check_exec "$DOTFILES_DIR/scripts/link-configs.sh" "link-configs.sh"
check_exec "$DOTFILES_DIR/scripts/backup-configs.sh" "backup-configs.sh"

echo ""
echo "Verificando directorios de configuración..."
check_dir "$DOTFILES_DIR/config" "Directorio config"
check_dir "$DOTFILES_DIR/config/starship" "Starship"
check_dir "$DOTFILES_DIR/config/git" "Git"
check_dir "$DOTFILES_DIR/scripts" "Scripts"

echo ""
echo "Verificando archivos de configuración..."
check_file "$DOTFILES_DIR/config/starship/starship.toml" "Starship config"
check_file "$DOTFILES_DIR/config/git/.gitconfig" "Git config"

echo ""
echo "Verificando directorios opcionales..."
check_dir "$DOTFILES_DIR/packages" "Directorio packages"
check_dir "$DOTFILES_DIR/user-scripts" "Directorio user-scripts"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  VERIFICACIÓN COMPLETADA               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Nota:${NC} Los directorios opcionales se crearán automáticamente"
echo -e "${YELLOW}Siguiente paso:${NC} Edita config.sh y ejecuta ./install.sh"
