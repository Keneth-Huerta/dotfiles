# Dotfiles - Sistema de Configuración Automática

Sistema modular de dotfiles para Arch Linux con Hyprland, diseñado para restaurar tu entorno completo en cualquier máquina con un solo comando.

## Características

 **Tema moderno** con colores rojos predominantes
 **Instalación modular** - instala solo lo que necesitas
-  **Configuración completa** de Hyprland + Waybar
-  **Gestión de paquetes** - Pacman, AUR y Flatpak
-  **Modo rápido** para instalación parcial (ideal para escuela/trabajo)
-  **Sistema de backup** para tus configuraciones actuales
-  **Symlinks automáticos** para fácil sincronización

## Requisitos

- Arch Linux (o derivados como Manjaro, EndeavourOS)
- Conexión a internet activa
- Git instalado: `sudo pacman -S git`
- Usuario con permisos sudo

## Instalación Rápida

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Hacer ejecutable el instalador
chmod +x install.sh

# 3. (Opcional) Editar configuración personal
nano config.sh

# 4. Ejecutar el instalador
./install.sh
```

## Estructura del Proyecto

```
dotfiles/
├── install.sh                  # Script principal con menú interactivo
├── config.sh                   # Configuración personalizable
├── README.md                   # Este archivo
├── .gitignore                  # Archivos ignorados por git
│
├── config/                     # Configuraciones de aplicaciones
│   ├── hypr/                  # Hyprland (compositor Wayland)
│   ├── waybar/                # Barra de estado
│   ├── kitty/                 # Terminal emulator
│   ├── fish/                  # Fish shell
│   ├── zsh/                   # Zsh shell (.zshrc, .zshenv)
│   ├── nvim/                  # Neovim configuración
│   ├── rofi/                  # Application launcher
│   ├── dunst/                 # Gestor de notificaciones
│   ├── starship/              # Prompt personalizado
│   ├── git/                   # Configuración Git
│   ├── tmux/                  # Terminal multiplexor
│   ├── btop/                  # Monitor de sistema
│   ├── fastfetch/             # Info del sistema
│   └── cava/                  # Visualizador de audio
│
├── scripts/                    # Scripts de instalación modulares
│   ├── install-packages.sh    # Instalación de paquetes
│   ├── install-gui.sh         # Entorno gráfico (Hyprland + SDDM)
│   ├── install-cli-tools.sh   # Herramientas CLI
│   ├── link-configs.sh        # Enlazar configuraciones con symlinks
│   └── backup-configs.sh      # Backup de configuraciones actuales
│
├── packages/                   # Listas de paquetes instalados
│   ├── pacman-explicit.txt    # Paquetes oficiales
│   ├── aur.txt                # Paquetes de AUR
│   └── flatpak.txt            # Aplicaciones Flatpak
│
└── user-scripts/               # Scripts personalizados del usuario
```

## Modos de Uso

### Instalación Completa
**Ideal para:** Nueva instalación de Arch Linux

```bash
./install.sh
# Seleccionar opción 1: "Instalación completa"
```

**Incluye:** Sistema completo con GUI, todas las apps y configuraciones

---

### Instalación Rápida (Modo Portátil)
**Ideal para:** Escuela, trabajo, computadoras temporales

```bash
./install.sh
# Seleccionar opción 8: "Configuración rápida"
```

**Instala solo:** vim, neovim, zsh, fish, starship, fzf, ripgrep, git, htop, tmux

**Tiempo:** 5-10 minutos

---

### Instalación Modular
Instala solo componentes específicos:

- **Opción 2:** Solo paquetes
- **Opción 3:** Solo entorno gráfico (Hyprland)
- **Opción 4:** Solo herramientas CLI
- **Opción 5:** Solo enlazar configuraciones
- **Opción 6:** Solo hacer backup

---

### Hacer Backup
Guarda tu configuración actual **antes** de instalar:

```bash
./install.sh
# Seleccionar opción 6: "Hacer backup"
```

**Guarda:**
- Todas las configs de `~/.config/`
- Archivos de shell (`.zshrc`, etc.)
- Lista de paquetes instalados

## Configuración Personalizada

Edita `config.sh` antes de instalar con tu información:

```bash
# Información personal
USER_NAME="kenethissac"
USER_EMAIL="hugk070821@gmail.com"

# Shell predeterminada (fish, zsh, bash)
DEFAULT_SHELL="fish"

# Editor predeterminado
DEFAULT_EDITOR="nvim"

# Temas (colores rojos predominantes)
GTK_THEME="Catppuccin-Mocha-Standard-Red-Dark"
ICON_THEME="Papirus-Dark"
CURSOR_THEME="Bibata-Modern-Classic"

# Opciones de Hyprland
HYPRLAND_BORDER_COLOR="rgb(dc143c)"  # Rojo carmesí
```

## Paquetes Incluidos

### Sistema y Desarrollo
- Base: `base-devel`, `git`, `wget`, `curl`
- Lenguajes: `nodejs`, `python`, `go`, `rust`
- Contenedores: `docker`, `docker-compose`

### Hyprland y Wayland
- Core: `hyprland`, `waybar`, `rofi-wayland`
- Wallpapers: `swaybg`
- Lock: `swaylock-effects`, `swayidle`
- Clipboard: `wl-clipboard`, `cliphist`
- Notificaciones: `dunst`
- Screenshots: `grim`, `slurp`

### Terminal y Shell
- Terminales: `kitty`, `alacritty`
- Shells: `fish`, `zsh` + plugins
- Prompts: `starship`, `oh-my-posh`
- Multiplexor: `tmux`

### Editores
- `neovim`, `vim`, `visual-studio-code-bin`

### Utilidades CLI
- Monitores: `htop`, `btop`
- Info: `fastfetch`, `neofetch`
- Búsqueda: `fzf`, `ripgrep`, `fd`
- Visualización: `bat`, `exa`, `tree`
- File managers: `ranger`, `nnn`
- Git: `git`, `git-delta`, `lazygit`

### Navegadores
- `firefox`, `chromium`, `brave-bin`

### Temas y Fuentes
- GTK: `catppuccin-gtk-theme-mocha`
- Iconos: `papirus-icon-theme`
- Fuentes: `ttf-jetbrains-mono-nerd`, `ttf-font-awesome`

## Flujo de Trabajo

### Primera vez (Nueva instalación de Arch)

```bash
# 1. Instalar Arch Linux base
# 2. Conectar a internet
sudo systemctl start NetworkManager
nmtui

# 3. Instalar git
sudo pacman -S git

# 4. Clonar dotfiles
git clone https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 5. Editar configuración
nano config.sh

# 6. Instalación completa
./install.sh
# Opción 1

# 7. Reiniciar
sudo reboot
```

### Actualizar configuraciones

```bash
cd ~/dotfiles

# 1. Hacer backup primero
./install.sh  # Opción 6

# 2. Pull cambios
git pull

# 3. Re-enlazar
./install.sh  # Opción 5
```

### Sincronizar a GitHub

```bash
cd ~/dotfiles

# 1. Backup
./install.sh  # Opción 6

# 2. Commit
git add .
git commit -m "Update configs - $(date +%Y-%m-%d)"

# 3. Push
git push origin main
```

## Tema y Estilo

**Tema moderno con colores rojos predominantes:**

- Tema GTK: Catppuccin Mocha Red Dark
- Iconos: Papirus Dark (rojos)
- Fuente: JetBrains Mono Nerd Font
- Cursor: Bibata Modern Classic
- Colores Hyprland: Bordes rojos (`#dc143c`)

## Solución de Problemas

### No hay internet
```bash
sudo systemctl start NetworkManager
nmtui
```

### yay no está instalado
El script lo instala automáticamente.

### Configuraciones no se aplican
```bash
cd ~/dotfiles
./scripts/link-configs.sh
```

### Restaurar backup
```bash
mv ~/.config/hypr.bak ~/.config/hypr
```

## Notas

1.  Edita `config.sh` antes del primer uso
2.  Backups automáticos con extensión `.bak`
3.  Las configs se enlazan (symlinks), no se copian
4.  Datos sensibles: añádelos a `.gitignore`

##  Autor

**Keneth Isaac Huerta Galindo**
- GitHub: [@Keneth-Huerta](https://github.com/Keneth-Huerta)
- Email: kenethissac@gmail.com

---

**¡Dale una estrella si te gusta este proyecto!**

**Tip:** Puedes forkear y adaptar a tus necesidades.
