#!/usr/bin/env bash

# ============================================================================
# SSH KEY MANAGER - Gestión de claves SSH
# ============================================================================
# Crea, lista y gestiona tus claves SSH

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SSH_DIR="$HOME/.ssh"
DOTFILES_SSH="$HOME/Documents/repos/dotfiles/ssh-backup"

# Listar claves SSH
list_keys() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     CLAVES SSH DISPONIBLES${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -d "$SSH_DIR" ]; then
        echo -e "${YELLOW}No hay directorio .ssh${NC}"
        return 1
    fi
    
    local found=false
    for key in "$SSH_DIR"/*.pub; do
        if [ -f "$key" ]; then
            found=true
            local keyname=$(basename "$key" .pub)
            local fingerprint=$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
            
            echo -e "${GREEN}▸${NC} ${YELLOW}$keyname${NC}"
            echo -e "  ${BLUE}Fingerprint:${NC} $fingerprint"
            echo -e "  ${BLUE}Ubicación:${NC} $key"
            echo ""
        fi
    done
    
    if [ "$found" = false ]; then
        echo -e "${YELLOW}No hay claves SSH${NC}"
    fi
}

# Crear nueva clave SSH
create_key() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     CREAR NUEVA CLAVE SSH${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "Nombre de la clave (default: id_ed25519): " keyname
    keyname=${keyname:-id_ed25519}
    
    read -p "Email para la clave: " email
    
    local keypath="$SSH_DIR/$keyname"
    
    if [ -f "$keypath" ]; then
        echo -e "${RED}Error: La clave ya existe${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Creando clave SSH...${NC}"
    
    ssh-keygen -t ed25519 -C "$email" -f "$keypath"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Clave creada exitosamente${NC}"
        echo ""
        echo -e "${YELLOW}Clave pública:${NC}"
        cat "$keypath.pub"
        echo ""
        echo -e "${BLUE}Copia la clave pública a GitHub/GitLab${NC}"
    else
        echo -e "${RED}Error al crear la clave${NC}"
    fi
}

# Copiar clave pública al portapapeles
copy_key() {
    list_keys
    
    echo -e "${YELLOW}Ingresa el nombre de la clave para copiar:${NC}"
    read -r keyname
    
    local keyfile="$SSH_DIR/${keyname}.pub"
    
    if [ ! -f "$keyfile" ]; then
        echo -e "${RED}Error: Clave no encontrada${NC}"
        return 1
    fi
    
    if command -v xclip &> /dev/null; then
        cat "$keyfile" | xclip -selection clipboard
        echo -e "${GREEN}✓ Clave copiada al portapapeles${NC}"
    elif command -v wl-copy &> /dev/null; then
        cat "$keyfile" | wl-copy
        echo -e "${GREEN}✓ Clave copiada al portapapeles${NC}"
    else
        echo -e "${YELLOW}Portapapeles no disponible, aquí está la clave:${NC}"
        cat "$keyfile"
    fi
}

# Backup de claves SSH
backup_keys() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     BACKUP DE CLAVES SSH${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${RED}⚠ ADVERTENCIA: Las claves SSH son sensibles${NC}"
    echo -e "${YELLOW}Solo respalda las claves públicas (.pub) en el repo${NC}"
    echo -e "${YELLOW}Las claves privadas deben mantenerse secretas${NC}"
    echo ""
    read -p "¿Continuar con el backup de claves PÚBLICAS? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Backup cancelado${NC}"
        return 1
    fi
    
    mkdir -p "$DOTFILES_SSH"
    
    # Copiar solo claves públicas
    for key in "$SSH_DIR"/*.pub; do
        if [ -f "$key" ]; then
            cp "$key" "$DOTFILES_SSH/"
            echo -e "${GREEN}✓${NC} $(basename "$key") respaldada"
        fi
    done
    
    # Copiar config si existe
    if [ -f "$SSH_DIR/config" ]; then
        cp "$SSH_DIR/config" "$DOTFILES_SSH/"
        echo -e "${GREEN}✓${NC} config respaldado"
    fi
    
    echo ""
    echo -e "${GREEN}Backup completado${NC}"
    echo -e "${BLUE}Ubicación:${NC} $DOTFILES_SSH"
}

# Restaurar claves desde backup
restore_keys() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     RESTAURAR CLAVES SSH${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -d "$DOTFILES_SSH" ]; then
        echo -e "${RED}No hay backup de claves SSH${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Se restaurarán las claves públicas desde:${NC}"
    echo -e "${BLUE}$DOTFILES_SSH${NC}"
    echo ""
    read -p "¿Continuar? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Restauración cancelada${NC}"
        return 1
    fi
    
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    
    # Restaurar claves públicas
    for key in "$DOTFILES_SSH"/*.pub; do
        if [ -f "$key" ]; then
            cp "$key" "$SSH_DIR/"
            chmod 644 "$SSH_DIR/$(basename "$key")"
            echo -e "${GREEN}✓${NC} $(basename "$key") restaurada"
        fi
    done
    
    # Restaurar config
    if [ -f "$DOTFILES_SSH/config" ]; then
        cp "$DOTFILES_SSH/config" "$SSH_DIR/"
        chmod 600 "$SSH_DIR/config"
        echo -e "${GREEN}✓${NC} config restaurado"
    fi
    
    echo ""
    echo -e "${GREEN}Restauración completada${NC}"
    echo -e "${RED}⚠ Recuerda: Necesitas agregar las claves privadas manualmente${NC}"
}

# Configurar ssh-agent
setup_agent() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     CONFIGURAR SSH-AGENT${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Iniciar ssh-agent
    eval "$(ssh-agent -s)"
    
    # Agregar todas las claves
    for key in "$SSH_DIR"/id_*; do
        if [ -f "$key" ] && [[ ! "$key" =~ \.pub$ ]]; then
            echo -e "${YELLOW}Agregando:${NC} $(basename "$key")"
            ssh-add "$key"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✓ SSH-agent configurado${NC}"
    echo ""
    echo -e "${BLUE}Claves cargadas:${NC}"
    ssh-add -l
}

# Main
main() {
    clear
    echo -e "${RED}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                  SSH KEY MANAGER                             ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${GREEN}1)${NC} Listar claves SSH"
    echo -e "${GREEN}2)${NC} Crear nueva clave SSH"
    echo -e "${GREEN}3)${NC} Copiar clave pública"
    echo -e "${GREEN}4)${NC} Backup de claves (solo públicas)"
    echo -e "${GREEN}5)${NC} Restaurar claves desde backup"
    echo -e "${GREEN}6)${NC} Configurar ssh-agent"
    echo -e "${GREEN}0)${NC} Salir"
    echo ""
    read -p "Selecciona una opción: " option
    
    case $option in
        1) list_keys ;;
        2) create_key ;;
        3) copy_key ;;
        4) backup_keys ;;
        5) restore_keys ;;
        6) setup_agent ;;
        0) exit 0 ;;
        *) echo -e "${RED}Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
    main
}

main
