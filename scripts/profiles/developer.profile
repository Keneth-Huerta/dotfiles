# PERFIL DEVELOPER - Herramientas de desarrollo
# Hyprland + IDEs + Docker + Git + Dev Tools

PROFILE_NAME="Developer"
PROFILE_DESC="Herramientas completas de desarrollo"

# Paquetes core
INSTALL_HYPRLAND=true
INSTALL_GDM=true
INSTALL_WAYBAR=true
INSTALL_KITTY=true
INSTALL_ZSH=true

# Extras
INSTALL_IDES=true
INSTALL_VIRTUALIZATION=true
INSTALL_GAMING=false
INSTALL_PENTESTING=false
INSTALL_MULTIMEDIA=false
INSTALL_DEV_TOOLS=true

# Opciones
ENABLE_MULTILIB=false
ENABLE_BLACKARCH=false

# Paquetes específicos del perfil
PROFILE_PACKAGES=(
    "docker"
    "docker-compose"
    "virtualbox"
    "code"
    "git"
    "github-cli"
    "nodejs"
    "npm"
    "python"
    "python-pip"
    "rust"
    "go"
    "jdk-openjdk"
    "maven"
    "gradle"
)
