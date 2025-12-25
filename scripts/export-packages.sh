#!/usr/bin/env bash

# Script para exportar todos los paquetes instalados en el sistema
# Autor: Keneth Isaac Huerta Galindo

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$DOTFILES_DIR/packages"

# Crear directorio si no existe
mkdir -p "$PACKAGES_DIR"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   EXPORTANDO PAQUETES INSTALADOS       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# 1. Exportar paquetes pacman explícitamente instalados (con filtrado)
echo -e "${YELLOW}Exportando paquetes pacman (explícitos)...${NC}"

# Lista de paquetes a excluir (solo GNOME, KDE, terminales/gestores de archivos extras)
# NO se filtran herramientas de pentesting ni blackarch
EXCLUDE_PATTERN="^(gnome-|plasma-|kde-cli-tools|konsole|xterm|dolphin|thunar|qemu-base|virt-manager)$"

# Exportar sin filtro primero (backup)
pacman -Qqe > "$PACKAGES_DIR/pacman-explicit-full.txt"

# Exportar con filtro (archivo principal)
pacman -Qqe | grep -vE "$EXCLUDE_PATTERN" > "$PACKAGES_DIR/pacman-explicit.txt"

COUNT_FULL=$(wc -l < "$PACKAGES_DIR/pacman-explicit-full.txt")
COUNT_FILTERED=$(wc -l < "$PACKAGES_DIR/pacman-explicit.txt")
COUNT_EXCLUDED=$((COUNT_FULL - COUNT_FILTERED))

echo -e "${GREEN}✓ $COUNT_FILTERED paquetes exportados${NC}"
echo -e "${BLUE}  ($COUNT_EXCLUDED paquetes filtrados automáticamente)${NC}"

# 2. Exportar todos los paquetes nativos
echo -e "${YELLOW}Exportando paquetes pacman (nativos)...${NC}"
pacman -Qqn > "$PACKAGES_DIR/pacman-native.txt"
COUNT=$(wc -l < "$PACKAGES_DIR/pacman-native.txt")
echo -e "${GREEN}✓ $COUNT paquetes nativos exportados${NC}"

# 3. Exportar paquetes AUR
echo -e "${YELLOW}Exportando paquetes AUR...${NC}"
pacman -Qqm > "$PACKAGES_DIR/aur.txt"
COUNT=$(wc -l < "$PACKAGES_DIR/aur.txt")
echo -e "${GREEN}✓ $COUNT paquetes AUR exportados${NC}"

# 4. Exportar paquetes flatpak
if command -v flatpak &> /dev/null; then
    echo -e "${YELLOW}Exportando paquetes flatpak...${NC}"
    flatpak list --app --columns=application > "$PACKAGES_DIR/flatpak.txt" 2>/dev/null || echo "" > "$PACKAGES_DIR/flatpak.txt"
    COUNT=$(wc -l < "$PACKAGES_DIR/flatpak.txt")
    echo -e "${GREEN}✓ $COUNT paquetes flatpak exportados${NC}"
else
    echo -e "${YELLOW}⊘ Flatpak no está instalado${NC}"
    echo "" > "$PACKAGES_DIR/flatpak.txt"
fi

# 5. Exportar paquetes snap
if command -v snap &> /dev/null; then
    echo -e "${YELLOW}Exportando paquetes snap...${NC}"
    snap list | tail -n +2 | awk '{print $1}' > "$PACKAGES_DIR/snap.txt" 2>/dev/null || echo "" > "$PACKAGES_DIR/snap.txt"
    COUNT=$(wc -l < "$PACKAGES_DIR/snap.txt")
    echo -e "${GREEN}✓ $COUNT paquetes snap exportados${NC}"
else
    echo -e "${YELLOW}⊘ Snap no está instalado${NC}"
    echo "" > "$PACKAGES_DIR/snap.txt"
fi

# 6. Exportar paquetes npm globales
if command -v npm &> /dev/null; then
    echo -e "${YELLOW}Exportando paquetes npm globales...${NC}"
    npm list -g --depth=0 2>/dev/null | tail -n +2 | awk '{print $2}' | sed 's/@.*//' > "$PACKAGES_DIR/npm-global.txt" || echo "" > "$PACKAGES_DIR/npm-global.txt"
    COUNT=$(wc -l < "$PACKAGES_DIR/npm-global.txt")
    echo -e "${GREEN}✓ $COUNT paquetes npm globales exportados${NC}"
else
    echo -e "${YELLOW}⊘ npm no está instalado${NC}"
    echo "" > "$PACKAGES_DIR/npm-global.txt"
fi

# 7. Exportar paquetes pip globales
if command -v pip &> /dev/null; then
    echo -e "${YELLOW}Exportando paquetes pip globales...${NC}"
    pip list --format=freeze 2>/dev/null > "$PACKAGES_DIR/pip-global.txt" || echo "" > "$PACKAGES_DIR/pip-global.txt"
    COUNT=$(wc -l < "$PACKAGES_DIR/pip-global.txt")
    echo -e "${GREEN}✓ $COUNT paquetes pip globales exportados${NC}"
else
    echo -e "${YELLOW}⊘ pip no está instalado${NC}"
    echo "" > "$PACKAGES_DIR/pip-global.txt"
fi

# 8. Crear resumen
echo -e "${YELLOW}Creando resumen...${NC}"
cat > "$PACKAGES_DIR/RESUMEN.md" << EOF
# Resumen de Paquetes Instalados

**Fecha de exportación:** $(date +"%Y-%m-%d %H:%M:%S")
**Sistema:** $(uname -n) - $(uname -r)

## Estadísticas

| Tipo | Cantidad | Archivo |
|------|----------|---------|
| Pacman (explícitos) | $(wc -l < "$PACKAGES_DIR/pacman-explicit.txt") | pacman-explicit.txt |
| Pacman (explícitos - completo con backup) | $(wc -l < "$PACKAGES_DIR/pacman-explicit-full.txt") | pacman-explicit-full.txt |
| Pacman (nativos) | $(wc -l < "$PACKAGES_DIR/pacman-native.txt") | pacman-native.txt |
| AUR | $(wc -l < "$PACKAGES_DIR/aur.txt") | aur.txt |
| Flatpak | $(wc -l < "$PACKAGES_DIR/flatpak.txt") | flatpak.txt |
| Snap | $(wc -l < "$PACKAGES_DIR/snap.txt") | snap.txt |
| npm (global) | $(wc -l < "$PACKAGES_DIR/npm-global.txt") | npm-global.txt |
| pip (global) | $(wc -l < "$PACKAGES_DIR/pip-global.txt") | pip-global.txt |

## ℹ️ Filtrado Automático

**Paquetes excluidos automáticamente:** $COUNT_EXCLUDED

Los siguientes tipos de paquetes se filtran automáticamente al exportar:
- ❌ GNOME (gnome-*)
- ❌ KDE/Plasma (plasma-*, kde-cli-tools, konsole, dolphin)
- ❌ Terminales extras (xterm)
- ❌ Gestores de archivos extras (dolphin, thunar)
- ❌ Virtualización extra (qemu-base, virt-manager)
- ✅ Herramientas de pentesting (se MANTIENEN)
- ✅ BlackArch keyring (se MANTIENE)

**Nota:** El archivo \`pacman-explicit-full.txt\` contiene TODOS los paquetes sin filtrar.

## Cómo restaurar

### Pacman (explícitos)
\`\`\`bash
sudo pacman -S --needed \$(cat pacman-explicit.txt)
\`\`\`

### AUR (con yay o paru)
\`\`\`bash
yay -S --needed \$(cat aur.txt)
# o
paru -S --needed \$(cat aur.txt)
\`\`\`

### Flatpak
\`\`\`bash
while read app; do flatpak install -y flathub "\$app"; done < flatpak.txt
\`\`\`

### Snap
\`\`\`bash
while read app; do sudo snap install "\$app"; done < snap.txt
\`\`\`

### npm global
\`\`\`bash
while read pkg; do npm install -g "\$pkg"; done < npm-global.txt
\`\`\`

### pip global
\`\`\`bash
pip install -r pip-global.txt
\`\`\`

---

*Generado automáticamente por export-packages.sh*
EOF

echo -e "${GREEN}✓ Resumen creado${NC}"

# Mostrar resumen final
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   EXPORTACIÓN COMPLETADA               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Archivos generados en: $PACKAGES_DIR${NC}"
echo ""
echo -e "  📄 pacman-explicit.txt  - $(wc -l < "$PACKAGES_DIR/pacman-explicit.txt") paquetes"
echo -e "  📄 pacman-native.txt    - $(wc -l < "$PACKAGES_DIR/pacman-native.txt") paquetes"
echo -e "  📄 aur.txt              - $(wc -l < "$PACKAGES_DIR/aur.txt") paquetes"
echo -e "  📄 flatpak.txt          - $(wc -l < "$PACKAGES_DIR/flatpak.txt") paquetes"
echo -e "  📄 snap.txt             - $(wc -l < "$PACKAGES_DIR/snap.txt") paquetes"
echo -e "  📄 npm-global.txt       - $(wc -l < "$PACKAGES_DIR/npm-global.txt") paquetes"
echo -e "  📄 pip-global.txt       - $(wc -l < "$PACKAGES_DIR/pip-global.txt") paquetes"
echo -e "  📄 RESUMEN.md           - Resumen y guía de restauración"
echo ""
echo -e "${YELLOW}Tip: Haz commit de estos archivos para tener backup de tus paquetes${NC}"
echo -e "${YELLOW}     cd $DOTFILES_DIR && git add packages/ && git commit -m 'Update packages list'${NC}"
