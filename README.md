# Dotfiles v2.1 - Sistema de Configuración Multiplataforma

<div align="center">

**Sistema modular para múltiples distribuciones Linux con Hyprland**  
Restaura tu entorno completo en cualquier máquina con un solo comando.

[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Fedora](https://img.shields.io/badge/Fedora-51A2DA?logo=fedora&logoColor=white)](https://getfedora.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Compositor-00D9FF)](https://hyprland.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## 🎉 ¡NUEVO! Soporte Multi-Distribución

**Ahora funciona en múltiples distribuciones:**
- ✅ Arch Linux (y derivados: Manjaro, EndeavourOS, Garuda)
- ✅ Ubuntu / Debian (y derivados: Pop!_OS, Linux Mint, Elementary)
- ✅ Fedora / RHEL (y derivados: CentOS, Rocky, AlmaLinux)
- ✅ openSUSE
- ✅ Void Linux

**El script principal (`install.sh`) ahora:**
- ✅ Detecta automáticamente tu distribución
- ✅ Muestra advertencia si no es Arch pero permite continuar
- ✅ Instala lo que puede en tu distro
- ✅ Registra errores pero no se detiene

**Instalación selectiva:** Ya no necesitas instalar todo. Instala solo lo que necesitas:
```bash
# Script principal (optimizado para Arch, funciona en otras)
./install.sh

# O solo herramientas CLI (recomendado para no-Arch)
./scripts/install-cli-tools.sh --packages kitty zsh neovim git starship
```

Ver [CHANGELOG-MULTI-DISTRO.md](CHANGELOG-MULTI-DISTRO.md) y [RESUMEN-FINAL.md](RESUMEN-FINAL.md) para más detalles.

## Índice

<details>
<summary>Click para expandir el índice completo</summary>

### Inicio Rápido
- [Requisitos](#requisitos)
- [Instalación Rápida](#instalación-rápida)
- [Primeros Pasos](#primeros-pasos)

### Documentación
- [Características](#características-principales)
- [Perfiles Disponibles](#perfiles-disponibles)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Menú Principal](#menú-principal)

### Casos de Uso
- [Laptop Escuela/Trabajo](#laptop-de-escuelatrabajo)
- [PC Gaming](#pc-gaming)
- [Workstation Desarrollo](#workstation-de-desarrollo)
- [Pentesting/Seguridad](#pentestingseguridad)
- [Transferir entre PCs](#transferir-entre-computadoras)

### Configuración
- [Personalización](#personalización)
- [Tips y Trucos](#tips-y-trucos)
- [Seguridad](#seguridad)

### Mantenimiento
- [Solución de Problemas](#solución-de-problemas)
- [Herramientas Incluidas](#herramientas-incluidas)
- [Documentación Adicional](#documentación-adicional)

### Otros
- [Contribuir](#contribuir)
- [Changelog](#changelog)
- [Licencia](#licencia)

</details>

---

## Características Principales
### Nuevo en v2.0
- **6 Perfiles predefinidos** (minimal, desktop, gaming, developer, pentesting, full)
- **Detección automática de hardware** (GPU, CPU, WiFi, Bluetooth)
- **Modo Dry-Run** - previsualiza sin ejecutar
- **Sistema de backups mejorado** con timestamps
- **Verificación post-instalación** automática
- **Sistema de hooks** (pre/post install/config)
- **Detección de conflictos** (display managers, etc.)
- **Verificación de espacio** en disco
- **Health Check** completo del sistema
- **Gestión de repositorios Git** (clonar, actualizar todos)
- **Gestión de claves SSH** (backup seguro, restauración)
- **Auto-ubicación** del repositorio (`~/Documents/repos/dotfiles`)
- **Auto-detección de repositorios** existentes
- **Soporte para repositorios privados** (SSH/HTTPS)
- **Manejo robusto de permisos sudo** (pide contraseña una sola vez)
### Interfaz
- **Tema moderno** con colores rojos predominantes
- **Instalación modular** - instala solo lo que necesitas
- **Menú interactivo** con 16 opciones
- **Logs detallados** con timestamps y niveles
### Configuración
- **Hyprland + Waybar** completamente configurados
- **Gestión de paquetes** - Pacman, AUR (yay/paru), Flatpak
- **Modo rápido** para instalación parcial
- **Symlinks automáticos** para sincronización
## Requisitos

- Arch Linux (o derivados: Manjaro, EndeavourOS, etc.)
- Conexión a internet activa
- Git instalado: `sudo pacman -S git`
- **Usuario normal con permisos sudo** (NO ejecutar como root)
- Espacio en disco: 5-20GB (según perfil)

> [!IMPORTANT]  
> **NO ejecutes** `sudo ./install.sh`  
> El script pedirá sudo **automáticamente** cuando sea necesario.  
> Solo pedirá tu contraseña **una vez** al inicio.  
> Ver [docs/PERMISOS_SUDO.md](docs/PERMISOS_SUDO.md) para detalles.

---

## Instalación Rápida
### Primera vez:
```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/dotfiles.git
cd dotfiles
# 2. Inicializar (mueve a ubicación correcta)
./scripts/init-dotfiles.sh
# 3. Ejecutar desde nueva ubicación
cd ~/Documents/repos/dotfiles
# 4. Detectar hardware (opcional pero recomendado)
./install.sh  # Opción 14
# 5. Instalar con perfil
./install.sh  # Opción 1 → Selecciona tu perfil
```
### Instalación en nueva computadora (si ya tienes el repo configurado):
```bash
# 1. Clonar
git clone https://github.com/tu-usuario/dotfiles.git ~/Documents/repos/dotfiles
cd ~/Documents/repos/dotfiles
# 2. Instalar
./install.sh  # Opción 1 → Tu perfil guardado
# 3. Restaurar SSH
./scripts/ssh-manager.sh  # Opción 5
# 4. Clonar repos
./scripts/repo-manager.sh  # Opción 2
# Listo
```
## Estructura del Proyecto

```
dotfiles/
├── install.sh                  # Script principal (17 opciones)
├── config.sh                   # Configuración personalizable
├── verify.sh                   # Verificación del sistema
├── README.md                   # Este archivo
│
├── docs/                       # Documentación
│   ├── FEATURES.md             # Características completas v2.0
│   ├── PERMISOS_SUDO.md        # Manejo de permisos sudo
│   └── REPOSITORIOS_PRIVADOS.md # Guía de repos privados
│
├── config/                     # Configuraciones de aplicaciones
│   ├── hypr/                   # Hyprland (compositor Wayland)
│   ├── waybar/                 # Barra de estado
│   ├── kitty/                  # Terminal
│   ├── zsh/, fish/             # Shells
│   ├── git/, starship/         # Git y prompt
│   └── swaylock/, wlogout/, wofi/
│
├── scripts/                    # Scripts de utilidad
│   ├── install-packages.sh     # Instalador de paquetes
│   ├── install-gui.sh          # GUI (Hyprland, GDM)
│   ├── link-configs.sh         # Crear symlinks
│   ├── backup-configs.sh       # Backups con timestamps
│   ├── health-check.sh         # Health check del sistema
│   ├── detect-hardware.sh      # Detección de hardware
    repo-manager.sh           # Gestión de repositorios
    ssh-manager.sh            # Gestión de SSH
    auto-detect-repos.sh      # Auto-detectar repos existentes
    post-install-verify.sh    # Verificación post-instalación
    export-packages.sh        # Exportar paquetes
    init-dotfiles.sh          # Inicializar y mover repo
    profiles/                 # Perfiles predefinidos
        minimal.profile       # Perfil mínimo (~5GB)
        desktop.profile       # Uso diario (~10GB)
        gaming.profile        # Gaming (~15GB)
        developer.profile     # Desarrollo (~18GB)
        pentesting.profile    # Seguridad (~16GB)
        full.profile          # Todo (~20GB)
 packages/                      # Listas de paquetes
    pacman-explicit.txt       # Paquetes pacman
    aur.txt                   # Paquetes AUR
    flatpak.txt               # Paquetes Flatpak
    npm-global.txt            # Paquetes npm
    pip-global.txt            # Paquetes pip
    snap.txt                  # Paquetes snap
 hooks/                         # Hooks pre/post
    README.md                 # Documentación de hooks
    pre-install.sh.example    # Ejemplo pre-instalación
    post-install.sh.example   # Ejemplo post-instalación
 ssh-backup/                    # Backup SSH
    README.md                 # Guía de seguridad SSH
 user-scripts/                  # Scripts personalizados del usuario
    README.md                 # Documentación
 repos.list                     # Lista de repositorios Git
 repos.list.example             # Ejemplo de configuración
```
        full.profile          # Todo incluido
 hooks/                         #  Sistema de hooks
    README.md                 # Documentación de hooks
    pre-install.sh.example    # Ejemplo pre-instalación
    post-install.sh.example   # Ejemplo post-instalación
 packages/                      # Listas de paquetes
    pacman-explicit.txt       # Paquetes principales (limpio)
    aur.txt                   # Paquetes AUR
    flatpak.txt               # Aplicaciones Flatpak
    ...                       # Otros gestores
 ssh-backup/                    #  Backup de claves SSH
    README.md                 #  Información de seguridad
    *.pub                     # Solo claves públicas
 repos.list.example             #  Template para tus repos
 repos.list                     #  Tu lista de repositorios (se crea al usar)
```
## Perfiles Disponibles
| Perfil | Descripción | Paquetes | Espacio | Uso |
|--------|-------------|----------|---------|-----|
| **Minimal** | Base + Hyprland | ~50 | ~5GB | VMs, recursos limitados |
| **Desktop** | Uso diario + multimedia | ~100 | ~10GB | Laptop personal, escuela |
| **Gaming** | Steam + Lutris + Wine | ~130 | ~15GB | PC gaming |
| **Developer** | IDEs + Docker + Tools | ~150 | ~18GB | Desarrollo software |
| **Pentesting** | BlackArch + Security | ~140 | ~16GB | Seguridad, hacking ético |
| **Full** | TODO incluido | ~200 | ~20GB | Workstation completa |

Elige tu perfil durante la instalación (Opción 1 del menú).

---

## 🎨 NUEVO: Menú Moderno con Python + Rich

Ahora tienes **dos opciones de interfaz**:

### Opción 21: Menú Moderno (Recomendado) ⭐
```
╔══════════════════════════════════════════════════════════════╗
║              DOTFILES INSTALLER                              ║
║                  Tu sistema, tu forma                        ║
╚══════════════════════════════════════════════════════════════╝

┌────┬──────────────────────────┬────────────────────────────┬──────────┐
│ #  │ Componente               │ Descripción                │ Estado   │
├────┼──────────────────────────┼────────────────────────────┼──────────┤
│ 1  │ Terminal Tools           │ kitty, alacritty           │ ●        │
│ 2  │ Shells                   │ zsh + p10k, fish          │ ●        │
│ 3  │ Editores                 │ neovim + NvChad            │ ●        │
└────┴──────────────────────────┴────────────────────────────┴──────────┘

Instalando Terminal Tools   ━━━━━━━━━━━━━━━━━━━━━━━━ 100% ✓
```

**Características:**
- ✅ Interfaz moderna con colores y tablas
- ✅ Progress bars en tiempo real
- ✅ Selección múltiple intuitiva (1, 2-5, 7)
- ✅ Menú de gestión integrado
- ✅ Auto-instalación de dependencias (Python + Rich)

Ver documentación completa: [docs/MENU-MODERNO.md](docs/MENU-MODERNO.md)

### Opción 20: Menú Clásico (whiptail)
Para sistemas con limitaciones o preferencia por interfaces clásicas.

---

## Menú Principal

```
╔════════════════════════════════════╗
║      MENÚ PRINCIPAL - v2.1         ║
╚════════════════════════════════════╝

Instalación:
  1) Instalación completa (con perfil)
  2) Solo paquetes
  3) Solo GUI (Hyprland + GDM)
  4) Solo CLI tools
  5) Solo enlazar configs

Backup y Exportación:
  6) Backup de configuraciones
  7) Exportar paquetes

Mantenimiento:
  8) Actualizar sistema
  9) Config rápida (vim, zsh)

Menús Interactivos:
  20) Menú interactivo (whiptail/dialog)
  21) ★ Menú Moderno (Python + Rich) [RECOMENDADO]

Gestión:
  11) Gestionar repositorios
  12) Gestionar claves SSH
  13) Restaurar backup
  17) Auto-detectar repositorios
  18) Actualizar configuraciones al repo

Diagnóstico:
  14) Detección hardware
  15) Health check sistema
  16) Verificar instalación
  19) Ver estado de enlaces simbólicos

Avanzado:
  10) Inicializar dotfiles
  0)  Salir
```

---

## Casos de Uso
### Laptop de Escuela/Trabajo
```bash
./install.sh
# Opción 1 → Perfil Desktop
# Opción 9 → Configuración rápida (si solo quieres lo básico)
```
**Incluye**: Navegador, multimedia, office, terminal configurado
---
### PC Gaming
```bash
./install.sh
# Opción 1 → Perfil Gaming
```
**Incluye**: Steam, Lutris, Wine, GameMode, MangoHUD, Discord
---
### Workstation de Desarrollo
```bash
./install.sh
# Opción 1 → Perfil Developer
# Después de instalar:
# 1. Configurar SSH (para repos privados)
./scripts/ssh-manager.sh   # Crear clave y agregar a GitHub/GitLab
# 2. Detectar repos existentes (si tienes algunos)
./scripts/auto-detect-repos.sh
# 3. Clonar todos tus proyectos
./scripts/repo-manager.sh  # Opción 2
# 4. Verificar SSH
./scripts/repo-manager.sh  # Opción 6
```
**Incluye**: IDEs, Docker, VirtualBox, herramientas de dev
** Tip**: Lee [docs/REPOSITORIOS_PRIVADOS.md](docs/REPOSITORIOS_PRIVADOS.md) para detalles sobre repos privados
---
### Pentesting/Seguridad
```bash
./install.sh
# Opción 1 → Perfil Pentesting
```
**Incluye**: BlackArch, Wireshark, Metasploit, herramientas de seguridad
---
### Transferir Entre Computadoras
**PC Origen:**
```bash
cd ~/Documents/repos/dotfiles
# Hacer backups
./scripts/backup-configs.sh      # Configs
./scripts/ssh-manager.sh         # SSH (Opción 4)
./scripts/export-packages.sh     # Paquetes
# Commit y push
git add .
git commit -m "Backup completo"
git push
```
**PC Destino:**
```bash
# Clonar y configurar
git clone https://github.com/tu-usuario/dotfiles ~/Documents/repos/dotfiles
cd ~/Documents/repos/dotfiles
# Instalar
./install.sh  # Opción 1 → Mismo perfil
# Restaurar
./scripts/ssh-manager.sh   # Opción 5
./scripts/repo-manager.sh  # Opción 2
# Idéntico al PC origen
```
---

## Herramientas Incluidas

### Gestión de Sistema
- **pacman** - Gestor de paquetes oficial
- **yay/paru** - AUR helpers
- **GDM** - Display Manager (login screen)
### Entorno Gráfico
- **Hyprland** - Compositor Wayland moderno
- **Waybar** - Barra de estado personalizable
- **Dunst** - Notificaciones
- **Wofi** - Launcher de aplicaciones
- **Swaylock** - Bloqueador de pantalla

### Terminal
- **Kitty** - Emulador de terminal GPU-accelerated
- **Zsh** - Shell avanzado
- **Starship** - Prompt personalizable
- **Oh My Zsh** - Framework para Zsh
### Desarrollo
- **VS Code, IntelliJ, Android Studio** - IDEs
- **Docker, VirtualBox** - Virtualización
- **Git, GitHub CLI** - Control de versiones
- **Node.js, Python, Rust, Go, Java** - Lenguajes

### Utilidades
- **btop** - Monitor del sistema
- **fastfetch** - Info del sistema
- **fzf, ripgrep, fd, bat** - CLI tools
- **Nautilus, Ranger** - Gestores de archivos

---

## Tips y Trucos
### Vista Previa (Dry-Run)
```bash
# Ver qué se instalará SIN ejecutar
DRY_RUN=true ./install.sh
```
### Verificar Salud del Sistema
```bash
./install.sh  # Opción 15
# O directamente:
./scripts/health-check.sh
```
### Crear Hooks Personalizados
```bash
# Copiar ejemplo
cp hooks/post-install.sh.example hooks/post-install.sh
# Editar
nano hooks/post-install.sh
# Hacer ejecutable
chmod +x hooks/post-install.sh
# Se ejecutará automáticamente después de instalar
```
### Gestionar tus Repos
```bash
# Editar lista
nano repos.list
# Agregar repos:
# https://github.com/usuario/proyecto1
# git@github.com:usuario/privado.git
# Clonar todos
./scripts/repo-manager.sh  # Opción 2
# Actualizar todos
./scripts/repo-manager.sh  # Opción 3
```

---

## Seguridad
### Claves SSH
- Solo se respaldan claves **públicas** (`.pub`)
- Las claves **privadas** NUNCA se suben al repo
- `.gitignore` previene accidentes
- [Más info](ssh-backup/README.md)
### Información Sensible
El `.gitignore` protege:
- Claves privadas SSH
- Tokens y credenciales
- Información personal en configs
- Logs con datos sensibles

---

## Documentación Adicional
### Guías Completas
- **[docs/FEATURES.md](docs/FEATURES.md)** -  Documentación completa de todas las características
- **[docs/PERMISOS_SUDO.md](docs/PERMISOS_SUDO.md)** -  Sistema de permisos y sudo
- **[docs/REPOSITORIOS_PRIVADOS.md](docs/REPOSITORIOS_PRIVADOS.md)** -  Manejo de repositorios privados
### Otros Recursos
- **[hooks/README.md](hooks/README.md)** -  Sistema de hooks pre/post
- **[ssh-backup/README.md](ssh-backup/README.md)** -  Guía de seguridad SSH
- **[user-scripts/README.md](user-scripts/README.md)** -  Scripts personalizados
- **[packages/README.md](packages/README.md)** -  Gestión de paquetes

---

## Solución de Problemas
### Error: Display Manager conflicts
```bash
# Ver cuáles están habilitados
systemctl list-unit-files | grep -E "(gdm|sddm|lightdm)"
# Deshabilitar el no deseado
sudo systemctl disable sddm
sudo systemctl enable gdm
```
### Verificar Instalación Fallida
```bash
./install.sh  # Opción 16
# O:
./scripts/post-install-verify.sh
```
### Restaurar desde Backup
```bash
./install.sh  # Opción 13
# O:
./scripts/restore-backup.sh
```
### Health Check con Problemas
```bash
# Ejecutar verificación completa
./scripts/health-check.sh
# Ver detalles de servicios
systemctl status NetworkManager
systemctl status gdm
systemctl status docker
```

---

## Personalización
### Editar Perfil
```bash
# Ver perfil actual
cat scripts/profiles/developer.profile
# Crear perfil personalizado
cp scripts/profiles/full.profile scripts/profiles/custom.profile
nano scripts/profiles/custom.profile
```
### Agregar tus Scripts
```bash
# Agregar en user-scripts/
cp mi-script.sh user-scripts/
chmod +x user-scripts/mi-script.sh
```

---

## Contribuir
1. Fork el proyecto
2. Crea tu rama: `git checkout -b feature/nueva-caracteristica`
3. Commit: `git commit -m 'Add nueva característica'`
4. Push: `git push origin feature/nueva-caracteristica`
5. Abre un Pull Request

---

## Changelog
### v2.0.0 - Diciembre 2024
**Sistema de Configuración Avanzada**
#### Características Principales (13):
- **Sistema de 6 perfiles** (minimal, desktop, gaming, developer, pentesting, full)
- **Detección automática de hardware** (GPU, CPU, WiFi, Bluetooth)
- **Modo dry-run** - Previsualiza sin ejecutar
- **Backups mejorados** con timestamps y metadatos
- **Verificación post-instalación** con retry automático
- **Sistema de hooks** (pre/post install/config)
- **Detección de conflictos** (display managers, shells, etc.)
- **Verificación de espacio** en disco
- **Logs mejorados** con timestamps y niveles
- **Health check** completo del sistema (9 categorías)
#### Gestión de Repositorios:
- **Gestión de repositorios Git** (clonar/actualizar/estado todos)
- **Auto-detección** de repositorios existentes
- **Soporte para repositorios privados** (SSH/HTTPS)
- **Conversión automática** HTTPS → SSH
#### Seguridad y Permisos:
- **Manejo robusto de permisos sudo** (pide contraseña una sola vez)
- **Gestión de claves SSH** con backup seguro y verificación
- **Verificación de configuración SSH** (GitHub/GitLab)
#### Otros:
- **Auto-ubicación** del repositorio
- **Documentación completa** (800+ líneas)
- **Estructura organizada** (carpeta docs/)
#### Archivos:
- 15+ scripts de utilidad
- 6 perfiles predefinidos
- Documentación en español
- Sistema modular y extensible
### v1.0.0 - 2024
- Primera versión
- Instalación básica de Hyprland
- Scripts modulares
- Sistema de backups básico

---

## Licencia
Este proyecto está bajo la Licencia MIT. Ver archivo `LICENSE` para más detalles.
## Agradecimientos
- Comunidad de Arch Linux
- Hyprland Developers
- Todos los contribuidores
---
**¿Preguntas o sugerencias?** Abre un issue en el repositorio.
**Feliz configuración**
---

<div align="center">

### **Made with ❤️ for Arch Linux**

**¿Preguntas o sugerencias?** Abre un issue en el repositorio

**Feliz configuración**

#### Autor
**Keneth Isaac Huerta Galindo**  
[![GitHub](https://img.shields.io/badge/GitHub-@Keneth--Huerta-181717?logo=github)](https://github.com/Keneth-Huerta)  
[![Email](https://img.shields.io/badge/Email-kenethissac@gmail.com-EA4335?logo=gmail&logoColor=white)](mailto:kenethissac@gmail.com)

---

**Dale una estrella si te gusta este proyecto**  
**Puedes forkear y adaptar a tus necesidades**

[Volver arriba](#dotfiles-v20---sistema-de-configuración-avanzada)

</div>