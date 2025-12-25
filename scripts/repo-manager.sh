#!/usr/bin/env bash

# ============================================================================
# REPOSITORY MANAGER - Gestión de repositorios Git
# ============================================================================
# Clona, actualiza y gestiona todos tus repositorios de desarrollo

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOS_FILE="$DOTFILES_DIR/repos.list"
DEFAULT_REPOS_DIR="$HOME/Documents/repos"

# Verificar si SSH está configurado
check_ssh_keys() {
    if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
        return 1
    fi
    return 0
}

# Verificar si una URL es SSH o HTTPS
is_ssh_url() {
    [[ "$1" =~ ^git@.*:.*\.git$ ]]
}

# Verificar conectividad con GitHub/GitLab
check_git_connectivity() {
    local url="$1"
    
    if [[ "$url" =~ github\.com ]]; then
        ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" && return 0
    elif [[ "$url" =~ gitlab\.com ]]; then
        ssh -T git@gitlab.com 2>&1 | grep -q "Welcome" && return 0
    fi
    return 1
}

# Verificar configuración SSH
verify_ssh_config() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     VERIFICACIÓN SSH${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificar claves SSH
    if check_ssh_keys; then
        echo -e "${GREEN}✓${NC} Claves SSH encontradas:"
        [ -f "$HOME/.ssh/id_ed25519" ] && echo -e "   • ${BLUE}id_ed25519${NC}"
        [ -f "$HOME/.ssh/id_rsa" ] && echo -e "   • ${BLUE}id_rsa${NC}"
    else
        echo -e "${RED}✗${NC} No se encontraron claves SSH"
        echo -e "${YELLOW}Ejecuta:${NC} ./scripts/ssh-manager.sh para crear una"
        return 1
    fi
    echo ""
    
    # Verificar GitHub
    echo -e "${YELLOW}→${NC} Verificando GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo -e "${GREEN}✓${NC} GitHub: Autenticado correctamente"
    else
        echo -e "${RED}✗${NC} GitHub: No autenticado o sin conexión"
        echo -e "${YELLOW}Agrega tu clave pública a:${NC} https://github.com/settings/keys"
    fi
    echo ""
    
    # Verificar GitLab
    echo -e "${YELLOW}→${NC} Verificando GitLab..."
    if ssh -T git@gitlab.com 2>&1 | grep -q "Welcome"; then
        echo -e "${GREEN}✓${NC} GitLab: Autenticado correctamente"
    else
        echo -e "${RED}✗${NC} GitLab: No autenticado o sin conexión"
        echo -e "${YELLOW}Agrega tu clave pública a:${NC} https://gitlab.com/-/profile/keys"
    fi
    echo ""
    
    # Verificar ssh-agent
    if ssh-add -l &>/dev/null; then
        echo -e "${GREEN}✓${NC} ssh-agent está ejecutándose"
    else
        echo -e "${YELLOW}⚠${NC} ssh-agent no está activo"
        echo -e "${YELLOW}Ejecuta:${NC} eval \$(ssh-agent -s) && ssh-add"
    fi
}

# Convertir URLs HTTPS a SSH
convert_to_ssh() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     CONVERTIR A SSH${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Esta opción convertirá URLs HTTPS a formato SSH${NC}"
    echo -e "${YELLOW}Útil para repositorios privados${NC}"
    echo ""
    
    # Crear backup
    cp "$REPOS_FILE" "$REPOS_FILE.backup"
    echo -e "${GREEN}✓${NC} Backup creado: repos.list.backup"
    echo ""
    
    # Convertir URLs
    local converted=0
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        read -r url dest <<< "$line"
        
        # Si ya es SSH, omitir
        if is_ssh_url "$url"; then
            continue
        fi
        
        # Convertir HTTPS a SSH
        if [[ "$url" =~ ^https://github\.com/(.+)/(.+)\.git$ ]]; then
            local new_url="git@github.com:${BASH_REMATCH[1]}/${BASH_REMATCH[2]}.git"
            sed -i "s|$url|$new_url|g" "$REPOS_FILE"
            echo -e "${GREEN}✓${NC} Convertido: $(basename "$url" .git)"
            echo -e "   ${BLUE}De:${NC} $url"
            echo -e "   ${BLUE}A:${NC}  $new_url"
            ((converted++))
        elif [[ "$url" =~ ^https://gitlab\.com/(.+)/(.+)\.git$ ]]; then
            local new_url="git@gitlab.com:${BASH_REMATCH[1]}/${BASH_REMATCH[2]}.git"
            sed -i "s|$url|$new_url|g" "$REPOS_FILE"
            echo -e "${GREEN}✓${NC} Convertido: $(basename "$url" .git)"
            ((converted++))
        fi
    done < "$REPOS_FILE.backup"
    
    echo ""
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${BLUE}URLs convertidas:${NC} $converted"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    
    if [ $converted -eq 0 ]; then
        echo -e "${YELLOW}No se encontraron URLs HTTPS para convertir${NC}"
    else
        echo -e "${GREEN}✓ Conversión completada${NC}"
        echo -e "${YELLOW}Ahora puedes clonar los repositorios privados${NC}"
    fi
}

# Crear archivo de repos si no existe
init_repos_file() {
    if [ ! -f "$REPOS_FILE" ]; then
        cat > "$REPOS_FILE" << 'EOF'
# ============================================================================
# LISTA DE REPOSITORIOS
# ============================================================================
# Formato: URL_DEL_REPO [DIRECTORIO_DESTINO]
# Si no se especifica directorio, se usa ~/Documents/repos
#
# Ejemplos:
# https://github.com/usuario/proyecto
# https://github.com/usuario/otro-proyecto custom-dir
# git@github.com:usuario/privado.git
#
# Tus repositorios:
EOF
        echo -e "${GREEN}✓ Archivo repos.list creado${NC}"
        echo -e "${BLUE}Edita${NC} $REPOS_FILE ${BLUE}para agregar tus repositorios${NC}"
    fi
}

# Listar repositorios configurados
list_repos() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     REPOSITORIOS CONFIGURADOS${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -f "$REPOS_FILE" ]; then
        echo -e "${YELLOW}No hay repositorios configurados${NC}"
        echo -e "${BLUE}Edita:${NC} $REPOS_FILE"
        return 1
    fi
    
    local i=1
    while IFS= read -r line; do
        # Ignorar comentarios y líneas vacías
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        read -r url dest <<< "$line"
        local repo_name=$(basename "$url" .git)
        local target_dir="${dest:-$DEFAULT_REPOS_DIR/$repo_name}"
        
        echo -e "${GREEN}$i.${NC} ${YELLOW}$repo_name${NC}"
        echo -e "   ${BLUE}URL:${NC} $url"
        echo -e "   ${BLUE}Dir:${NC} $target_dir"
        
        # Verificar si ya está clonado
        if [ -d "$target_dir/.git" ]; then
            cd "$target_dir"
            local branch=$(git branch --show-current 2>/dev/null)
            local status=$(git status --porcelain 2>/dev/null)
            
            if [ -z "$status" ]; then
                echo -e "   ${GREEN}✓ Clonado (branch: $branch, limpio)${NC}"
            else
                echo -e "   ${YELLOW}⚠ Clonado (branch: $branch, cambios sin commit)${NC}"
            fi
        else
            echo -e "   ${RED}✗ No clonado${NC}"
        fi
        
        echo ""
        ((i++))
    done < "$REPOS_FILE"
}

# Clonar todos los repositorios
clone_all() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     CLONANDO REPOSITORIOS${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificar SSH si hay repos privados
    local has_ssh_repos=false
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        read -r url dest <<< "$line"
        if is_ssh_url "$url"; then
            has_ssh_repos=true
            break
        fi
    done < "$REPOS_FILE"
    
    if [ "$has_ssh_repos" = true ]; then
        if ! check_ssh_keys; then
            echo -e "${YELLOW}⚠ Advertencia: Detectados repositorios SSH pero no hay claves SSH${NC}"
            echo -e "${BLUE}Para clonar repositorios privados necesitas:${NC}"
            echo -e "  1. Configurar claves SSH: ./scripts/ssh-manager.sh"
            echo -e "  2. Agregar la clave pública a GitHub/GitLab"
            echo ""
            read -p "¿Deseas continuar de todos modos? [y/N]: " continue_anyway
            [[ ! "$continue_anyway" =~ ^[Yy]$ ]] && return 1
            echo ""
        fi
    fi
    
    local total=0
    local success=0
    local failed=0
    local skipped=0
    
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        read -r url dest <<< "$line"
        local repo_name=$(basename "$url" .git)
        local target_dir="${dest:-$DEFAULT_REPOS_DIR/$repo_name}"
        ((total++))
        
        if [ -d "$target_dir/.git" ]; then
            echo -e "${BLUE}⊙${NC} $repo_name ya existe, omitiendo..."
            ((skipped++))
        else
            echo -e "${YELLOW}→${NC} Clonando $repo_name..."
            
            # Determinar si es privado
            local repo_type="público"
            if is_ssh_url "$url"; then
                repo_type="privado (SSH)"
            fi
            echo -e "   ${BLUE}Tipo:${NC} $repo_type"
            echo -e "   ${BLUE}URL:${NC} $url"
            
            mkdir -p "$(dirname "$target_dir")"
            
            if git clone "$url" "$target_dir" 2>&1; then
                echo -e "${GREEN}✓${NC} $repo_name clonado exitosamente"
                ((success++))
            else
                echo -e "${RED}✗${NC} Error al clonar $repo_name"
                
                # Diagnóstico de error
                if is_ssh_url "$url"; then
                    echo -e "${YELLOW}   Posibles causas:${NC}"
                    echo -e "   • No tienes acceso al repositorio"
                    echo -e "   • Tu clave SSH no está agregada a GitHub/GitLab"
                    echo -e "   • La clave SSH no está cargada en ssh-agent"
                    echo -e "${BLUE}   Solución:${NC}"
                    echo -e "   ./scripts/ssh-manager.sh  # Opción 6: Configurar ssh-agent"
                else
                    echo -e "${YELLOW}   Posibles causas:${NC}"
                    echo -e "   • Repositorio privado (usa SSH: git@github.com:usuario/repo.git)"
                    echo -e "   • URL incorrecta"
                    echo -e "   • Sin conexión a internet"
                fi
                ((failed++))
            fi
        fi
        echo ""
    done < "$REPOS_FILE"
    
    # Resumen
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${BLUE}Total:${NC} $total | ${GREEN}Clonados:${NC} $success | ${RED}Fallidos:${NC} $failed | ${BLUE}Omitidos:${NC} $skipped"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    
    if [ $failed -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Revisa los errores arriba para más detalles${NC}"
    fi
}

# Actualizar todos los repositorios
update_all() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     ACTUALIZANDO REPOSITORIOS${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local total=0
    local updated=0
    local skipped=0
    local failed=0
    
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        read -r url dest <<< "$line"
        local repo_name=$(basename "$url" .git)
        local target_dir="${dest:-$DEFAULT_REPOS_DIR/$repo_name}"
        ((total++))
        
        if [ ! -d "$target_dir/.git" ]; then
            echo -e "${RED}✗${NC} $repo_name no está clonado"
            ((skipped++))
            continue
        fi
        
        echo -e "${YELLOW}→${NC} Actualizando $repo_name..."
        cd "$target_dir"
        
        # Verificar cambios sin commit
        if [ -n "$(git status --porcelain)" ]; then
            local changes=$(git status --short | wc -l)
            echo -e "${YELLOW}⚠${NC} $repo_name tiene $changes cambios sin commit"
            echo -e "   ${BLUE}Usa:${NC} git stash (guardar cambios temporalmente)"
            ((skipped++))
            echo ""
            continue
        fi
        
        # Verificar branch actual
        local branch=$(git branch --show-current)
        
        # Pull
        if git pull --ff-only 2>&1; then
            echo -e "${GREEN}✓${NC} $repo_name actualizado (branch: $branch)"
            ((updated++))
        else
            echo -e "${RED}✗${NC} Error al actualizar $repo_name"
            echo -e "${YELLOW}   Posibles causas:${NC}"
            echo -e "   • Conflictos entre local y remoto"
            echo -e "   • Falta autenticación (para repos privados)"
            echo -e "   • Branch desincronizado"
            ((failed++))
        fi
        echo ""
    done < "$REPOS_FILE"
    
    # Resumen
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${BLUE}Total:${NC} $total | ${GREEN}Actualizados:${NC} $updated | ${YELLOW}Omitidos:${NC} $skipped | ${RED}Fallidos:${NC} $failed"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
}

# Estado de todos los repos
status_all() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     ESTADO DE REPOSITORIOS${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        read -r url dest <<< "$line"
        local repo_name=$(basename "$url" .git)
        local target_dir="${dest:-$DEFAULT_REPOS_DIR/$repo_name}"
        
        if [ ! -d "$target_dir/.git" ]; then
            echo -e "${RED}✗${NC} ${YELLOW}$repo_name${NC} - No clonado"
            continue
        fi
        
        cd "$target_dir"
        local branch=$(git branch --show-current)
        local status=$(git status --short)
        
        echo -e "${BLUE}▸${NC} ${YELLOW}$repo_name${NC} (branch: $branch)"
        
        if [ -z "$status" ]; then
            echo -e "  ${GREEN}✓ Limpio${NC}"
        else
            echo -e "  ${RED}Cambios:${NC}"
            echo "$status" | sed 's/^/    /'
        fi
        echo ""
    done < "$REPOS_FILE"
}

# Menú principal
main() {
    init_repos_file
    
    clear
    echo -e "${RED}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║              REPOSITORY MANAGER                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${GREEN}1)${NC} Listar repositorios configurados"
    echo -e "${GREEN}2)${NC} Clonar todos los repositorios"
    echo -e "${GREEN}3)${NC} Actualizar todos los repositorios"
    echo -e "${GREEN}4)${NC} Ver estado de todos los repositorios"
    echo -e "${GREEN}5)${NC} Editar lista de repositorios"
    echo -e "${GREEN}6)${NC} Verificar configuración SSH"
    echo -e "${GREEN}7)${NC} Convertir URLs a SSH (para repos privados)"
    echo -e "${GREEN}0)${NC} Salir"
    echo ""
    read -p "Selecciona una opción: " option
    
    case $option in
        1) list_repos ;;
        2) clone_all ;;
        3) update_all ;;
        4) status_all ;;
        5) ${EDITOR:-nano} "$REPOS_FILE" ;;
        6) verify_ssh_config ;;
        7) convert_to_ssh ;;
        0) exit 0 ;;
        *) echo -e "${RED}Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
    main
}

main
