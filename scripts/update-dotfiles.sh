#!/usr/bin/env bash
# ============================================================================
# ACTUALIZAR DOTFILES - Sincronizar configuraciones actuales al repositorio
# ============================================================================
# Este script copia tus configuraciones actuales del sistema al repositorio
# de dotfiles, permitiéndote mantenerlo actualizado fácilmente.
# ============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   ACTUALIZAR CONFIGURACIONES EN EL REPOSITORIO        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Función para copiar configuración
sync_config() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    if [ -e "$source" ] || [ -L "$source" ]; then
        # Si es un symlink, obtener el destino real
        if [ -L "$source" ]; then
            local real_source="$(readlink -f "$source")"
            
            # Si el symlink apunta a nuestro repo, no copiarlo
            if [[ "$real_source" == "$DOTFILES_DIR"* ]]; then
                echo -e "${BLUE}→${NC} $name ${YELLOW}(ya enlazado, saltando)${NC}"
                return 0
            fi
            source="$real_source"
        fi
        
        # Crear directorio de destino
        mkdir -p "$(dirname "$target")"
        
        # Si el target existe, hacer backup
        if [ -e "$target" ]; then
            local backup="${target}.old"
            mv "$target" "$backup" 2>/dev/null
        fi
        
        # Copiar
        if cp -r "$source" "$target" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $name actualizado"
            return 0
        else
            echo -e "${RED}✗${NC} Error al copiar $name"
            return 1
        fi
    else
        echo -e "${YELLOW}⊘${NC} $name no existe (saltando)"
        return 1
    fi
}

# Contador de actualizaciones
UPDATED=0
SKIPPED=0
FAILED=0

echo -e "${YELLOW}Sincronizando configuraciones...${NC}"
echo ""

# ============================================================================
# Terminal y Shell
# ============================================================================

echo -e "${CYAN}[Terminal y Shell]${NC}"

if sync_config "$HOME/.config/kitty" "$DOTFILES_DIR/config/kitty" "Kitty"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

if sync_config "$HOME/.zshrc" "$DOTFILES_DIR/config/zsh/.zshrc" "Zsh config"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

if sync_config "$HOME/.zshenv" "$DOTFILES_DIR/config/zsh/.zshenv" "Zsh env"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

if sync_config "$HOME/.p10k.zsh" "$DOTFILES_DIR/config/zsh/.p10k.zsh" "Powerlevel10k"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

if sync_config "$HOME/.config/fish" "$DOTFILES_DIR/config/fish" "Fish"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

echo ""

# ============================================================================
# Editores
# ============================================================================

echo -e "${CYAN}[Editores]${NC}"

if sync_config "$HOME/.config/nvim" "$DOTFILES_DIR/config/nvim" "Neovim"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

echo ""

# ============================================================================
# Prompts y Herramientas CLI
# ============================================================================

echo -e "${CYAN}[Prompts y CLI]${NC}"

if sync_config "$HOME/.config/starship.toml" "$DOTFILES_DIR/config/starship/starship.toml" "Starship"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

if sync_config "$HOME/.tmux.conf" "$DOTFILES_DIR/config/tmux/.tmux.conf" "Tmux"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

echo ""

# ============================================================================
# Git
# ============================================================================

echo -e "${CYAN}[Git]${NC}"

if sync_config "$HOME/.gitconfig" "$DOTFILES_DIR/config/git/.gitconfig" "Git config"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

echo ""

# ============================================================================
# Wayland / Hyprland (si existen)
# ============================================================================

if [ -d "$HOME/.config/hypr" ]; then
    echo -e "${CYAN}[Wayland/Hyprland]${NC}"
    
    if sync_config "$HOME/.config/hypr" "$DOTFILES_DIR/config/hypr" "Hyprland"; then
        ((UPDATED++))
    else
        ((SKIPPED++))
    fi
    
    if sync_config "$HOME/.config/waybar" "$DOTFILES_DIR/config/waybar" "Waybar"; then
        ((UPDATED++))
    else
        ((SKIPPED++))
    fi
    
    if sync_config "$HOME/.config/wofi" "$DOTFILES_DIR/config/wofi" "Wofi"; then
        ((UPDATED++))
    else
        ((SKIPPED++))
    fi
    
    if sync_config "$HOME/.config/swaylock" "$DOTFILES_DIR/config/swaylock" "Swaylock"; then
        ((UPDATED++))
    else
        ((SKIPPED++))
    fi
    
    if sync_config "$HOME/.config/wlogout" "$DOTFILES_DIR/config/wlogout" "WLogout"; then
        ((UPDATED++))
    else
        ((SKIPPED++))
    fi
    
    echo ""
fi

# ============================================================================
# Otros (System monitors, etc)
# ============================================================================

echo -e "${CYAN}[System Monitors]${NC}"

if sync_config "$HOME/.config/btop" "$DOTFILES_DIR/config/btop" "Btop"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

if sync_config "$HOME/.config/fastfetch" "$DOTFILES_DIR/config/fastfetch" "Fastfetch"; then
    ((UPDATED++))
else
    ((SKIPPED++))
fi

echo ""

# ============================================================================
# Resumen
# ============================================================================

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   RESUMEN DE ACTUALIZACIÓN                             ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Actualizados: ${GREEN}$UPDATED${NC}"
echo -e "  ${YELLOW}⊘${NC} Saltados:     ${YELLOW}$SKIPPED${NC}"

if [ $FAILED -gt 0 ]; then
    echo -e "  ${RED}✗${NC} Fallidos:     ${RED}$FAILED${NC}"
fi

echo ""

# ============================================================================
# Git Status y Commit (Opcional)
# ============================================================================

cd "$DOTFILES_DIR" || exit 1

if command -v git &> /dev/null && [ -d .git ]; then
    echo -e "${CYAN}[Git Status]${NC}"
    echo ""
    
    # Mostrar cambios
    if git status --short | grep -q .; then
        git status --short
        echo ""
        
        echo -e "${YELLOW}¿Deseas hacer commit de estos cambios? (s/n)${NC}"
        read -r response
        
        if [[ "$response" =~ ^[sS]$ ]]; then
            echo ""
            echo -e "${CYAN}Ingresa el mensaje del commit:${NC}"
            read -r commit_msg
            
            if [ -n "$commit_msg" ]; then
                git add .
                git commit -m "$commit_msg"
                echo -e "${GREEN}✓ Commit realizado${NC}"
                echo ""
                
                echo -e "${YELLOW}¿Deseas hacer push? (s/n)${NC}"
                read -r push_response
                
                if [[ "$push_response" =~ ^[sS]$ ]]; then
                    git push
                    echo -e "${GREEN}✓ Push realizado${NC}"
                fi
            else
                echo -e "${YELLOW}Commit cancelado (mensaje vacío)${NC}"
            fi
        else
            echo -e "${BLUE}Puedes hacer commit manualmente:${NC}"
            echo -e "  cd $DOTFILES_DIR"
            echo -e "  git add ."
            echo -e "  git commit -m 'Actualizar configuraciones'"
            echo -e "  git push"
        fi
    else
        echo -e "${GREEN}✓ No hay cambios para commitear${NC}"
    fi
fi

echo ""
echo -e "${GREEN}¡Repositorio actualizado!${NC}"
echo ""
