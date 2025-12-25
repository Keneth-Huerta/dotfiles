#!/usr/bin/env bash
# ============================================================================
# HARDWARE DETECTION - Detección automática de hardware
# ============================================================================

detect_hardware() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     DETECCIÓN DE HARDWARE${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # GPU Detection
    echo -e "${BLUE}Detectando GPU...${NC}"
    GPU_VENDOR=""
    GPU_MODEL=""
    
    if lspci | grep -i vga | grep -iq intel; then
        GPU_VENDOR="Intel"
        GPU_MODEL=$(lspci | grep -i vga | grep -i intel | sed 's/.*: //')
        echo -e "  ${GREEN}✓${NC} GPU Intel detectada: $GPU_MODEL"
        RECOMMEND_PACKAGES+=("vulkan-intel" "intel-media-driver" "libva-intel-driver")
    fi
    
    if lspci | grep -i vga | grep -iq nvidia; then
        GPU_VENDOR="NVIDIA"
        GPU_MODEL=$(lspci | grep -i vga | grep -i nvidia | sed 's/.*: //')
        echo -e "  ${GREEN}✓${NC} GPU NVIDIA detectada: $GPU_MODEL"
        RECOMMEND_PACKAGES+=("nvidia" "nvidia-utils" "nvidia-settings")
    fi
    
    if lspci | grep -i vga | grep -iq amd; then
        GPU_VENDOR="AMD"
        GPU_MODEL=$(lspci | grep -i vga | grep -i amd | sed 's/.*: //')
        echo -e "  ${GREEN}✓${NC} GPU AMD detectada: $GPU_MODEL"
        RECOMMEND_PACKAGES+=("vulkan-radeon" "libva-mesa-driver" "mesa-vdpau")
    fi
    
    # CPU Detection
    echo ""
    echo -e "${BLUE}Detectando CPU...${NC}"
    CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
    CPU_MODEL=$(lscpu | grep "Model name" | sed 's/Model name: *//')
    echo -e "  ${GREEN}✓${NC} CPU: $CPU_MODEL"
    
    # Laptop Detection
    echo ""
    echo -e "${BLUE}Detectando tipo de sistema...${NC}"
    IS_LAPTOP=false
    if [ -d /sys/class/power_supply/BAT* ] || [ -d /sys/class/power_supply/battery ]; then
        IS_LAPTOP=true
        echo -e "  ${GREEN}✓${NC} Laptop detectado"
        RECOMMEND_PACKAGES+=("tlp" "tlp-rdw" "powertop")
        RECOMMEND_SERVICES+=("tlp")
    else
        echo -e "  ${GREEN}✓${NC} PC de escritorio"
    fi
    
    # Bluetooth Detection
    echo ""
    echo -e "${BLUE}Detectando Bluetooth...${NC}"
    if lsusb | grep -iq bluetooth || lspci | grep -iq bluetooth; then
        echo -e "  ${GREEN}✓${NC} Bluetooth disponible"
        RECOMMEND_PACKAGES+=("bluez" "bluez-utils" "blueman")
        RECOMMEND_SERVICES+=("bluetooth")
    else
        echo -e "  ${YELLOW}⚠${NC} Bluetooth no detectado"
    fi
    
    # Wifi Detection
    echo ""
    echo -e "${BLUE}Detectando WiFi...${NC}"
    if ip link | grep -q wlan || ip link | grep -q wlp; then
        WIFI_DEVICE=$(ip link | grep -o 'wl[a-z0-9]*' | head -n1)
        echo -e "  ${GREEN}✓${NC} WiFi disponible: $WIFI_DEVICE"
        RECOMMEND_PACKAGES+=("networkmanager" "nm-connection-editor")
        RECOMMEND_SERVICES+=("NetworkManager")
    else
        echo -e "  ${YELLOW}⚠${NC} WiFi no detectado"
    fi
    
    # Touchpad Detection
    echo ""
    echo -e "${BLUE}Detectando Touchpad...${NC}"
    if grep -iq touchpad /proc/bus/input/devices; then
        echo -e "  ${GREEN}✓${NC} Touchpad disponible"
        RECOMMEND_PACKAGES+=("libinput" "xf86-input-libinput")
    else
        echo -e "  ${YELLOW}⚠${NC} Touchpad no detectado"
    fi
    
    # Audio Detection
    echo ""
    echo -e "${BLUE}Detectando Audio...${NC}"
    if lspci | grep -iq audio; then
        AUDIO_DEVICE=$(lspci | grep -i audio | sed 's/.*: //' | head -n1)
        echo -e "  ${GREEN}✓${NC} Audio: $AUDIO_DEVICE"
        RECOMMEND_PACKAGES+=("pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "pavucontrol")
    fi
    
    # Summary
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Recomendaciones basadas en tu hardware:${NC}"
    echo ""
    
    if [ ${#RECOMMEND_PACKAGES[@]} -gt 0 ]; then
        echo -e "${BLUE}Paquetes recomendados:${NC}"
        for pkg in "${RECOMMEND_PACKAGES[@]}"; do
            if ! pacman -Q "$pkg" &> /dev/null; then
                echo -e "  ${YELLOW}→${NC} $pkg"
            fi
        done
    fi
    
    echo ""
    if [ ${#RECOMMEND_SERVICES[@]} -gt 0 ]; then
        echo -e "${BLUE}Servicios recomendados:${NC}"
        for svc in "${RECOMMEND_SERVICES[@]}"; do
            if ! systemctl is-enabled "$svc" &> /dev/null 2>&1; then
                echo -e "  ${YELLOW}→${NC} Habilitar $svc"
            fi
        done
    fi
    
    echo ""
    echo -e "${GREEN}Detección completada.${NC}"
    echo ""
}

# Arrays globales
RECOMMEND_PACKAGES=()
RECOMMEND_SERVICES=()
