# 🎉 ACTUALIZACIÓN IMPORTANTE: Soporte Multi-Distribución

## ¿Qué cambió?

¡Los scripts ahora funcionan en **múltiples distribuciones Linux**! Ya no estás limitado a solo Arch Linux.

### Distribuciones Soportadas ✅

- **Arch Linux** (y derivados: Manjaro, EndeavourOS, Garuda)
- **Ubuntu / Debian** (y derivados: Pop!_OS, Linux Mint, Elementary)
- **Fedora / RHEL** (y derivados: CentOS, Rocky, AlmaLinux)
- **openSUSE**
- **Void Linux**

## Nuevo Sistema de Instalación

### 1. Script Principal: `distro-utils.sh`

Este nuevo módulo:
- ✅ Detecta automáticamente tu distribución
- ✅ Identifica el gestor de paquetes (pacman, apt, dnf, zypper, xbps)
- ✅ Mapea nombres de paquetes entre distribuciones
- ✅ Proporciona funciones universales (`pkg_install`, `pkg_update`, etc.)

### 2. `install-cli-tools.sh` Mejorado

Ahora puedes:

#### Instalación Selectiva de Paquetes Específicos

```bash
# En tu escuela con Ubuntu, instalar solo lo que necesitas
./scripts/install-cli-tools.sh --packages kitty zsh neovim git starship fzf

# Instalar solo shells
./scripts/install-cli-tools.sh --shells

# Instalar todo
./scripts/install-cli-tools.sh --all
```

#### Modo Interactivo

```bash
./scripts/install-cli-tools.sh
```

Te mostrará un menú con opciones para instalar:
1. Herramientas de terminal
2. Shells (zsh + oh-my-zsh)
3. Editores (vim, neovim)
4. Utilidades CLI (htop, fzf, ripgrep, bat, etc)
5. Herramientas de desarrollo (node, python, go, rust)
6. Bases de datos
7. Paquetes específicos

## Casos de Uso

### 📚 Escenario 1: En la Escuela (Ubuntu)

Solo necesitas las herramientas esenciales:

```bash
cd ~/dotfiles
./scripts/install-cli-tools.sh --packages kitty zsh neovim git starship
```

### 💻 Escenario 2: Setup Completo en Casa (Arch)

```bash
cd ~/dotfiles
./scripts/install-cli-tools.sh --all
```

### 🔧 Escenario 3: Desarrollo Rápido (Cualquier Distro)

```bash
cd ~/dotfiles
./scripts/install-cli-tools.sh --shells     # zsh + oh-my-zsh
./scripts/install-cli-tools.sh --editors    # vim + neovim + LazyVim
./scripts/install-cli-tools.sh --cli        # utilidades esenciales
./scripts/install-cli-tools.sh --dev        # node, python, go, docker
```

### 🎯 Escenario 4: Instalación Personalizada

```bash
# Selecciona exactamente lo que quieres
./scripts/install-cli-tools.sh --packages \
  kitty \           # Terminal
  zsh \             # Shell
  neovim \          # Editor
  git \             # Control de versiones
  fzf \             # Fuzzy finder
  ripgrep \         # Búsqueda rápida
  bat \             # cat mejorado
  htop \            # Monitor de procesos
  tmux \            # Multiplexor
  starship          # Prompt bonito
```

## Comandos Disponibles

```bash
./scripts/install-cli-tools.sh [OPCIÓN]

Opciones:
  --all         Instalar todo
  --terminal    Herramientas de terminal (kitty, alacritty, tmux)
  --shells      Shells (fish, zsh + oh-my-zsh)
  --prompts     Prompts (starship)
  --editors     Editores (vim, neovim, LazyVim)
  --cli         Utilidades CLI (htop, fzf, ripgrep, bat, etc)
  --dev         Herramientas de desarrollo (node, python, go, rust)
  --databases   Bases de datos (postgresql, redis)
  --packages    Instalar paquetes específicos
  --update      Actualizar sistema
  --help        Mostrar ayuda
```

## Mapeo Automático de Paquetes

El sistema mapea automáticamente los nombres de paquetes:

| Concepto | Arch | Ubuntu | Fedora |
|----------|------|--------|--------|
| Python | `python` | `python3` | `python3` |
| Build Tools | `base-devel` | `build-essential` | `Development Tools` |
| Docker | `docker` | `docker.io` | `docker` |
| Python pip | `python-pip` | `python3-pip` | `python3-pip` |

## Ventajas

1. **✅ Portabilidad**: Un solo script funciona en todas las distribuciones
2. **✅ Instalación Selectiva**: Instala solo lo que necesitas
3. **✅ Flexibilidad**: Modo interactivo o por comandos
4. **✅ Mantenible**: Fácil agregar soporte para más paquetes
5. **✅ Sin duplicación**: No más scripts separados por distro

## Instalación y Configuración

### Paso 1: Instalar Herramientas

```bash
cd ~/dotfiles
./scripts/install-cli-tools.sh --packages kitty zsh neovim git starship
```

### Paso 2: Vincular Configuraciones

```bash
./scripts/link-configs.sh
```

Esto vinculará:
- `~/.config/kitty/` → Configuración de Kitty
- `~/.config/zsh/` → Configuración de Zsh
- `~/.config/starship.toml` → Prompt de Starship
- Y más...

### Paso 3: Cambiar Shell a Zsh

```bash
chsh -s $(which zsh)
```

## Ejemplo de Script

Creamos un script de ejemplo en `scripts/example-usage.sh`:

```bash
./scripts/example-usage.sh
```

Esto te mostrará:
- Información de tu sistema
- Ejemplos de comandos
- Opciones para ejecutar instalaciones rápidas

## Documentación Completa

Ver documentación detallada en:
- [`docs/CLI-INSTALL-GUIDE.md`](docs/CLI-INSTALL-GUIDE.md) - Guía completa de instalación

## Funciones para Tus Scripts

Si quieres usar las funciones en tus propios scripts:

```bash
#!/usr/bin/env bash
source /path/to/dotfiles/scripts/distro-utils.sh

# Instalar paquetes (funciona en cualquier distro)
pkg_install kitty zsh neovim

# Verificar si está instalado
if pkg_is_installed neovim; then
    echo "Neovim está instalado"
fi

# Actualizar sistema
pkg_update

# Buscar paquetes
pkg_search ripgrep
```

## Solución de Problemas

### Ubuntu: Paquete no encontrado

Algunos paquetes pueden necesitar PPAs:

```bash
# Starship (si no está en repos)
curl -sS https://starship.rs/install.sh | sh
```

### Arch: Instalar yay

Si no tienes yay instalado:

```bash
cd ~/dotfiles
./scripts/install-cli-tools.sh --packages base-devel git
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## Contribuir

¿Encontraste un paquete que tiene un nombre diferente en tu distro?

1. Edita `scripts/distro-utils.sh`
2. Agrega el mapeo en `map_package_name()`
3. Crea un PR

## Cambios Técnicos

### Archivos Nuevos
- ✅ `scripts/distro-utils.sh` - Módulo de detección y gestión multi-distro
- ✅ `scripts/example-usage.sh` - Script de ejemplo
- ✅ `scripts/test-install.sh` - Script de prueba del sistema de errores
- ✅ `scripts/demo-error-handling.sh` - Demostración del sistema de gestión de errores
- ✅ `docs/CLI-INSTALL-GUIDE.md` - Guía completa
- ✅ `docs/ERROR-HANDLING.md` - Documentación del sistema de gestión de errores

### Archivos Modificados
- ✅ `scripts/install-cli-tools.sh` - Ahora multi-distro con instalación selectiva
- ✅ `scripts/install-packages.sh` - Adaptado para múltiples distros

### Características Nuevas
- ✅ Detección automática de distribución
- ✅ Mapeo de nombres de paquetes
- ✅ Instalación selectiva (`--packages`)
- ✅ Modo interactivo mejorado
- ✅ Modo no interactivo con argumentos
- ✅ Funciones reutilizables
- ✅ **Sistema de gestión de errores inteligente**
- ✅ **Búsqueda automática de alternativas**
- ✅ **Log persistente de paquetes fallidos**
- ✅ **Resumen detallado al final**
- ✅ **Instalación paquete por paquete para mejor control**

## Sistema de Gestión de Errores

### Nuevas Funcionalidades

#### 1. Búsqueda Inteligente
Cuando un paquete no se puede instalar:
1. Intenta instalación normal
2. Busca alternativas automáticamente
3. Intenta instalar las alternativas
4. Busca en los repositorios
5. Registra el fallo en un log

#### 2. Alternativas Automáticas
El sistema conoce alternativas comunes:
- `fastfetch` → `neofetch`, `screenfetch`
- `exa`/`eza` → `exa`, `eza`, `lsd`
- `bat` → `batcat`
- `fd` → `fd-find`
- `lazygit` → `tig`, `gitui`

#### 3. Log Persistente
Los fallos se guardan en `~/.dotfiles-failed-packages.log`:
```
2026-01-02 17:45:30 | arch | paquete-inexistente | No se encontró
```

#### 4. Resumen al Final
Muestra un resumen detallado de:
- ✅ Qué paquetes fallaron
- ✅ Por qué fallaron
- ✅ Sugerencias de alternativas
- ✅ Comandos para instalación manual
- ✅ Enlaces de instalación manual para casos especiales

### Ejemplo de Uso

```bash
./scripts/install-cli-tools.sh --packages git paquete-falso htop

# Output:
# [INFO] Instalando paquetes: git paquete-falso htop
# [✓] git ya está instalado ✓
# [INFO] Intentando instalar: paquete-falso
# [WARN] Paquete 'paquete-falso' no encontrado
# [ERROR] No se pudo instalar: paquete-falso
# [✓] htop instalado ✓
#
# Resumen:
#   ✓ Instalados: 2
#   ✗ Fallidos: 1
#
# ════════════════════════════════════════════════════════
# ⚠  PAQUETES QUE NO SE PUDIERON INSTALAR
# ════════════════════════════════════════════════════════
#   ✗ paquete-falso
# ℹ  Log guardado en: ~/.dotfiles-failed-packages.log
```

Ver documentación completa en [`docs/ERROR-HANDLING.md`](docs/ERROR-HANDLING.md)

## Licencia

MIT License

---

**Nota**: Este cambio no afecta tu configuración actual. Los archivos de configuración en `config/` siguen siendo los mismos. Solo mejoramos la instalación de paquetes.
