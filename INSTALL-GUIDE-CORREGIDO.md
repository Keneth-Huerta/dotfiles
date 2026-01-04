# Guía de Instalación Completa y Corregida

Este documento contiene todas las correcciones aplicadas al instalador CLI.

## 🔧 Problemas Resueltos

### 1. ✅ Selección Múltiple en el Menú
**Problema:** Al elegir la opción 5 (editores), si querías instalar varias cosas, tenías que volver al menú principal una y otra vez.

**Solución:** Ahora cada opción instala todo lo relacionado de una vez y automáticamente enlaza los dotfiles.

### 2. ✅ Enlace Automático de Dotfiles
**Problema:** Después de instalar algo, tenías que ejecutar `link-configs.sh` manualmente.

**Solución:** Ahora cada instalación enlaza automáticamente sus configuraciones:
- `install_terminal_tools` → enlaza configuración de Kitty
- `install_shells` → enlaza configuración de Zsh y .p10k.zsh
- `install_editors` → enlaza configuración de Neovim
- `install_prompts` → enlaza configuración de Starship

### 3. ✅ Powerlevel10k Configurado
**Problema:** Powerlevel10k no estaba instalado ni configurado.

**Solución:** 
- Se agregó `install_powerlevel10k()` que se ejecuta automáticamente con `--shells`
- Se corrigió `.zshrc` para usar `ZSH_THEME="powerlevel10k/powerlevel10k"`
- Se descargó archivo `.p10k.zsh` de configuración predeterminado
- El archivo se enlaza automáticamente a `~/.p10k.zsh`

### 4. ✅ NvChad en Lugar de LazyVim
**Problema:** El script instalaba LazyVim pero tú usabas NvChad.

**Solución:**
- Se cambió `install_lazyvim()` por `install_nvchad()`
- Se actualizó el menú y documentación para mostrar NvChad
- La instalación ahora clona el repositorio oficial de NvChad

### 5. ✅ Plugins de Oh-My-Zsh Configurados
**Problema:** Plugins como `z`, `sudo`, `web-search` no estaban configurados.

**Solución:** El archivo `.zshrc` ya tiene estos plugins configurados:
```bash
plugins=(
    git 
    z                          # ✅ Navegación rápida por directorios
    extract
    colored-man-pages
    alias-finder
    zsh-autosuggestions 
    zsh-syntax-highlighting 
    zsh-history-substring-search
    docker-compose
    kubectl
    sudo                       # ✅ Presiona ESC dos veces para agregar sudo
    systemd
    archlinux
    web-search                 # ✅ Buscar desde terminal (google, ddg, etc)
    copyfile
    copypath
)
```

### 6. ⚠️ Mover Repositorio a ~/Documents/repos/dotfiles
**Problema:** El repositorio no se movía a la ubicación correcta.

**Solución:** Ejecuta `init-dotfiles.sh` ANTES de instalar:

```bash
# Si clonaste en otro lugar (ej: ~/)
cd ~/dotfiles
./scripts/init-dotfiles.sh

# Esto moverá el repo a ~/Documents/repos/dotfiles
# y luego ejecuta desde ahí:
cd ~/Documents/repos/dotfiles
./scripts/install-cli-tools.sh
```

## 📋 Orden Correcto de Instalación

### 1. Clonar y Mover Repo
```bash
# Si no está en la ubicación correcta
git clone <tu-repo-url> ~/dotfiles
cd ~/dotfiles
./scripts/init-dotfiles.sh  # Esto lo mueve a ~/Documents/repos/dotfiles
```

### 2. Instalar Todo (Recomendado)
```bash
cd ~/Documents/repos/dotfiles
./scripts/install-cli-tools.sh --all
```

O instalación modular:

```bash
# Opción 1: Instalación básica
./scripts/install-cli-tools.sh --terminal  # Kitty + enlace automático
./scripts/install-cli-tools.sh --shells    # Zsh + Oh-My-Zsh + Powerlevel10k + enlace automático
./scripts/install-cli-tools.sh --editors   # Neovim + NvChad (opcional) + enlace automático

# Opción 2: Paquetes específicos
./scripts/install-cli-tools.sh --packages kitty zsh neovim git fzf ripgrep bat
# Nota: Esto NO enlaza configs automáticamente, solo con las opciones completas
```

### 3. Configurar Powerlevel10k (Primera vez)
```bash
# Después de instalar shells, ejecuta una vez:
p10k configure
```

### 4. Configurar NvChad (Primera vez)
```bash
# Ejecuta neovim y deja que instale plugins:
nvim
# Espera a que termine la instalación
# Presiona 'q' para salir cuando termine
```

## 🎯 Verificar que Todo Funciona

### Verificar Enlaces Simbólicos
```bash
# Kitty
ls -l ~/.config/kitty  # Debe apuntar a ~/Documents/repos/dotfiles/config/kitty

# Zsh
ls -l ~/.zshrc         # Debe apuntar a ~/Documents/repos/dotfiles/config/zsh/.zshrc
ls -l ~/.p10k.zsh      # Debe apuntar a ~/Documents/repos/dotfiles/config/zsh/.p10k.zsh

# Neovim (si tienes config personalizada)
ls -l ~/.config/nvim   # Debe apuntar a ~/Documents/repos/dotfiles/config/nvim
```

### Verificar Plugins de Zsh
```bash
# Reinicia la terminal o ejecuta:
source ~/.zshrc

# Prueba el plugin 'z':
z Documents  # Debe llevarte a ~/Documents

# Prueba 'sudo':
# Escribe un comando y presiona ESC dos veces para agregar sudo

# Prueba web-search:
google dotfiles  # Debe abrir Google en el navegador
```

### Verificar Powerlevel10k
```bash
# Si ves el prompt de p10k, está funcionando
# Si no, ejecuta:
p10k configure
```

## 📁 Estructura de Archivos Importantes

```
~/Documents/repos/dotfiles/
├── config/
│   ├── kitty/          → ~/.config/kitty/
│   ├── zsh/
│   │   ├── .zshrc      → ~/.zshrc
│   │   ├── .zshenv     → ~/.zshenv
│   │   └── .p10k.zsh   → ~/.p10k.zsh
│   ├── nvim/           → ~/.config/nvim/ (si tienes config)
│   └── starship/
│       └── starship.toml → ~/.config/starship.toml
├── scripts/
│   ├── install-cli-tools.sh  ← Script principal
│   ├── init-dotfiles.sh      ← Para mover repo
│   └── distro-utils.sh       ← Funciones compartidas
└── docs/
    └── CLI-INSTALL-GUIDE.md  ← Guía original
```

## 🆘 Solución de Problemas

### "El repositorio no se movió"
```bash
# Ejecuta manualmente:
cd ~/dotfiles  # o donde esté
./scripts/init-dotfiles.sh
# Responde 'Y' cuando pregunte si mover
```

### "Los enlaces no se crearon"
```bash
# Ejecuta manualmente el script de enlace:
cd ~/Documents/repos/dotfiles
./scripts/link-configs.sh
```

### "Powerlevel10k no aparece"
```bash
# Verifica que está instalado:
ls ~/.oh-my-zsh/custom/themes/powerlevel10k

# Si no existe:
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Luego configura:
p10k configure
```

### "NvChad no se instaló"
```bash
# Backup de config anterior (si existe):
mv ~/.config/nvim ~/.config/nvim.bak

# Clonar NvChad:
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

# Abrir neovim:
nvim
```

### "Los plugins de Zsh no funcionan"
```bash
# Verifica que están instalados:
ls ~/.oh-my-zsh/plugins/

# Recarga la config:
source ~/.zshrc

# Si falta alguno, reinstala:
cd ~/Documents/repos/dotfiles
./scripts/install-cli-tools.sh --shells
```

## 🎉 Resumen de Mejoras

✅ **Selección múltiple arreglada** - Ya no regresas al menú constantemente
✅ **Enlace automático** - Los dotfiles se enlazan al instalar
✅ **Powerlevel10k configurado** - Tema moderno instalado y listo
✅ **NvChad en lugar de LazyVim** - Tu editor preferido configurado
✅ **Plugins de Zsh listos** - z, sudo, web-search y más funcionando
✅ **Scripts mejorados** - init-dotfiles.sh mueve el repo correctamente

## 📝 Notas Finales

- **Siempre ejecuta desde ~/Documents/repos/dotfiles** después del init
- **Los enlaces simbólicos son automáticos** con las opciones completas (--shells, --terminal, etc)
- **Para paquetes individuales** usa `--packages` pero deberás enlazar manualmente
- **Configura p10k la primera vez** con `p10k configure`
- **Los plugins ya están en .zshrc**, solo necesitas instalar zsh

¡Disfruta tu entorno configurado! 🚀
