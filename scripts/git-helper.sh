#!/usr/bin/env bash

# Script helper para gestión de Git
# Facilita commits y pushes del repositorio dotfiles

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$DOTFILES_DIR"

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   GESTIÓN DE GIT - DOTFILES           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Verificar si es un repo git
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Este directorio no es un repositorio Git${NC}"
    echo -e "${YELLOW}¿Deseas inicializarlo? (s/n)${NC}"
    read -r response
    
    if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
        git init
        echo -e "${GREEN}✓ Repositorio Git inicializado${NC}"
        
        echo -e "${YELLOW}Ingresa la URL del repositorio remoto (o Enter para saltar):${NC}"
        read -r repo_url
        
        if [ -n "$repo_url" ]; then
            git remote add origin "$repo_url"
            echo -e "${GREEN}✓ Remoto añadido${NC}"
        fi
    else
        exit 0
    fi
fi

# Mostrar estado
echo -e "${CYAN}Estado actual:${NC}"
git status -s
echo ""

# Menú
echo "1) Backup completo (exportar paquetes + configs + commit)"
echo "2) Solo commit y push"
echo "3) Ver cambios (git diff)"
echo "4) Ver log"
echo "5) Agregar remoto"
echo "0) Salir"
echo ""
read -p "Selecciona una opción: " option

case $option in
    1)
        # Backup completo
        echo -e "${YELLOW}Exportando paquetes...${NC}"
        bash "$DOTFILES_DIR/scripts/export-packages.sh"
        
        echo -e "${YELLOW}Haciendo backup de configs...${NC}"
        bash "$DOTFILES_DIR/scripts/backup-configs.sh"
        
        echo -e "${YELLOW}Añadiendo archivos...${NC}"
        git add .
        
        echo -e "${CYAN}Ingresa el mensaje del commit (o Enter para usar automático):${NC}"
        read -r commit_msg
        
        if [ -z "$commit_msg" ]; then
            commit_msg="Update dotfiles - $(date +%Y-%m-%d)"
        fi
        
        git commit -m "$commit_msg"
        echo -e "${GREEN}✓ Commit realizado${NC}"
        
        echo -e "${YELLOW}¿Hacer push? (s/n)${NC}"
        read -r push_response
        
        if [[ "$push_response" =~ ^([sS][iI]|[sS])$ ]]; then
            git push origin main || git push origin master
            echo -e "${GREEN}✓ Push realizado${NC}"
        fi
        ;;
    
    2)
        # Solo commit y push
        git add .
        
        echo -e "${CYAN}Mensaje del commit:${NC}"
        read -r commit_msg
        
        if [ -z "$commit_msg" ]; then
            commit_msg="Update - $(date +%Y-%m-%d)"
        fi
        
        git commit -m "$commit_msg"
        
        echo -e "${YELLOW}¿Hacer push? (s/n)${NC}"
        read -r push_response
        
        if [[ "$push_response" =~ ^([sS][iI]|[sS])$ ]]; then
            git push
            echo -e "${GREEN}✓ Push realizado${NC}"
        fi
        ;;
    
    3)
        # Ver cambios
        git diff
        ;;
    
    4)
        # Ver log
        git log --oneline --graph --all -10
        ;;
    
    5)
        # Agregar remoto
        echo -e "${CYAN}URL del repositorio remoto:${NC}"
        read -r repo_url
        
        git remote add origin "$repo_url" 2>/dev/null || git remote set-url origin "$repo_url"
        echo -e "${GREEN}✓ Remoto configurado${NC}"
        ;;
    
    0)
        exit 0
        ;;
esac

echo ""
echo -e "${GREEN}¡Listo!${NC}"
