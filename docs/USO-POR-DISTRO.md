# 🚀 Uso en Diferentes Distribuciones

## Arch Linux
```bash
./install.sh
```
✅ Funciona completamente, incluyendo Hyprland y AUR

## Fedora / Ubuntu / Debian / Otras
```bash
./install.sh
```
- ⚠️ Mostrará advertencia pero permite continuar
- ✅ Instala herramientas CLI compatibles
- ✅ Vincula configuraciones
- ❌ Salta Hyprland y paquetes específicos de Arch
- 📝 Registra errores en log pero continúa

### Resultado Esperado en Fedora:
```
Sistema detectado: Fedora Linux (fedora)
Gestor de paquetes: dnf

╔══════════════════════════════════════════════════════════════╗
║  ADVERTENCIA: No estás en Arch Linux                         ║
╚══════════════════════════════════════════════════════════════╝

Este script está optimizado para Arch Linux con Hyprland.
Algunas características pueden no funcionar:
  - Instalación de Hyprland (compositor Wayland)
  - Paquetes de AUR
  - Configuraciones específicas de Arch

Herramientas CLI y configuraciones se instalarán normalmente.

¿Deseas continuar? (s/n)
```

## Recomendaciones por Distro

### Fedora
```bash
# Opción 1: Usar install.sh (acepta advertencia)
./install.sh

# Opción 2: Solo CLI (más limpio)
./scripts/install-cli-tools.sh --all
./scripts/link-configs.sh
```

### Ubuntu/Debian
```bash
# Igual que Fedora
./scripts/install-cli-tools.sh --shells
./scripts/install-cli-tools.sh --editors
./scripts/install-cli-tools.sh --cli
./scripts/link-configs.sh
```

## Qué se Instala en Cada Distro

| Componente | Arch | Fedora/Ubuntu | Notas |
|------------|------|---------------|-------|
| Git, curl, wget | ✅ | ✅ | Funciona en todas |
| Zsh + oh-my-zsh | ✅ | ✅ | Funciona en todas |
| Neovim, vim | ✅ | ✅ | Funciona en todas |
| Kitty, alacritty | ✅ | ✅ | Funciona en todas |
| fzf, ripgrep, bat | ✅ | ✅ | Funciona en todas |
| Starship | ✅ | ✅ | Funciona en todas |
| Hyprland | ✅ | ❌ | Solo Arch/AUR |
| Waybar | ✅ | ⚠️ | Puede requerir build manual |
| AUR packages | ✅ | ❌ | Solo Arch |

## Logs y Errores

Todos los errores se registran pero el script continúa:

```bash
# Ver log completo
cat ~/.dotfiles-install.log

# Ver paquetes que fallaron
cat ~/.dotfiles-failed-packages.log

# Ver resumen al final de la instalación
# Se muestra automáticamente
```

## TL;DR

- **Arch**: Usa `./install.sh` - todo funciona
- **Otras**: Usa `./install.sh` (acepta advertencia) o `./scripts/install-cli-tools.sh` (recomendado)
- **Errores**: Se registran pero no detienen la instalación
- **Log**: Revisa `~/.dotfiles-failed-packages.log` para ver qué falló
