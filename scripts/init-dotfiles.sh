#!/usr/bin/env bash

# ============================================================================
# INIT DOTFILES - Inicialización y Setup
# ============================================================================
# - Mueve el repositorio a la ubicación correcta
# - Copia configuraciones actuales
# - Configura el entorno

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$HOME/Documents/repos/dotfiles"

echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   INICIALIZACIÓN DE DOTFILES                          ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# PASO 1: Mover repositorio a la ubicación correcta
# ============================================================================

move_to_correct_location() {
    echo -e "${CYAN}[1/3] Verificando ubicación del repositorio...${NC}"
    
    # Si ya está en la ubicación correcta, no hacer nada
    if [ "$DOTFILES_DIR" = "$TARGET_DIR" ]; then
        echo -e "${GREEN}✓ El repositorio ya está en la ubicación correcta${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}⚠ El repositorio está en: $DOTFILES_DIR${NC}"
    echo -e "${BLUE}Ubicación recomendada: $TARGET_DIR${NC}"
    echo ""
    read -p "¿Deseas mover el repositorio a la ubicación recomendada? [Y/n]: " move_repo
    
    if [[ "$move_repo" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Conservando ubicación actual${NC}"
        return 0
    fi
    
    # Crear directorio de repos si no existe
    mkdir -p "$HOME/Documents/repos"
    
    # Si el destino existe, hacer backup
    if [ -d "$TARGET_DIR" ]; then
        local backup="$TARGET_DIR.backup-$(date +%Y%m%d-%H%M%S)"
        echo -e "${YELLOW}El destino existe, creando backup: $backup${NC}"
        mv "$TARGET_DIR" "$backup"
    fi
    
    # Mover el repositorio
    echo -e "${BLUE}Moviendo repositorio...${NC}"
    mv "$DOTFILES_DIR" "$TARGET_DIR"
    
    echo -e "${GREEN}✓ Repositorio movido exitosamente${NC}"
    echo -e "${BLUE}Nueva ubicación: $TARGET_DIR${NC}"
    echo ""
    echo -e "${YELLOW}⚠ IMPORTANTE: Ejecuta el script desde la nueva ubicación:${NC}"
    echo -e "  cd $TARGET_DIR"
    echo -e "  ./install.sh"
    echo ""
    exit 0
}

move_to_correct_location
echo ""

# ============================================================================
# PASO 2: Copiar configuraciones actuales
# ============================================================================

echo -e "${CYAN}[2/3] Copiando configuraciones actuales...${NC}"
echo ""

# Función para copiar config
copy_if_exists() {
    local source="$1"
    local dest="$2"
    local name="$3"
    
    if [ -e "$source" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -r "$source" "$dest"
        echo -e "${GREEN}✓${NC} $name copiado"
        return 0
    else
        echo -e "${YELLOW}⊘${NC} $name no existe (saltando)"
        return 1
    fi
}

echo -e "${CYAN}Copiando configuraciones desde ~/.config/ ...${NC}"
echo ""

# Copiar configuración de Powerlevel10k si existe
if [ -f "$HOME/.p10k.zsh" ]; then
    copy_if_exists "$HOME/.p10k.zsh" "$DOTFILES_DIR/config/zsh/.p10k.zsh" "Powerlevel10k config"
fi

# Hyprland y Wayland
copy_if_exists "$HOME/.config/hypr" "$DOTFILES_DIR/config/hypr" "Hyprland"
copy_if_exists "$HOME/.config/waybar" "$DOTFILES_DIR/config/waybar" "Waybar"
copy_if_exists "$HOME/.config/wlogout" "$DOTFILES_DIR/config/wlogout" "WLogout"
copy_if_exists "$HOME/.config/swaylock" "$DOTFILES_DIR/config/swaylock" "Swaylock"
copy_if_exists "$HOME/.config/wofi" "$DOTFILES_DIR/config/wofi" "Wofi"

# Terminal
copy_if_exists "$HOME/.config/kitty" "$DOTFILES_DIR/config/kitty" "Kitty"
copy_if_exists "$HOME/.config/fish" "$DOTFILES_DIR/config/fish" "Fish"

# Shell configs
copy_if_exists "$HOME/.zshrc" "$DOTFILES_DIR/config/zsh/.zshrc" "Zsh config"
copy_if_exists "$HOME/.zshenv" "$DOTFILES_DIR/config/zsh/.zshenv" "Zsh env"
copy_if_exists "$HOME/.config/starship.toml" "$DOTFILES_DIR/config/starship/starship.toml" "Starship"

# Editores
copy_if_exists "$HOME/.config/nvim" "$DOTFILES_DIR/config/nvim" "Neovim"
copy_if_exists "$HOME/.config/Code" "$DOTFILES_DIR/config/vscode" "VS Code"

# System monitors
copy_if_exists "$HOME/.config/btop" "$DOTFILES_DIR/config/btop" "Btop"
copy_if_exists "$HOME/.config/htop" "$DOTFILES_DIR/config/htop" "Htop"
copy_if_exists "$HOME/.config/fastfetch" "$DOTFILES_DIR/config/fastfetch" "Fastfetch"
copy_if_exists "$HOME/.config/cava" "$DOTFILES_DIR/config/cava" "Cava"

# File managers
copy_if_exists "$HOME/.config/ranger" "$DOTFILES_DIR/config/ranger" "Ranger"

# Git
copy_if_exists "$HOME/.gitconfig" "$DOTFILES_DIR/config/git/.gitconfig" "Git config"

# Tmux
copy_if_exists "$HOME/.tmux.conf" "$DOTFILES_DIR/config/tmux/.tmux.conf" "Tmux"

# MPV
copy_if_exists "$HOME/.config/mpv" "$DOTFILES_DIR/config/mpv" "MPV"

# Extras
copy_if_exists "$HOME/.config/copyq" "$DOTFILES_DIR/config/copyq" "CopyQ"
copy_if_exists "$HOME/.config/bongocat" "$DOTFILES_DIR/config/bongocat" "BongoCat"

echo ""

# ============================================================================
# PASO 3: Configurar archivos adicionales
# ============================================================================

echo -e "${CYAN}[3/3] Configurando archivos adicionales...${NC}"
echo ""

# Crear archivo de repos si no existe
if [ ! -f "$DOTFILES_DIR/repos.list" ]; then
    touch "$DOTFILES_DIR/repos.list"
    echo -e "${GREEN}✓${NC} repos.list creado (agrega tus repositorios aquí)"
fi

# Crear .gitignore si no existe
if [ ! -f "$DOTFILES_DIR/.gitignore" ]; then
    cat > "$DOTFILES_DIR/.gitignore" << 'EOF'
# Logs
*.log

# SSH private keys (NUNCA subir claves privadas)
ssh-backup/*
!ssh-backup/*.pub
!ssh-backup/config

# Información sensible
*.secret
.env

# Sistema
.DS_Store
Thumbs.db
EOF
    echo -e "${GREEN}✓${NC} .gitignore creado"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   INICIALIZACIÓN COMPLETADA            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Resumen:${NC}"
echo -e "  ${GREEN}✓${NC} Repositorio en la ubicación correcta"
echo -e "  ${GREEN}✓${NC} Configuraciones copiadas"
echo -e "  ${GREEN}✓${NC} Archivos auxiliares configurados"
echo ""
echo -e "${YELLOW}Siguiente paso:${NC}"
echo -e "  cd $DOTFILES_DIR"
echo -e "  git add ."
echo -e "  git commit -m 'Initial dotfiles configuration'"
echo ""
echo -e "${CYAN}Herramientas disponibles:${NC}"
echo -e "  ./scripts/repo-manager.sh  - Gestionar repositorios"
echo -e "  ./scripts/ssh-manager.sh   - Gestionar claves SSH"
echo -e "  ./scripts/health-check.sh  - Verificar salud del sistema"
echo ""
echo -e "${RED}⚠ IMPORTANTE:${NC} Revisa los archivos antes de hacer commit"
echo -e "  Algunos pueden contener información sensible"

