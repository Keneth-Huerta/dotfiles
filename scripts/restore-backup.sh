#!/usr/bin/env bash

# ============================================================================
# RESTORE BACKUP - Restaurar configuraciones desde backup
# ============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_ROOT="$HOME/.config-backups"

# Listar backups disponibles
list_backups() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     BACKUPS DISPONIBLES${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -d "$BACKUP_ROOT" ]; then
        echo -e "${YELLOW}No hay backups disponibles${NC}"
        return 1
    fi
    
    local i=1
    local backups=()
    
    for backup in "$BACKUP_ROOT"/backup-*; do
        if [ -d "$backup" ]; then
            local timestamp=$(basename "$backup" | sed 's/backup-//')
            local date_formatted=$(date -d "${timestamp:0:8} ${timestamp:9:2}:${timestamp:11:2}:${timestamp:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || echo "$timestamp")
            local size=$(du -sh "$backup" 2>/dev/null | cut -f1)
            local files=$(find "$backup" -type f 2>/dev/null | wc -l)
            
            backups+=("$backup")
            echo -e "${GREEN}$i.${NC} ${YELLOW}$date_formatted${NC}"
            echo -e "   ${BLUE}Tamaño:${NC} $size ${BLUE}| Archivos:${NC} $files"
            echo -e "   ${BLUE}Ruta:${NC} $backup"
            echo ""
            ((i++))
        fi
    done
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${YELLOW}No hay backups disponibles${NC}"
        return 1
    fi
    
    return 0
}

# Restaurar backup específico
restore_backup() {
    local backup_path="$1"
    
    if [ ! -d "$backup_path" ]; then
        echo -e "${RED}Error: Backup no encontrado${NC}"
        return 1
    fi
    
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Restaurando backup:${NC} $backup_path"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo ""
    
    # Confirmar
    read -p "$(echo -e ${YELLOW}¿Deseas continuar? [y/N]: ${NC})" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Restauración cancelada${NC}"
        return 1
    fi
    
    # Crear backup de seguridad de configs actuales
    local safety_backup="$HOME/.config-backup-before-restore-$(date +%Y%m%d-%H%M%S)"
    echo -e "${BLUE}Creando backup de seguridad...${NC}"
    mkdir -p "$safety_backup"
    
    # Restaurar cada configuración
    for config in "$backup_path"/*; do
        if [ -d "$config" ] || [ -f "$config" ]; then
            local config_name=$(basename "$config")
            local target="$HOME/.config/$config_name"
            
            # Backup de config actual si existe
            if [ -e "$target" ]; then
                echo -e "${YELLOW}Respaldando:${NC} $target"
                cp -r "$target" "$safety_backup/"
            fi
            
            # Restaurar
            echo -e "${GREEN}Restaurando:${NC} $config_name"
            cp -r "$config" "$HOME/.config/"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✓ Restauración completada${NC}"
    echo -e "${BLUE}Backup de seguridad guardado en:${NC}"
    echo -e "  $safety_backup"
    echo ""
}

# Restaurar interactivamente
restore_interactive() {
    list_backups
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    echo -e "${YELLOW}Selecciona el backup a restaurar (número):${NC}"
    read -r choice
    
    # Obtener la ruta del backup seleccionado
    local i=1
    for backup in "$BACKUP_ROOT"/backup-*; do
        if [ -d "$backup" ] && [ $i -eq $choice ]; then
            restore_backup "$backup"
            return 0
        fi
        ((i++))
    done
    
    echo -e "${RED}Opción inválida${NC}"
    return 1
}

# Eliminar backups antiguos
clean_old_backups() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     LIMPIEZA DE BACKUPS ANTIGUOS${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}¿Cuántos backups recientes deseas conservar?${NC}"
    read -p "Número (default: 5): " keep_count
    keep_count=${keep_count:-5}
    
    local backups=()
    for backup in "$BACKUP_ROOT"/backup-*; do
        if [ -d "$backup" ]; then
            backups+=("$backup")
        fi
    done
    
    # Ordenar por fecha (más recientes primero)
    IFS=$'\n' backups=($(sort -r <<<"${backups[*]}"))
    unset IFS
    
    local total=${#backups[@]}
    local to_delete=$((total - keep_count))
    
    if [ $to_delete -le 0 ]; then
        echo -e "${GREEN}No hay backups para eliminar${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Se eliminarán $to_delete backups antiguos${NC}"
    read -p "$(echo -e ${YELLOW}¿Continuar? [y/N]: ${NC})" confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Operación cancelada${NC}"
        return 1
    fi
    
    # Eliminar backups antiguos
    for ((i=keep_count; i<total; i++)); do
        echo -e "${RED}Eliminando:${NC} ${backups[$i]}"
        rm -rf "${backups[$i]}"
    done
    
    echo -e "${GREEN}✓ Limpieza completada${NC}"
}

# Main
main() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${RED}RESTORE BACKUP${NC}                                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}1)${NC} Restaurar backup (interactivo)"
    echo -e "${GREEN}2)${NC} Listar backups disponibles"
    echo -e "${GREEN}3)${NC} Limpiar backups antiguos"
    echo -e "${GREEN}0)${NC} Salir"
    echo ""
    read -p "Selecciona una opción: " option
    
    case $option in
        1) restore_interactive ;;
        2) list_backups ;;
        3) clean_old_backups ;;
        0) exit 0 ;;
        *) echo -e "${RED}Opción inválida${NC}" ;;
    esac
}

# Si se proporciona un timestamp como argumento
if [ $# -eq 1 ]; then
    restore_backup "$BACKUP_ROOT/backup-$1"
else
    main
fi
