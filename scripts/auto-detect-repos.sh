#!/usr/bin/env bash

# ============================================================================
# AUTO-DETECT REPOSITORIES
# Detecta automáticamente repositorios Git existentes y genera repos.list
# ============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOS_FILE="$DOTFILES_DIR/repos.list"
REPOS_DIRS=(
    "$HOME/Documents/repos"
    "$HOME/repos"
    "$HOME/projects"
    "$HOME/dev"
    "$HOME/code"
)

echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     AUTO-DETECCIÓN DE REPOSITORIOS GIT${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Array para almacenar repos encontrados
declare -a found_repos

# Buscar repositorios
echo -e "${BLUE}Buscando repositorios Git...${NC}"
echo ""

for base_dir in "${REPOS_DIRS[@]}"; do
    if [ ! -d "$base_dir" ]; then
        continue
    fi
    
    echo -e "${YELLOW}→ Escaneando: $base_dir${NC}"
    
    # Buscar directorios con .git
    while IFS= read -r -d '' git_dir; do
        repo_path=$(dirname "$git_dir")
        repo_name=$(basename "$repo_path")
        
        # Obtener URL del remote
        cd "$repo_path"
        remote_url=$(git remote get-url origin 2>/dev/null)
        
        if [ -n "$remote_url" ]; then
            found_repos+=("$remote_url|$repo_path")
            echo -e "  ${GREEN}✓${NC} $repo_name"
            echo -e "    ${BLUE}URL:${NC} $remote_url"
            echo -e "    ${BLUE}Path:${NC} $repo_path"
        else
            echo -e "  ${YELLOW}⚠${NC} $repo_name (sin remote origin)"
        fi
        
    done < <(find "$base_dir" -maxdepth 2 -type d -name ".git" -print0 2>/dev/null)
done

echo ""

if [ ${#found_repos[@]} -eq 0 ]; then
    echo -e "${YELLOW}No se encontraron repositorios Git${NC}"
    echo -e "${BLUE}¿Deseas crear repos.list manualmente?${NC}"
    exit 0
fi

echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${GREEN}Se encontraron ${#found_repos[@]} repositorios${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""

# Preguntar si generar repos.list
if [ -f "$REPOS_FILE" ]; then
    echo -e "${YELLOW}⚠ El archivo repos.list ya existe${NC}"
    read -p "¿Deseas sobrescribirlo? [y/N]: " overwrite
    
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Se creará un backup en repos.list.backup${NC}"
        cp "$REPOS_FILE" "$REPOS_FILE.backup"
    fi
fi

# Generar repos.list
cat > "$REPOS_FILE" << 'EOF'
# ============================================================================
# LISTA DE REPOSITORIOS GIT - Auto-generado
# ============================================================================
# Este archivo fue generado automáticamente por auto-detect-repos.sh
#
# Formato:
#   URL_DEL_REPO [DIRECTORIO_DESTINO]
#
# Si no especificas directorio, se clonará en ~/Documents/repos/nombre-repo
#
# Nota: Los directorios personalizados se mantienen de tus repos existentes
# ============================================================================

EOF

# Agregar repositorios encontrados
for entry in "${found_repos[@]}"; do
    IFS='|' read -r url path <<< "$entry"
    
    # Si el path es diferente del default, agregarlo
    repo_name=$(basename "$url" .git)
    default_path="$HOME/Documents/repos/$repo_name"
    
    if [ "$path" = "$default_path" ]; then
        # Path por defecto, solo URL
        echo "$url" >> "$REPOS_FILE"
    else
        # Path personalizado
        echo "$url $path" >> "$REPOS_FILE"
    fi
done

echo ""
echo -e "${GREEN}✓ Archivo repos.list generado${NC}"
echo -e "${BLUE}Ubicación:${NC} $REPOS_FILE"
echo ""
echo -e "${CYAN}Contenido:${NC}"
cat "$REPOS_FILE"
echo ""

# Mostrar comandos útiles
echo -e "${YELLOW}Comandos útiles:${NC}"
echo -e "  ${BLUE}Editar:${NC}           nano $REPOS_FILE"
echo -e "  ${BLUE}Ver repos:${NC}        ./scripts/repo-manager.sh  # Opción 1"
echo -e "  ${BLUE}Clonar todos:${NC}     ./scripts/repo-manager.sh  # Opción 2"
echo -e "  ${BLUE}Actualizar todos:${NC} ./scripts/repo-manager.sh  # Opción 3"
echo ""

# Preguntar si abrir repo-manager
read -p "¿Deseas abrir el gestor de repositorios ahora? [Y/n]: " open_manager

if [[ ! "$open_manager" =~ ^[Nn]$ ]]; then
    exec bash "$DOTFILES_DIR/scripts/repo-manager.sh"
fi
