# 🔍 Sistema de Gestión de Errores y Logs

## Características Nuevas

### 1. Búsqueda Inteligente de Paquetes

Cuando un paquete no se puede instalar, el sistema:
1. ✅ Intenta instalar el paquete normalmente
2. ✅ Si falla, busca alternativas automáticamente
3. ✅ Intenta instalar las alternativas
4. ✅ Busca en los repositorios paquetes similares
5. ✅ Registra el fallo en un log

### 2. Alternativas Automáticas

El sistema conoce alternativas para paquetes comunes:

| Paquete Original | Alternativas Automáticas |
|-----------------|-------------------------|
| `fastfetch` | `neofetch`, `screenfetch` |
| `exa` / `eza` | `exa`, `eza`, `lsd` |
| `bat` | `batcat` |
| `fd` | `fd-find` |
| `lazygit` | `tig`, `gitui` |

### 3. Log de Paquetes Fallidos

Los paquetes que no se pueden instalar se guardan en:
```
~/.dotfiles-failed-packages.log
```

Formato del log:
```
2026-01-02 17:45:30 | arch | paquete-inexistente | No se encontró en repositorios
2026-01-02 17:45:31 | ubuntu | oh-my-posh-bin | No disponible en esta distribución
```

### 4. Resumen al Final

Al terminar la instalación, se muestra un resumen:

```
════════════════════════════════════════════════════════════
⚠  PAQUETES QUE NO SE PUDIERON INSTALAR
════════════════════════════════════════════════════════════

  ✗ paquete-inexistente
    → No se encontró en repositorios

  ✗ oh-my-posh-bin
    → Instalación manual: https://ohmyposh.dev/docs/installation/linux

ℹ  Log completo guardado en: /home/user/.dotfiles-failed-packages.log

Para instalar manualmente, intenta:
  sudo pacman -S paquete-inexistente oh-my-posh-bin
  yay -S paquete-inexistente oh-my-posh-bin

════════════════════════════════════════════════════════════
```

## Ejemplos de Uso

### Ejemplo 1: Instalación Normal

```bash
./scripts/install-cli-tools.sh --packages git curl htop

# Output:
# [INFO] Instalando paquetes: git curl htop
# [✓] git ya está instalado ✓
# [✓] curl instalado ✓
# [✓] htop instalado ✓
#
# Resumen:
#   ✓ Instalados/Ya instalados: 3
#   ✗ Fallidos: 0
```

### Ejemplo 2: Con Paquetes Inexistentes

```bash
./scripts/install-cli-tools.sh --packages git paquete-falso htop

# Output:
# [INFO] Instalando paquetes: git paquete-falso htop
# [✓] git ya está instalado ✓
# [INFO] Intentando instalar: paquete-falso
# [WARN] Paquete 'paquete-falso' no encontrado, buscando alternativas...
# [WARN] Buscando 'paquete-falso' en repositorios...
# [ERROR] No se pudo instalar: paquete-falso
# [✓] htop instalado ✓
#
# Resumen:
#   ✓ Instalados/Ya instalados: 2
#   ✗ Fallidos: 1
#
# ════════════════════════════════════════════════════════════
# ⚠  PAQUETES QUE NO SE PUDIERON INSTALAR
# ════════════════════════════════════════════════════════════
#
#   ✗ paquete-falso
#
# ℹ  Log completo guardado en: ~/.dotfiles-failed-packages.log
```

### Ejemplo 3: Con Alternativas Automáticas

```bash
./scripts/install-cli-tools.sh --packages fastfetch

# En Ubuntu (donde fastfetch no está disponible):
# [INFO] Intentando instalar: fastfetch
# [WARN] Paquete 'fastfetch' no encontrado, buscando alternativas...
# [INFO] Intentando alternativa: neofetch
# [✓] Instalado alternativa: neofetch (en lugar de fastfetch) ✓
```

## Funciones Nuevas

### `try_install_with_search()`

Intenta instalar un paquete con búsqueda inteligente:

```bash
try_install_with_search "paquete"
# 1. Intenta instalación normal
# 2. Busca alternativas
# 3. Intenta instalar alternativas
# 4. Busca en repositorios
# 5. Registra fallo si todo falla
```

### `log_failed_package()`

Registra un paquete fallido:

```bash
log_failed_package "paquete-nombre" "Razón del fallo"
```

### `show_failed_packages_summary()`

Muestra el resumen de paquetes fallidos:

```bash
show_failed_packages_summary
```

### `suggest_alternative()`

Sugiere alternativas para un paquete:

```bash
suggest_alternative "fastfetch"
# Output: → Alternativas: neofetch screenfetch
```

## Personalización

### Agregar Nuevas Alternativas

Edita `scripts/distro-utils.sh` en la función `try_install_with_search()`:

```bash
case "$pkg" in
    tu-paquete)
        alternatives=("alternativa1" "alternativa2")
        ;;
    # ... más casos
esac
```

### Agregar Sugerencias

Edita `suggest_alternative()` para agregar sugerencias personalizadas:

```bash
case "$pkg" in
    tu-paquete)
        echo -e "    ${BLUE}→${NC} Instalación manual: https://tu-url.com"
        return
        ;;
    # ... más casos
esac
```

## Ver el Log de Fallos

```bash
# Ver todo el log
cat ~/.dotfiles-failed-packages.log

# Ver solo de hoy
grep "$(date '+%Y-%m-%d')" ~/.dotfiles-failed-packages.log

# Ver paquetes únicos que han fallado
cut -d'|' -f3 ~/.dotfiles-failed-packages.log | sort -u

# Limpiar el log
rm ~/.dotfiles-failed-packages.log
```

## Probar el Sistema

Ejecuta el script de prueba:

```bash
./scripts/test-install.sh
```

Este script intentará instalar varios paquetes, algunos reales y algunos falsos, para demostrar cómo funciona el sistema de gestión de errores.

## Ventajas

1. ✅ **No se detiene en errores**: Continúa instalando otros paquetes
2. ✅ **Alternativas automáticas**: Busca e instala alternativas sin intervención
3. ✅ **Log persistente**: Registro de todos los fallos para referencia
4. ✅ **Resumen claro**: Muestra qué falló y por qué al final
5. ✅ **Sugerencias útiles**: Proporciona comandos e instrucciones para instalación manual
6. ✅ **Búsqueda inteligente**: Busca en repositorios antes de rendirse

## Solución de Problemas

### El log crece mucho

```bash
# Limpiar logs antiguos (más de 30 días)
find ~/.dotfiles-failed-packages.log -mtime +30 -delete
```

### Ver estadísticas del log

```bash
# Paquetes más problemáticos
cut -d'|' -f3 ~/.dotfiles-failed-packages.log | sort | uniq -c | sort -rn | head -10
```

### Reintentar paquetes fallidos

```bash
# Obtener lista de paquetes fallidos de hoy
failed_pkgs=($(grep "$(date '+%Y-%m-%d')" ~/.dotfiles-failed-packages.log | cut -d'|' -f3 | tr -d ' '))

# Reintentar instalación
./scripts/install-cli-tools.sh --packages "${failed_pkgs[@]}"
```

## Mejoras Futuras

- [ ] Buscar en PPAs/AUR automáticamente
- [ ] Sistema de votación de alternativas (cuál funcionó mejor)
- [ ] Cache de búsquedas exitosas
- [ ] Integración con base de datos de paquetes online
- [ ] Sugerencias basadas en popularidad
- [ ] Notificación cuando un paquete fallido se vuelve disponible

## Ejemplos Reales

### Caso 1: Instalación en Ubuntu

```bash
# Intentar instalar herramientas de Arch en Ubuntu
./scripts/install-cli-tools.sh --packages \
    base-devel \
    yay \
    oh-my-posh-bin \
    fastfetch \
    git

# El sistema:
# - Mapea base-devel → build-essential ✓
# - Salta yay (solo Arch)
# - Salta oh-my-posh-bin (AUR)
# - Busca fastfetch, instala neofetch ✓
# - Instala git ✓
#
# Resumen: 3 instalados, 2 omitidos con sugerencias
```

### Caso 2: Paquetes con Nombres Diferentes

```bash
# En diferentes distros
./scripts/install-cli-tools.sh --packages python python-pip

# Arch: instala python y python-pip
# Ubuntu: instala python3 y python3-pip (mapeo automático)
# Fedora: instala python3 y python3-pip
```

## Conclusión

Este sistema hace que la instalación de paquetes sea más robusta y amigable, permitiendo que el script continúe incluso cuando algunos paquetes no están disponibles, mientras proporciona información útil para la instalación manual.
