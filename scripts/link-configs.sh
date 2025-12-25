#!/usr/bin/env bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Función para crear symlink con backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$target")"
    
    # Si el target existe y no es un symlink, hacer backup
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "${YELLOW}Haciendo backup de $target${NC}"
        mv "$target" "${target}.bak"
    fi
    
    # Si ya es un symlink, eliminarlo
    if [ -L "$target" ]; then
        rm "$target"
    fi
    
    # Crear symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}✓ Linked: $target -> $source${NC}"
}

# Función para enlazar configuraciones de Hyprland
link_hyprland() {
    echo -e "${BLUE}Enlazando configuraciones de Hyprland...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/hypr" ]; then
        create_symlink "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
    fi
}

# Función para enlazar configuraciones de Waybar
link_waybar() {
    echo -e "${BLUE}Enlazando configuraciones de Waybar...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/waybar" ]; then
        create_symlink "$DOTFILES_DIR/config/waybar" "$HOME/.config/waybar"
    fi
}

# Función para enlazar configuraciones de Kitty
link_kitty() {
    echo -e "${BLUE}Enlazando configuraciones de Kitty...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/kitty" ]; then
        create_symlink "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"
    fi
}



# Función para enlazar configuraciones de Zsh
link_zsh() {
    echo -e "${BLUE}Enlazando configuraciones de Zsh...${NC}"
    
    if [ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]; then
        create_symlink "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
    fi
    
    if [ -f "$DOTFILES_DIR/config/zsh/.zshenv" ]; then
        create_symlink "$DOTFILES_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
    fi
}

# Función para enlazar configuraciones de Neovim
link_neovim() {
    echo -e "${BLUE}Enlazando configuraciones de Neovim...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/nvim" ]; then
        create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
    fi
}

# Función para enlazar configuraciones de Rofi
link_rofi() {
    echo -e "${BLUE}Enlazando configuraciones de Rofi...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/rofi" ]; then
        create_symlink "$DOTFILES_DIR/config/rofi" "$HOME/.config/rofi"
    fi
}

# Función para enlazar configuraciones de Dunst
link_dunst() {
    echo -e "${BLUE}Enlazando configuraciones de Dunst...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/dunst" ]; then
        create_symlink "$DOTFILES_DIR/config/dunst" "$HOME/.config/dunst"
    fi
}

# Función para enlazar configuraciones de Starship
link_starship() {
    echo -e "${BLUE}Enlazando configuraciones de Starship...${NC}"
    
    if [ -f "$DOTFILES_DIR/config/starship/starship.toml" ]; then
        create_symlink "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"
    fi
}

# Función para enlazar configuraciones de Git
link_git() {
    echo -e "${BLUE}Enlazando configuraciones de Git...${NC}"
    
    if [ -f "$DOTFILES_DIR/config/git/.gitconfig" ]; then
        create_symlink "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
    fi
}

# Función para enlazar configuraciones de Tmux
link_tmux() {
    echo -e "${BLUE}Enlazando configuraciones de Tmux...${NC}"
    
    if [ -f "$DOTFILES_DIR/config/tmux/.tmux.conf" ]; then
        create_symlink "$DOTFILES_DIR/config/tmux/.tmux.conf" "$HOME/.tmux.conf"
    fi
}

# Función para enlazar configuraciones de Btop
link_btop() {
    echo -e "${BLUE}Enlazando configuraciones de Btop...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/btop" ]; then
        create_symlink "$DOTFILES_DIR/config/btop" "$HOME/.config/btop"
    fi
}

# Función para enlazar configuraciones de Fastfetch
link_fastfetch() {
    echo -e "${BLUE}Enlazando configuraciones de Fastfetch...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/fastfetch" ]; then
        create_symlink "$DOTFILES_DIR/config/fastfetch" "$HOME/.config/fastfetch"
    fi
}

# Función para enlazar configuraciones de Wlogout
link_wlogout() {
    echo -e "${BLUE}Enlazando configuraciones de Wlogout...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/wlogout" ]; then
        create_symlink "$DOTFILES_DIR/config/wlogout" "$HOME/.config/wlogout"
    fi
}

# Función para enlazar configuraciones de Swaylock
link_swaylock() {
    echo -e "${BLUE}Enlazando configuraciones de Swaylock...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/swaylock" ]; then
        create_symlink "$DOTFILES_DIR/config/swaylock" "$HOME/.config/swaylock"
    fi
}

# Función para enlazar configuraciones de MPV
link_mpv() {
    echo -e "${BLUE}Enlazando configuraciones de MPV...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/mpv" ]; then
        create_symlink "$DOTFILES_DIR/config/mpv" "$HOME/.config/mpv"
    fi
}

# Función para enlazar configuraciones de Ranger
link_ranger() {
    echo -e "${BLUE}Enlazando configuraciones de Ranger...${NC}"
    
    if [ -d "$DOTFILES_DIR/config/ranger" ]; then
        create_symlink "$DOTFILES_DIR/config/ranger" "$HOME/.config/ranger"
    fi
}

# Función para enlazar todas las configuraciones
link_all() {
    link_hyprland
    link_waybar
    link_kitty
    link_zsh
    link_neovim
    link_rofi
    link_dunst
    link_starship
    link_git
    link_tmux
    link_btop
    link_fastfetch
    link_wlogout
    link_swaylock
    link_mpv
    link_ranger
}

# Menú principal
main() {
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   ENLAZAR CONFIGURACIONES              ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "1)  Enlazar todas las configuraciones"
    echo "2)  Hyprland"
    echo "3)  Waybar"
    echo "4)  Kitty"
    echo "5)  Zsh"
    echo "6)  Neovim"
    echo "7)  Rofi"
    echo "8)  Dunst"
    echo "9) Starship"
    echo "10) Git"
    echo "11) Tmux"
    echo "12) Btop"
    echo "13) Fastfetch"
    echo "14) Wlogout"
    echo "15) Swaylock"
    echo "16) MPV"
    echo "17) Ranger"
    echo "0)  Volver"
    echo ""
    read -p "Selecciona una opción: " option
    
    case $option in
        1) link_all ;;
        2) link_hyprland ;;
        3) link_waybar ;;
        4) link_kitty ;;
        5) link_zsh ;;
        6) link_neovim ;;
        7) link_rofi ;;
        8) link_dunst ;;
        9) link_starship ;;
        10) link_git ;;
        11) link_tmux ;;
        12) link_btop ;;
        13) link_fastfetch ;;
        14) link_wlogout ;;
        15) link_swaylock ;;
        16) link_mpv ;;
        17) link_ranger ;;
        0) return ;;
        *) echo -e "${RED}Opción inválida${NC}" ;;
    esac
    
    echo -e "${GREEN}¡Configuraciones enlazadas correctamente!${NC}"
}

main
