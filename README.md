# Dotfiles - Arch Linux

Configuración personal para Arch Linux con Hyprland + ZSH + powerlevel10k. Incluye scripts de instalación, gestión de paquetes, symlinks, SSH y repos.

---

## Requisitos

- Arch Linux (instalación base)
- Git
- Conexión a internet

```bash
# Prerequisito: asegúrate de estar en el grupo wheel
su -c 'visudo'  # Descomenta: %wheel ALL=(ALL:ALL) ALL
```

---

## Instalación Rápida

```bash
# Clonar el repositorio
git clone https://github.com/Keneth-Huerta/dotfiles ~/Documents/repos/dotfiles
cd ~/Documents/repos/dotfiles

# Ejecutar el instalador
./install.sh
```

> **Nota**: El repo debe estar en `~/Documents/repos/dotfiles`. El instalador lo detecta automáticamente y te preguntará antes de moverlo si está en otra ubicación.

---

## Menú Principal

```
╔════════════════════════════════════╗
║         DOTFILES INSTALLER         ║
╚════════════════════════════════════╝

  INSTALACIÓN
  1)  Instalación completa (Todo)
  2)  Instalar paquetes (pacman + AUR + flatpak)
  3)  Entorno gráfico (Hyprland + Waybar)
  4)  Herramientas CLI (nvim, zsh, bat, eza...)
  5)  Configuración rápida (vim, zsh, starship)

  CONFIGURACIÓN
  6)  Enlazar configuraciones (crear symlinks)
  7)  Backup de configuraciones actuales
  8)  Actualizar configuraciones en el repo
  9)  Exportar lista de paquetes instalados

  GESTIÓN
  10) Inicializar dotfiles (copiar configs al repo)
  11) Gestionar repositorios
  12) Gestionar claves SSH
  13) Restaurar backup

  DIAGNÓSTICO
  14) Actualizar sistema
  15) Detectar hardware
  16) Verificar salud del sistema
  17) Verificar instalación
  18) Estado de enlaces simbólicos
  19) Auto-detectar repositorios existentes

  0)  Salir
```

---

## Estructura del Proyecto

```
dotfiles/
├── install.sh                  # Script principal (entrada única)
├── config.sh                   # Configuración personalizable
├── verify.sh                   # Verificación del proyecto
├── README.md                   # Este archivo
│
├── config/                     # Configuraciones de aplicaciones
│   ├── hypr/                   # Hyprland (compositor Wayland)
│   ├── waybar/                 # Barra de estado
│   ├── kitty/                  # Terminal
│   ├── zsh/                    # Shell (ZSH + Oh My Zsh + p10k)
│   ├── nvim/                   # Editor (Neovim)
│   ├── git/                    # Git
│   ├── starship/               # Prompt alternativo
│   ├── btop/                   # Monitor del sistema
│   ├── fastfetch/              # Info del sistema
│   └── swaylock/, wlogout/, wofi/
│
├── scripts/                    # Scripts de utilidad
│   ├── install-packages.sh     # Instalador de paquetes
│   ├── install-gui.sh          # GUI (Hyprland, GDM)
│   ├── install-cli-tools.sh    # Herramientas CLI
│   ├── link-configs.sh         # Crear symlinks
│   ├── backup-configs.sh       # Backups con timestamps
│   ├── health-check.sh         # Health check del sistema
│   ├── detect-hardware.sh      # Detección de hardware
│   ├── repo-manager.sh         # Gestión de repositorios Git
│   ├── ssh-manager.sh          # Gestión de claves SSH
│   ├── auto-detect-repos.sh    # Auto-detectar repos existentes
│   ├── post-install-verify.sh  # Verificación post-instalación
│   ├── export-packages.sh      # Exportar paquetes instalados
│   ├── init-dotfiles.sh        # Inicializar y mover repo
│   └── profiles/               # Perfiles predefinidos
│       ├── minimal.profile
│       ├── desktop.profile
│       ├── gaming.profile
│       ├── developer.profile
│       ├── pentesting.profile
│       └── full.profile
│
├── packages/                   # Listas de paquetes
│   ├── pacman-explicit.txt     # Paquetes pacman
│   ├── aur.txt                 # Paquetes AUR
│   ├── flatpak.txt             # Aplicaciones Flatpak
│   ├── npm-global.txt          # Paquetes npm
│   └── snap.txt                # Paquetes snap
│
├── docs/                       # Documentación
│   ├── FEATURES.md             # Características completas
│   ├── PERMISOS_SUDO.md        # Manejo de permisos sudo
│   ├── REPOSITORIOS_PRIVADOS.md # Guía de repos privados
│   └── ERROR-HANDLING.md       # Manejo de errores
│
├── hooks/                      # Hooks pre/post instalación
│   ├── README.md
│   ├── pre-install.sh.example
│   └── post-install.sh.example
│
├── ssh-backup/                 # Backup de claves SSH (solo .pub)
├── user-scripts/               # Scripts personalizados del usuario
├── repos.list                  # Tu lista de repositorios Git
└── repos.list.example          # Plantilla de ejemplo
```

---

## Perfiles Disponibles

| Perfil | Descripción | Espacio aprox. |
|--------|-------------|----------------|
| **minimal** | Base + Hyprland | ~5 GB |
| **desktop** | Uso diario + multimedia | ~10 GB |
| **gaming** | Steam + Lutris + Wine | ~15 GB |
| **developer** | IDEs + Docker + herramientas dev | ~18 GB |
| **pentesting** | BlackArch + herramientas de seguridad | ~16 GB |
| **full** | Todo incluido | ~20 GB |

Elige tu perfil en la **Opción 1** del menú.

---

## Casos de Uso

### Instalación nueva en Arch Linux

```bash
./install.sh
# Opción 1 → Elige tu perfil
# Opción 6 → Enlazar configuraciones (symlinks)
```

### Solo configurar el entorno (ya tienes Arch)

```bash
./install.sh
# Opción 5 → Configuración rápida (vim, zsh, starship)
# Opción 6 → Enlazar configuraciones
```

### Workstation de Desarrollo

```bash
./install.sh
# Opción 1 → Perfil Developer
# Después:
./scripts/ssh-manager.sh       # Crear clave SSH para GitHub/GitLab
./scripts/auto-detect-repos.sh # Detectar repos existentes
./scripts/repo-manager.sh      # Clonar todos tus proyectos
```

Ver [docs/REPOSITORIOS_PRIVADOS.md](docs/REPOSITORIOS_PRIVADOS.md) para repos privados.

### Transferir configuración entre equipos

**Equipo origen:**
```bash
cd ~/Documents/repos/dotfiles
./scripts/backup-configs.sh   # Backup de configs
./scripts/ssh-manager.sh      # Backup de SSH (opción 4)
./scripts/export-packages.sh  # Exportar lista de paquetes
git add . && git commit -m "Backup completo" && git push
```

**Equipo destino:**
```bash
git clone https://github.com/Keneth-Huerta/dotfiles ~/Documents/repos/dotfiles
cd ~/Documents/repos/dotfiles
./install.sh                  # Opción 1 → mismo perfil
./scripts/ssh-manager.sh      # Restaurar SSH (opción 5)
./scripts/repo-manager.sh     # Clonar repos (opción 2)
```

### PC Gaming

```bash
./install.sh
# Opción 1 → Perfil Gaming
```

Incluye: Steam, Lutris, Wine, GameMode, MangoHUD, Discord.

### Pentesting / Seguridad

```bash
./install.sh
# Opción 1 → Perfil Pentesting
```

Incluye: BlackArch, Wireshark, Metasploit, herramientas de seguridad.

---

## Herramientas Incluidas

### Sistema
- **pacman** + **paru** — gestores de paquetes (oficial + AUR)
- **GDM** — display manager
- **btop** — monitor de recursos

### Entorno Gráfico
- **Hyprland** — compositor Wayland
- **Waybar** — barra de estado
- **Dunst** — notificaciones
- **Wofi** — launcher
- **Swaylock** / **wlogout** — bloqueo de pantalla y menú de salida

### Terminal y Shell
- **Kitty** — terminal GPU-accelerated
- **ZSH** + **Oh My Zsh** + **powerlevel10k** — shell con prompt
- **fastfetch** — info del sistema al iniciar

### Desarrollo
- **Neovim** — editor de texto
- **VS Code, IntelliJ, Android Studio** — IDEs
- **Docker, VirtualBox** — virtualización
- **Git, GitHub CLI** — control de versiones
- **Node.js, Python, Rust, Go, Java** — lenguajes

### CLI Utilities
- **fzf, ripgrep, fd, bat, eza** — herramientas modernas
- **Nautilus, Ranger** — gestores de archivos

---

## Tips y Trucos

### Dry-run (ver qué se instalará sin ejecutar)

```bash
DRY_RUN=true ./install.sh
```

### Verificar el estado del proyecto

```bash
./verify.sh
```

### Health check del sistema

```bash
./install.sh  # Opción 16
# O directamente:
./scripts/health-check.sh
```

### Hooks personalizados

```bash
cp hooks/post-install.sh.example hooks/post-install.sh
nano hooks/post-install.sh
chmod +x hooks/post-install.sh
# Se ejecuta automáticamente después de instalar
```

### Gestionar tus repos

```bash
nano repos.list
# Agregar líneas del tipo:
# https://github.com/usuario/proyecto
# git@github.com:usuario/privado.git

./scripts/repo-manager.sh  # Opción 2 → clonar todos
./scripts/repo-manager.sh  # Opción 3 → actualizar todos
```

### Personalizar configuración

```bash
nano config.sh  # Cambia nombre, email, tema, shell, etc.
./install.sh    # Opción 1 o la que necesites
```

---

## Seguridad

- Solo se respaldan claves SSH **públicas** (`.pub`)
- Las claves **privadas** nunca se suben al repo
- `.gitignore` previene subir tokens, credenciales y claves privadas

Ver [ssh-backup/README.md](ssh-backup/README.md) para más detalles.

---

## Documentación Adicional

| Archivo | Descripción |
|---------|-------------|
| [docs/FEATURES.md](docs/FEATURES.md) | Documentación completa de características |
| [docs/PERMISOS_SUDO.md](docs/PERMISOS_SUDO.md) | Sistema de permisos y sudo |
| [docs/REPOSITORIOS_PRIVADOS.md](docs/REPOSITORIOS_PRIVADOS.md) | Repos privados (SSH/HTTPS) |
| [docs/ERROR-HANDLING.md](docs/ERROR-HANDLING.md) | Manejo de errores |
| [hooks/README.md](hooks/README.md) | Sistema de hooks pre/post |
| [ssh-backup/README.md](ssh-backup/README.md) | Guía de seguridad SSH |
| [packages/README.md](packages/README.md) | Gestión de paquetes |

---

## Solución de Problemas

### Conflicto de display managers

```bash
systemctl list-unit-files | grep -E "(gdm|sddm|lightdm)"
sudo systemctl disable sddm
sudo systemctl enable gdm
```

### Verificar instalación fallida

```bash
./install.sh  # Opción 17
# O directamente:
./scripts/post-install-verify.sh
```

### Restaurar desde backup

```bash
./install.sh  # Opción 13
# O directamente:
./scripts/restore-backup.sh
```

### Health check con problemas

```bash
./scripts/health-check.sh
systemctl status NetworkManager
systemctl status gdm
```

### p10k no carga el prompt

Asegúrate de que `~/.zshrc` **no** define `ZSH_THEME` (debe quedar vacío) y que la línea:

```bash
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
```

esté **después** de `source $ZSH/oh-my-zsh.sh`.

---

## Personalización

### Editar o crear un perfil

```bash
cat scripts/profiles/developer.profile
cp scripts/profiles/full.profile scripts/profiles/custom.profile
nano scripts/profiles/custom.profile
```

### Agregar tus scripts

```bash
cp mi-script.sh user-scripts/
chmod +x user-scripts/mi-script.sh
```

---

## Licencia

MIT — ver archivo `LICENSE`.

---

<div align="center">

**Made with ❤️ for Arch Linux**

**Autor:** Keneth Isaac Huerta Galindo  
[![GitHub](https://img.shields.io/badge/GitHub-@Keneth--Huerta-181717?logo=github)](https://github.com/Keneth-Huerta)  
[![Email](https://img.shields.io/badge/Email-kenethissac@gmail.com-EA4335?logo=gmail&logoColor=white)](mailto:kenethissac@gmail.com)

**¿Preguntas o sugerencias?** Abre un issue en el repositorio.

</div>
