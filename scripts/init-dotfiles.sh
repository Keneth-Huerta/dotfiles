#!/usr/bin/env bash

# Script de inicialización de configuraciones
# Copia las configuraciones actuales del sistema al repositorio dotfiles

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   INICIALIZACIÓN DE DOTFILES                          ║${NC}"
echo -e "${RED}║   Copia tus configuraciones actuales al repositorio   ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
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
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   INICIALIZACIÓN COMPLETADA            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Siguiente paso:${NC}"
echo -e "  cd $DOTFILES_DIR"
echo -e "  git add config/"
echo -e "  git commit -m 'Add initial configurations'"
echo ""
echo -e "${CYAN}Nota:${NC} Revisa los archivos antes de hacer commit"
echo -e "      Algunos pueden contener información sensible"
