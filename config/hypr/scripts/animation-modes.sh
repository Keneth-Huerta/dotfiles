#!/bin/bash

#  Script para cambiar estilos de animación dinámicamente 

case "$1" in
    "vistoso")
        # Modo súper vistoso y dramático
        hyprctl keyword animation "windows,1,10,dramaticBounce,popin 20%"
        hyprctl keyword animation "windowsIn,1,12,explosive,popin 10%"
        hyprctl keyword animation "workspaces,1,12,redFlow,slidefade 15%"
        hyprctl keyword animation "workspacesIn,1,15,dramaticBounce,slide"
        hyprctl keyword animation "specialWorkspace,1,15,smoothBounce,slidevert"
        notify-send " Animaciones" "Modo ULTRA VISTOSO activado" --urgency=low
        ;;
    
    "elegante")
        # Modo elegante y suave
        hyprctl keyword animation "windows,1,8,redFlow,popin 60%"
        hyprctl keyword animation "windowsIn,1,8,smoothBounce,popin 50%"
        hyprctl keyword animation "workspaces,1,8,easeOutQuint,slidefade 25%"
        hyprctl keyword animation "workspacesIn,1,8,gentleOut,slide"
        hyprctl keyword animation "specialWorkspace,1,10,elastic,slidevert"
        notify-send " Animaciones" "Modo ELEGANTE activado" --urgency=low
        ;;
    
    "rapido")
        # Modo rápido para mejor rendimiento
        hyprctl keyword animation "windows,1,4,quick,popin 80%"
        hyprctl keyword animation "windowsIn,1,4,quick,popin 70%"
        hyprctl keyword animation "workspaces,1,5,linear,slide"
        hyprctl keyword animation "workspacesIn,1,5,almostLinear,slide"
        hyprctl keyword animation "specialWorkspace,1,6,quick,slidevert"
        notify-send " Animaciones" "Modo RÁPIDO activado" --urgency=low
        ;;
    
    "extremo")
        # Modo extremo con máximos efectos
        hyprctl keyword animation "windows,1,15,elasticOut,popin 5%"
        hyprctl keyword animation "windowsIn,1,18,explosive,popin 1%"
        hyprctl keyword animation "workspaces,1,15,dramaticBounce,slidefade 10%"
        hyprctl keyword animation "workspacesIn,1,20,smoothBounce,slide"
        hyprctl keyword animation "specialWorkspace,1,20,elasticOut,slidevert"
        notify-send " Animaciones" "Modo EXTREMO activado - ¡Prepárate!" --urgency=critical
        ;;
    
    "reset")
        # Restaurar configuración por defecto
        hyprctl keyword animation "windows,1,8,dramaticBounce,popin 40%"
        hyprctl keyword animation "windowsIn,1,10,explosive,popin 30%"
        hyprctl keyword animation "workspaces,1,10,redFlow,slidefade 20%"
        hyprctl keyword animation "workspacesIn,1,12,dramaticBounce,slide"
        hyprctl keyword animation "specialWorkspace,1,12,smoothBounce,slidevert"
        notify-send " Animaciones" "Configuración por defecto restaurada" --urgency=low
        ;;
    
    *)
        echo " Uso: $0 {vistoso|elegante|rapido|extremo|reset}"
        echo ""
        echo "  vistoso  - Efectos dramáticos y llamativos"
        echo "  elegante - Animaciones suaves y sofisticadas"
        echo "  rapido   - Animaciones rápidas para rendimiento"
        echo "  extremo  - Efectos máximos (¡CUIDADO!)"
        echo "  reset    - Restaurar configuración por defecto"
        ;;
esac
