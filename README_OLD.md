# 🚀 Dotfiles - Sistema de Configuración Automatizado

Sistema completo de dotfiles con instalador interactivo para Arch Linux. Permite restaurar todo tu entorno de trabajo en minutos en cualquier máquina nueva.

## 📋 Características

- **Instalación modular**: Escoge entre instalación completa o componentes específicos
- **Entorno gráfico completo**: Hyprland + Waybar + todas las configuraciones visuales
- **Herramientas CLI**: Neovim, Fish, Kitty, btop, y más
- **Gestión automática de paquetes**: Pacman + AUR + Flatpak
- **Backup automático**: Respalda configuraciones existentes antes de instalar
- **Sistema de logs**: Tracking completo de la instalación

## 🎯 Casos de Uso

### Instalación Completa (Casa/PC Principal)
```bash
./install.sh --full
```
Instala todo: entorno gráfico, aplicaciones, herramientas, configuraciones.

### Instalación Parcial (Escuela/Trabajo)
```bash
./install.sh --cli
```
Solo herramientas esenciales: Neovim, Fish, Kitty, Git, etc.

### Solo Configuraciones
```bash
./install.sh --configs-only
```
Aplica dotfiles sin instalar paquetes.

## 🚀 Inicio Rápido

### Instalación en Máquina Nueva (Arch Linux)

```bash
# 1. Conecta a internet
sudo systemctl start NetworkManager
nmtui

# 2. Instala Git
sudo pacman -S git

# 3. Clona el repositorio
git clone https://github.com/TU_USUARIO/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 4. Ejecuta el instalador
./install.sh
```

## 📦 Componentes Incluidos

### Entorno Gráfico (--gui)
- **Hyprland**: Compositor Wayland
- **Waybar**: Barra de estado moderna
- **Wofi**: Lanzador de aplicaciones
- **Swaylock**: Bloqueo de pantalla
- **Kitty**: Terminal moderna
- **Dolphin**: Gestor de archivos
- **Temas y cursores**: Apariencia completa

### Herramientas CLI (--cli)
- **Neovim**: Editor configurado con NvChad
- **Fish**: Shell moderna con autocompletado
- **Git**: Control de versiones + configuración
- **Btop**: Monitor de sistema
- **Fastfetch**: Información del sistema
- **Eza**: ls mejorado
- **Bat**: cat con sintaxis
- **Zoxide**: cd inteligente
- **Ripgrep**: búsqueda rápida

### Desarrollo (--dev)
- Docker + Docker Compose
- Python, Node.js, Go
- Android Studio
- VS Code / Neovim
- Herramientas de compilación

### Aplicaciones (--apps)
- Navegadores (Brave, Chromium)
- Bitwarden
- Notion
- Discord
- Spotify
- GIMP, Inkscape

## 📁 Estructura del Proyecto

```
dotfiles/
├── install.sh              # Script principal
├── scripts/                # Módulos de instalación
│   ├── packages.sh        # Instalación de paquetes
│   ├── gui.sh             # Entorno gráfico
│   ├── cli-tools.sh       # Herramientas CLI
│   ├── dev-tools.sh       # Herramientas de desarrollo
│   ├── configs.sh         # Aplicación de dotfiles
│   └── utils.sh           # Funciones auxiliares
├── config/                 # Configuraciones
│   ├── hypr/              # Hyprland
│   ├── waybar/            # Waybar
│   ├── kitty/             # Kitty
│   ├── nvim/              # Neovim
│   ├── fish/              # Fish shell
│   └── ...
├── packages/               # Listas de paquetes
│   ├── base.txt           # Paquetes base
│   ├── gui.txt            # GUI packages
│   ├── cli.txt            # CLI tools
│   ├── dev.txt            # Desarrollo
│   └── aur.txt            # AUR packages
└── backups/                # Backups automáticos
```

## 🎮 Modo Interactivo

El script presenta un menú interactivo con opciones:

```
╔══════════════════════════════════════════╗
║   🚀 INSTALADOR DE DOTFILES - ARCH      ║
╚══════════════════════════════════════════╝

Selecciona el tipo de instalación:

1) 🖥️  Instalación Completa (Todo)
2) 💻 Solo Entorno Gráfico (Hyprland + GUI)
3) ⌨️  Solo Herramientas CLI
4) 👨‍💻 Herramientas de Desarrollo
5) 📝 Solo Aplicar Configuraciones
6) 🎨 Personalizado (Escoger componentes)
7) ❌ Salir

Opción:
```

## ⚙️ Opciones de Línea de Comandos

```bash
./install.sh [OPCIÓN]

Opciones:
  --full            Instalación completa
  --gui             Solo entorno gráfico
  --cli             Solo herramientas CLI
  --dev             Solo herramientas de desarrollo
  --configs-only    Solo aplicar configuraciones
  --custom          Modo personalizado
  --help            Mostrar ayuda
  --dry-run         Simular instalación sin ejecutar
```

## 🔧 Personalización

### Agregar tus propios paquetes

Edita los archivos en `packages/`:
```bash
echo "mi-paquete" >> packages/base.txt
```

### Agregar configuraciones

Copia tus configs a `config/`:
```bash
cp -r ~/.config/mi-app config/
```

### Modificar scripts

Edita los scripts en `scripts/` según tus necesidades.

## 🛡️ Seguridad

- ✅ Backups automáticos de configuraciones existentes
- ✅ Confirmación antes de operaciones críticas
- ✅ Logs detallados de todas las operaciones
- ✅ Rollback en caso de errores

## 📝 Logs

Los logs se guardan en `~/.dotfiles-install.log`

```bash
# Ver logs
tail -f ~/.dotfiles-install.log

# Ver solo errores
grep ERROR ~/.dotfiles-install.log
```

## 🔄 Actualización

Para actualizar tus dotfiles:

```bash
cd ~/dotfiles
git pull
./install.sh --configs-only
```

## 🤝 Contribuir

Puedes adaptar este sistema a tus necesidades. Es tu configuración personal.

## 📄 Licencia

MIT - Usa como quieras

## 🎯 Ejemplos de Uso

### Primera instalación en PC nuevo
```bash
./install.sh --full
```

### Solo instalar en PC de escuela/trabajo
```bash
./install.sh --cli
# Instala: nvim, fish, git, herramientas básicas
```

### Actualizar solo configs después de cambios
```bash
./install.sh --configs-only
```

### Instalación personalizada
```bash
./install.sh --custom
# Muestra checklist de componentes
```

## ⚡ Tips

- Ejecuta `--dry-run` primero para ver qué se instalará
- Revisa los logs si algo falla
- Los backups están en `~/.config-backup-[fecha]`
- Puedes ejecutar el script múltiples veces de forma segura

## 🆘 Troubleshooting

### Error de permisos
```bash
chmod +x install.sh scripts/*.sh
```

### Fallo en AUR
```bash
# Instala yay manualmente
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

### Configuraciones no se aplican
```bash
# Verifica symlinks
ls -la ~/.config/
```

---

**Hecho con ❤️ para facilitar la vida en Arch Linux**
