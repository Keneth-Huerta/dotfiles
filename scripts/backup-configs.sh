#!/usr/bin/env bash

# ============================================================================
# BACKUP DE CONFIGURACIONES - Con Timestamps y Organización
# ============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_ROOT="$HOME/.config-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/backup-$TIMESTAMP"

# Crear directorio de backups
mkdir -p "$BACKUP_DIR"

# Función para copiar configuración con verificación
copy_config() {
    local source="$1"
    local target="$2"
    
    if [ -e "$source" ] || [ -L "$source" ]; then
        # Si es un symlink, copiar el archivo real
        if [ -L "$source" ]; then
            source="$(readlink -f "$source")"
        fi
        
        # Crear directorio de destino
        mkdir -p "$(dirname "$target")"
        
        # Copiar
        cp -r "$source" "$target"
        echo -e "${GREEN}✓ Copiado: $source -> $target${NC}"
    else
        echo -e "${YELLOW}⊘ No existe: $source${NC}"
    fi
}

# Función para hacer backup de Hyprland
backup_hyprland() {
    echo -e "${BLUE}Haciendo backup de Hyprland...${NC}"
    copy_config "$HOME/.config/hypr" "$BACKUP_DIR/hypr"
}

# Función para hacer backup de Waybar
backup_waybar() {
    echo -e "${BLUE}Haciendo backup de Waybar...${NC}"
    copy_config "$HOME/.config/waybar" "$BACKUP_DIR/waybar"
}

# Función para hacer backup de Kitty
backup_kitty() {
    echo -e "${BLUE}Haciendo backup de Kitty...${NC}"
    copy_config "$HOME/.config/kitty" "$BACKUP_DIR/kitty"
}

# Función para hacer backup de Fish
backup_fish() {
    echo -e "${BLUE}Haciendo backup de Fish...${NC}"
    copy_config "$HOME/.config/fish" "$DOTFILES_DIR/config/fish"
}

# Función para hacer backup de Zsh
backup_zsh() {
    echo -e "${BLUE}Haciendo backup de Zsh...${NC}"
    mkdir -p "$DOTFILES_DIR/config/zsh"
    copy_config "$HOME/.zshrc" "$DOTFILES_DIR/config/zsh/.zshrc"
    copy_config "$HOME/.zshenv" "$DOTFILES_DIR/config/zsh/.zshenv"
    copy_config "$HOME/.zprofile" "$DOTFILES_DIR/config/zsh/.zprofile"
}

# Función para hacer backup de Neovim
backup_neovim() {
    echo -e "${BLUE}Haciendo backup de Neovim...${NC}"
    copy_config "$HOME/.config/nvim" "$DOTFILES_DIR/config/nvim"
}

# Función para hacer backup de Rofi
backup_rofi() {
    echo -e "${BLUE}Haciendo backup de Rofi...${NC}"
    copy_config "$HOME/.config/rofi" "$DOTFILES_DIR/config/rofi"
}

# Función para hacer backup de Dunst
backup_dunst() {
    echo -e "${BLUE}Haciendo backup de Dunst...${NC}"
    copy_config "$HOME/.config/dunst" "$DOTFILES_DIR/config/dunst"
}

# Función para hacer backup de Starship
backup_starship() {
    echo -e "${BLUE}Haciendo backup de Starship...${NC}"
    mkdir -p "$DOTFILES_DIR/config/starship"
    copy_config "$HOME/.config/starship.toml" "$DOTFILES_DIR/config/starship/starship.toml"
}

# Función para hacer backup de Git
backup_git() {
    echo -e "${BLUE}Haciendo backup de Git...${NC}"
    mkdir -p "$DOTFILES_DIR/config/git"
    copy_config "$HOME/.gitconfig" "$DOTFILES_DIR/config/git/.gitconfig"
}

# Función para hacer backup de Tmux
backup_tmux() {
    echo -e "${BLUE}Haciendo backup de Tmux...${NC}"
    mkdir -p "$DOTFILES_DIR/config/tmux"
    copy_config "$HOME/.tmux.conf" "$DOTFILES_DIR/config/tmux/.tmux.conf"
}

# Función para hacer backup de Btop
backup_btop() {
    echo -e "${BLUE}Haciendo backup de Btop...${NC}"
    copy_config "$HOME/.config/btop" "$DOTFILES_DIR/config/btop"
}

# Función para hacer backup de Fastfetch
backup_fastfetch() {
    echo -e "${BLUE}Haciendo backup de Fastfetch...${NC}"
    copy_config "$HOME/.config/fastfetch" "$DOTFILES_DIR/config/fastfetch"
}

# Función para hacer backup de Cava
backup_cava() {
    echo -e "${BLUE}Haciendo backup de Cava...${NC}"
    copy_config "$HOME/.config/cava" "$DOTFILES_DIR/config/cava"
}

# Función para hacer backup de scripts personalizados
backup_scripts() {
    echo -e "${BLUE}Haciendo backup de scripts...${NC}"
    if [ -d "$HOME/Documents/scripts" ]; then
        mkdir -p "$DOTFILES_DIR/user-scripts"
        cp -r "$HOME/Documents/scripts/"* "$DOTFILES_DIR/user-scripts/" 2>/dev/null
        echo -e "${GREEN}✓ Scripts copiados${NC}"
    fi
}

# Función para exportar lista de paquetes instalados
export_package_list() {
    echo -e "${BLUE}Exportando lista de paquetes...${NC}"
    
    # Usar el script dedicado de exportación
    if [ -x "$DOTFILES_DIR/scripts/export-packages.sh" ]; then
        bash "$DOTFILES_DIR/scripts/export-packages.sh"
    else
        echo -e "${YELLOW}Script export-packages.sh no encontrado, exportando manualmente...${NC}"
        
        mkdir -p "$DOTFILES_DIR/packages"
        
        # Paquetes oficiales explícitamente instalados
        pacman -Qqe > "$DOTFILES_DIR/packages/pacman-explicit.txt"
        
        # Todos los paquetes nativos
        pacman -Qqn > "$DOTFILES_DIR/packages/pacman-native.txt"
        
        # Paquetes AUR
        pacman -Qqm > "$DOTFILES_DIR/packages/aur.txt"
        
        # Paquetes flatpak
        if command -v flatpak &> /dev/null; then
            flatpak list --app --columns=application > "$DOTFILES_DIR/packages/flatpak.txt"
        fi
        
        # Paquetes snap
        if command -v snap &> /dev/null; then
            snap list | tail -n +2 | awk '{print $1}' > "$DOTFILES_DIR/packages/snap.txt"
        fi
        
        # Paquetes npm globales
        if command -v npm &> /dev/null; then
            npm list -g --depth=0 2>/dev/null | tail -n +2 | awk '{print $2}' | sed 's/@.*//' > "$DOTFILES_DIR/packages/npm-global.txt"
        fi
        
        # Paquetes pip globales
        if command -v pip &> /dev/null; then
            pip list --format=freeze > "$DOTFILES_DIR/packages/pip-global.txt"
        fi
        
        echo -e "${GREEN}✓ Listas de paquetes exportadas${NC}"
    fi
}

# Función para hacer backup de todo
backup_all() {
    backup_hyprland
    backup_waybar
    backup_kitty
    backup_fish
    backup_zsh
    backup_neovim
    backup_rofi
    backup_dunst
    backup_starship
    backup_git
    backup_tmux
    backup_btop
    backup_fastfetch
    backup_cava
    backup_scripts
    export_package_list
}

# Menú principal
main() {
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   BACKUP DE CONFIGURACIONES            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "1)  Hacer backup de todo"
    echo "2)  Hyprland"
    echo "3)  Waybar"
    echo "4)  Kitty"
    echo "5)  Fish"
    echo "6)  Zsh"
    echo "7)  Neovim"
    echo "8)  Rofi"
    echo "9)  Dunst"
    echo "10) Starship"
    echo "11) Git"
    echo "12) Tmux"
    echo "13) Btop"
    echo "14) Fastfetch"
    echo "15) Cava"
    echo "16) Scripts personalizados"
    echo "17) Exportar lista de paquetes"
    echo "0)  Volver"
    echo ""
    read -p "Selecciona una opción: " option
    
    case $option in
        1) backup_all ;;
        2) backup_hyprland ;;
        3) backup_waybar ;;
        4) backup_kitty ;;
        5) backup_fish ;;
        6) backup_zsh ;;
        7) backup_neovim ;;
        8) backup_rofi ;;
        9) backup_dunst ;;
        10) backup_starship ;;
        11) backup_git ;;
        12) backup_tmux ;;
        13) backup_btop ;;
        14) backup_fastfetch ;;
        15) backup_cava ;;
        16) backup_scripts ;;
        17) export_package_list ;;
        0) return ;;
        *) echo -e "${RED}Opción inválida${NC}" ;;
    esac
    
    # Mostrar resumen del backup
    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        echo -e "${CYAN}════════════════════════════════════════${NC}"
        echo -e "${GREEN}✓ Backup completado${NC}"
        echo -e "${BLUE}Ubicación:${NC} $BACKUP_DIR"
        
        # Calcular tamaño
        local size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
        echo -e "${BLUE}Tamaño:${NC} $size"
        
        # Contar archivos
        local files=$(find "$BACKUP_DIR" -type f | wc -l)
        echo -e "${BLUE}Archivos:${NC} $files"
        
        echo -e "${CYAN}════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}Para restaurar este backup usa:${NC}"
        echo -e "  ./scripts/restore-backup.sh $TIMESTAMP"
        echo ""
    fi
    
    echo -e "${YELLOW}No olvides hacer commit de los cambios:${NC}"
    echo -e "  cd $DOTFILES_DIR"
    echo -e "  git add ."
    echo -e "  git commit -m 'Update dotfiles'"
    echo -e "  git push"
}

main
