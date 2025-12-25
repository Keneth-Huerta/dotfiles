# PERFIL DESKTOP - Sistema para uso diario
# Hyprland + navegador + multimedia + productividad

PROFILE_NAME="Desktop"
PROFILE_DESC="Uso diario con navegador y multimedia"

# Paquetes core
INSTALL_HYPRLAND=true
INSTALL_GDM=true
INSTALL_WAYBAR=true
INSTALL_KITTY=true
INSTALL_ZSH=true

# Extras
INSTALL_IDES=false
INSTALL_VIRTUALIZATION=false
INSTALL_GAMING=false
INSTALL_PENTESTING=false
INSTALL_MULTIMEDIA=true
INSTALL_DEV_TOOLS=false

# Opciones
ENABLE_MULTILIB=false
ENABLE_BLACKARCH=false

# Paquetes específicos del perfil
PROFILE_PACKAGES=(
    "firefox"
    "chromium"
    "nautilus"
    "vlc"
    "mpv"
    "libreoffice-fresh"
)
