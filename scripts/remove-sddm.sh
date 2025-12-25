#!/usr/bin/env bash

# Script para remover SDDM si no lo necesitas
# SDDM es el Display Manager (pantalla de login gráfica)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      DESINSTALACIÓN DE SDDM (Display Manager)    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}¿Qué es SDDM?${NC}"
echo "SDDM es la pantalla de login gráfica que aparece al iniciar el sistema."
echo ""
echo -e "${BLUE}¿Por qué removerlo?${NC}"
echo "Si usas Hyprland, NO necesitas SDDM. Puedes iniciar Hyprland directamente"
echo "desde la terminal ejecutando el comando 'Hyprland' después de hacer login."
echo ""
echo -e "${YELLOW}¿Estás seguro de que deseas remover SDDM?${NC}"
read -p "Escribe 'SI' para confirmar: " -r
echo

if [[ ! $REPLY == "SI" ]]; then
    echo -e "${GREEN}Operación cancelada${NC}"
    exit 0
fi

echo -e "${YELLOW}Deshabilitando SDDM...${NC}"
if sudo systemctl is-enabled sddm &> /dev/null; then
    sudo systemctl disable sddm
    echo -e "${GREEN}✓ SDDM deshabilitado${NC}"
else
    echo -e "${BLUE}[INFO] SDDM ya estaba deshabilitado${NC}"
fi

echo -e "${YELLOW}Deteniendo servicio SDDM...${NC}"
if sudo systemctl is-active sddm &> /dev/null; then
    sudo systemctl stop sddm
    echo -e "${GREEN}✓ Servicio detenido${NC}"
else
    echo -e "${BLUE}[INFO] Servicio ya estaba detenido${NC}"
fi

echo ""
echo -e "${YELLOW}¿Deseas desinstalar el paquete SDDM completamente?${NC}"
read -p "(s/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}Desinstalando SDDM...${NC}"
    sudo pacman -Rns sddm sddm-sugar-candy-git 2>/dev/null || sudo pacman -Rns sddm 2>/dev/null
    echo -e "${GREEN}✓ SDDM desinstalado${NC}"
else
    echo -e "${BLUE}[INFO] SDDM deshabilitado pero no desinstalado${NC}"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ¡Operación completada!               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Próximos pasos:${NC}"
echo "1. Reinicia tu sistema"
echo "2. Después del reinicio, verás la terminal de login (TTY)"
echo "3. Ingresa tu usuario y contraseña"
echo "4. Ejecuta: Hyprland"
echo ""
echo -e "${YELLOW}TIP: Para iniciar Hyprland automáticamente al hacer login:${NC}"
echo "Agrega esto a tu ~/.zprofile:"
echo ""
echo -e "${CYAN}if [ -z \"\$DISPLAY\" ] && [ \"\$XDG_VTNR\" -eq 1 ]; then"
echo "    exec Hyprland"
echo -e "fi${NC}"
echo ""
