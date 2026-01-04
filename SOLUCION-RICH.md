# ✅ Solución: Instalación de Rich en Arch Linux

## Problema

En Arch Linux (y derivados), Python usa **PEP 668** (entorno manejado externamente), lo que bloquea la instalación de paquetes con `pip install --user`.

Error que aparecía:
```
error: externally-managed-environment
```

## Solución

### En Arch/Manjaro/EndeavourOS:

```bash
sudo pacman -S python-rich
```

✅ **Ya está instalado en tu sistema!**

### Para Verificar:

```bash
python3 -c "from rich.console import Console; Console().print('[green]✓ Rich funciona![/green]')"
```

## Usar el Menú Moderno

### Opción 1: Desde install.sh

```bash
./install.sh
# Seleccionar opción 21
```

### Opción 2: Directamente

```bash
./scripts/instalador
```

### Opción 3: Menú Python directo

```bash
python3 scripts/menu-moderno.py
```

## Cambios Aplicados

El script `scripts/instalador` ahora:

1. ✅ **Detecta Arch** y usa `pacman` automáticamente
2. ✅ **Métodos alternativos** si no es Arch:
   - `pip install --user --break-system-packages rich` (bypass PEP 668)
   - `pip install --user rich` (normal)
   - `pipx install rich` (si pipx disponible)
   - `sudo pip install rich` (sistema)
   
3. ✅ **Menú fallback** en bash puro si falla todo
4. ✅ **Opción 11** en el menú simple para reintentar instalación

## Resumen

| Distribución | Comando |
|--------------|---------|
| **Arch/Manjaro** | `sudo pacman -S python-rich` |
| **Ubuntu/Debian** | `pip install --user rich` |
| **Fedora** | `pip install --user rich` |
| **Otras** | `pip install --user rich` |

## ¡Listo para Usar!

Ahora puedes ejecutar:

```bash
./install.sh
# Opción 21: Menú Moderno ⭐
```

Y verás el menú con:
- 🎨 Colores y estilos
- 📊 Tablas bonitas
- 📈 Progress bars animados
- ✨ Interfaz moderna

---

**Fecha:** 3 de enero de 2026  
**Estado:** ✅ Resuelto  
**Rich versión:** 14.2.0
