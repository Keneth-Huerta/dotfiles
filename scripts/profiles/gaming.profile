# PERFIL GAMING - Optimizado para juegos
# Hyprland + Steam + Lutris + Wine + drivers

PROFILE_NAME="Gaming"
PROFILE_DESC="Sistema optimizado para gaming"

# Paquetes core
INSTALL_HYPRLAND=true
INSTALL_GDM=true
INSTALL_WAYBAR=true
INSTALL_KITTY=true
INSTALL_ZSH=true

# Extras
INSTALL_IDES=false
INSTALL_VIRTUALIZATION=false
INSTALL_GAMING=true
INSTALL_PENTESTING=false
INSTALL_MULTIMEDIA=true
INSTALL_DEV_TOOLS=false

# Opciones
ENABLE_MULTILIB=true
ENABLE_BLACKARCH=false

# Paquetes específicos del perfil
PROFILE_PACKAGES=(
    "steam"
    "lutris"
    "wine"
    "wine-mono"
    "wine-gecko"
    "winetricks"
    "gamemode"
    "lib32-gamemode"
    "mangohud"
    "lib32-mangohud"
    "discord"
)
