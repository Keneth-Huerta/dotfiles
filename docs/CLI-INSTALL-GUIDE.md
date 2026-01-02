# Instalador CLI Multi-Distribución

Este sistema de instalación ahora soporta **múltiples distribuciones Linux**, no solo Arch Linux.

## Distribuciones Soportadas

- ✅ **Arch Linux** (y derivados: Manjaro, EndeavourOS, Garuda)
- ✅ **Ubuntu / Debian** (y derivados: Pop!_OS, Linux Mint, Elementary)
- ✅ **Fedora / RHEL** (y derivados: CentOS, Rocky, AlmaLinux)
- ✅ **openSUSE**
- ✅ **Void Linux**

## Características Principales

### 1. Detección Automática
El script detecta automáticamente:
- Tu distribución Linux
- El gestor de paquetes disponible (pacman, apt, dnf, zypper, xbps)
- AUR helpers en Arch (yay, paru, pikaur)

### 2. Mapeo de Paquetes
Los nombres de paquetes se adaptan automáticamente según la distribución:
- `python` → `python3` en Ubuntu
- `base-devel` → `build-essential` en Ubuntu
- `docker` → `docker.io` en Ubuntu
- Y muchos más...

### 3. Instalación Selectiva
Puedes instalar solo lo que necesitas.

## Uso Básico

### Modo Interactivo (Menú)

```bash
cd /home/valge/Documents/repos/dotfiles/scripts
./install-cli-tools.sh
```

Te mostrará un menú con opciones:
```
1)  Instalar todo
2)  Herramientas de terminal (kitty, alacritty, tmux)
3)  Shells (fish, zsh + oh-my-zsh)
4)  Prompts (starship, oh-my-posh)
5)  Editores (vim, neovim, LazyVim)
6)  Utilidades CLI (htop, fzf, ripgrep, bat, etc)
7)  Herramientas de desarrollo (node, python, go, rust)
8)  Bases de datos (postgresql, redis)
9)  Instalar paquetes específicos
10) Actualizar sistema
0)  Salir
```

### Modo No Interactivo (Argumentos)

#### Instalar todo
```bash
./install-cli-tools.sh --all
```

#### Instalar categorías específicas
```bash
# Solo shells
./install-cli-tools.sh --shells

# Solo editores
./install-cli-tools.sh --editors

# Solo utilidades CLI
./install-cli-tools.sh --cli

# Herramientas de desarrollo
./install-cli-tools.sh --dev
```

#### Instalar paquetes específicos
```bash
# Instalar solo kitty y zsh
./install-cli-tools.sh --packages kitty zsh

# Instalar kitty, neovim y starship
./install-cli-tools.sh --packages kitty neovim starship

# En tu escuela con Ubuntu, instalar lo esencial
./install-cli-tools.sh --packages kitty zsh neovim git fzf ripgrep
```

#### Actualizar sistema
```bash
./install-cli-tools.sh --update
```

#### Ver ayuda
```bash
./install-cli-tools.sh --help
```

## Ejemplos de Uso

### Escenario 1: En tu escuela (Ubuntu)
Solo quieres instalar herramientas básicas:

```bash
cd ~/dotfiles/scripts
./install-cli-tools.sh --packages kitty zsh neovim git starship fzf ripgrep bat
```

Luego configurar zsh:
```bash
./install-cli-tools.sh --shells  # Instala zsh + oh-my-zsh
```

### Escenario 2: Configuración Mínima de Desarrollo
```bash
./install-cli-tools.sh --shells     # zsh + oh-my-zsh
./install-cli-tools.sh --editors    # vim + neovim
./install-cli-tools.sh --cli        # fzf, ripgrep, bat, etc
```

### Escenario 3: Setup Completo de Desarrollador
```bash
./install-cli-tools.sh --shells
./install-cli-tools.sh --editors
./install-cli-tools.sh --cli
./install-cli-tools.sh --dev        # node, python, go, rust, docker
./install-cli-tools.sh --databases  # postgresql, redis
```

### Escenario 4: Solo las Herramientas que Necesitas
```bash
# Lista tus paquetes favoritos
./install-cli-tools.sh --packages \
  kitty \
  zsh \
  neovim \
  git \
  fzf \
  ripgrep \
  bat \
  htop \
  tmux \
  starship
```

## Configuraciones Incluidas

Después de instalar las herramientas, puedes vincular las configuraciones:

```bash
# Desde el directorio principal
cd ~/dotfiles
./scripts/link-configs.sh
```

### 🔗 ¿Qué son los Enlaces Simbólicos?

Un **enlace simbólico** (symlink) es como un "acceso directo" que apunta a otro archivo o carpeta.

**Ejemplo práctico:**
```bash
# Tu configuración de Kitty está en:
~/dotfiles/config/kitty/kitty.conf

# Pero Kitty busca su configuración en:
~/.config/kitty/kitty.conf

# El enlace simbólico conecta ambos:
ln -s ~/dotfiles/config/kitty ~/.config/kitty
      └──────┬──────┘           └──────┬──────┘
          ORIGEN                   DESTINO
```

Ahora cuando Kitty lee `~/.config/kitty/kitty.conf`, en realidad está leyendo tu archivo de `~/dotfiles/config/kitty/kitty.conf` ✓

**Ventajas:**
- ✅ Mantén todas tus configs en un solo lugar (tu repo)
- ✅ Versiónalas con Git
- ✅ Sincroniza fácilmente entre computadoras
- ✅ Las aplicaciones siguen funcionando normalmente

**Ejemplo visual:**
```
Tu repo:                    Lo que las apps ven:
~/dotfiles/                 ~/.config/
├── config/                 ├── kitty/  ──→ ~/dotfiles/config/kitty/
│   ├── kitty/             │   (enlace simbólico)
│   │   └── kitty.conf     │
│   ├── zsh/               ├── zsh/    ──→ ~/dotfiles/config/zsh/
│   │   └── .zshrc         │   (enlace simbólico)
│   └── starship/          └── starship.toml ──→ ~/dotfiles/config/starship/
│       └── starship.toml      (enlace simbólico)
```

El script `link-configs.sh` creará estos enlaces automáticamente:
- ✅ `~/.config/kitty/` → `~/dotfiles/config/kitty/`
- ✅ `~/.config/zsh/` → `~/dotfiles/config/zsh/`
- ✅ `~/.config/nvim/` → `~/dotfiles/config/nvim/` (si existe)
- ✅ `~/.config/starship.toml` → `~/dotfiles/config/starship/starship.toml`
- ✅ Y más...

**Para verificar que funcionó:**
```bash
# Ver a dónde apunta un enlace simbólico
ls -l ~/.config/kitty

# Output:
# lrwxrwxrwx ... ~/.config/kitty -> /home/user/dotfiles/config/kitty
#                                    └─ Apunta a tu repo ✓
```

## Instalación de Oh-My-Zsh

El script instala automáticamente Oh-My-Zsh cuando usas la opción `--shells`:

```bash
./install-cli-tools.sh --shells
```

Esto incluye:
- ✅ Zsh
- ✅ Oh-My-Zsh
- ✅ Plugins recomendados (autosuggestions, syntax-highlighting)

## Notas Importantes

### Ubuntu/Debian
- Algunos paquetes pueden requerir PPAs adicionales (como Starship)
- El script intentará instalar desde repos oficiales primero
- Si algo no está disponible, te sugerirá la instalación manual

### Arch Linux
- Soporta AUR helpers (yay, paru)
- Paquetes exclusivos de AUR se saltarán en otras distros
- Instala `yay` si no lo tienes con `./install-cli-tools.sh --packages yay`

### Permisos Sudo
- El script pedirá tu contraseña sudo al inicio
- Mantendrá la sesión activa durante la instalación
- Solo necesitas ingresarla una vez

## Solución de Problemas

### "Distribución no reconocida"
El script intentará detectar el gestor de paquetes automáticamente. Si falla:
1. Verifica que tienes `/etc/os-release`
2. Reporta el problema con tu distro

### "Paquete no encontrado"
Algunos paquetes pueden tener nombres diferentes:
- Usa `pkg_search nombre` para buscar
- O instala manualmente y reporta el problema

### "No hay AUR helper"
En Arch, instala yay primero:
```bash
./install-cli-tools.sh --packages base-devel git
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## Funciones Avanzadas

### Script distro-utils.sh
Si quieres usar las funciones en tus propios scripts:

```bash
source /home/valge/Documents/repos/dotfiles/scripts/distro-utils.sh

# Instalar paquetes
pkg_install kitty zsh neovim

# Verificar si está instalado
if pkg_is_installed neovim; then
    echo "Neovim está instalado"
fi

# Buscar paquetes
pkg_search ripgrep

# Actualizar sistema
pkg_update
```

## Contribuir

Si encuentras que un paquete tiene un nombre diferente en tu distro, puedes:
1. Editar `scripts/distro-utils.sh`
2. Agregar el mapeo en la función `map_package_name()`
3. Crear un PR o issue

## Licencia

MIT License - Úsalo libremente
