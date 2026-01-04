# 🎨 Menú Moderno de Instalación

## Descripción

Este menú moderno reemplaza el antiguo menú de whiptail con una interfaz mucho más atractiva y funcional usando **Python + Rich**.

## ¿Por qué Python + Rich?

### ✅ Ventajas vs whiptail/dialog:
- **Interfaz moderna**: Colores, bordes, tablas, progress bars
- **Más flexible**: Puedes personalizar cada elemento
- **Mejor UX**: Feedback visual en tiempo real
- **Multiplataforma**: Funciona en cualquier Linux/Mac/Windows

### ✅ Ventajas vs C/C++:
- **Sin compilación**: No necesitas compilar nada
- **Más fácil de mantener**: Código más legible y modificable
- **Librerías listas**: Rich tiene todo lo que necesitas
- **Desarrollo más rápido**: Agregar features es inmediato

### ✅ Ventajas vs Rust/Go:
- **Preinstalado**: Python ya está en 99% de sistemas Linux
- **No requiere toolchain**: No necesitas instalar rustc o go
- **Más simple**: Para un instalador, Python es perfecto

## Características

### 🎯 Interfaz Visual
```
╔══════════════════════════════════════════════════════════════╗
║   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
║   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
║   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
║   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
║   ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
║   ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
╚══════════════════════════════════════════════════════════════╝
```

### 📋 Tabla de Componentes
```
┌────┬──────────────────────────┬────────────────────────────┬──────────┐
│ #  │ Componente               │ Descripción                │ Estado   │
├────┼──────────────────────────┼────────────────────────────┼──────────┤
│ 1  │ Terminal Tools           │ kitty, alacritty           │ ●        │
│ 2  │ Shells                   │ zsh + p10k, fish          │ ●        │
│ 3  │ Editores                 │ neovim + NvChad            │ ●        │
└────┴──────────────────────────┴────────────────────────────┴──────────┘
```

### ⚡ Progress Bars
```
Instalando Terminal Tools   ━━━━━━━━━━━━━━━━━━━━━━━━ 100% ✓
Instalando Shells          ━━━━━━━━━━━━━━━━━━━━━━━━  75% ◐
```

### 🔧 Menú de Gestión
- ✓ Enlazar configuraciones
- ✓ Backup automático
- ✓ Estado de symlinks
- ✓ Gestión SSH
- ✓ Health check

## Instalación

### Opción 1: Desde el instalador (automático)

```bash
./install.sh
# Seleccionar opción 21
```

El script **automáticamente**:
1. Detecta si Python está instalado
2. Si no, pregunta si quieres instalarlo
3. Instala Rich si es necesario
4. Ejecuta el menú moderno

### Opción 2: Manual

```bash
# Instalar Python (si no lo tienes)
sudo pacman -S python python-pip  # Arch
sudo apt install python3 python3-pip  # Ubuntu/Debian
sudo dnf install python3 python3-pip  # Fedora

# Instalar Rich
pip install --user rich

# Ejecutar
./scripts/instalador
```

### Opción 3: Fallback a menú simple

Si no quieres instalar Python o Rich, el script automáticamente usa un **menú simple en bash puro** que funciona sin dependencias.

## Uso

### Selección Individual
```
Selecciona componentes (ej: 1, 3, 5): 1
```

### Selección Múltiple
```
Selecciona componentes (ej: 1, 3, 5): 1, 2, 3
```

### Rangos
```
Selecciona componentes (ej: 1, 3, 5): 1-5
```

### Combinaciones
```
Selecciona componentes (ej: 1, 3, 5): 1, 3-5, 7
```

## Estructura

```
scripts/
├── instalador              # Launcher inteligente (bash)
│   ├── Detecta Python
│   ├── Instala dependencias si es necesario
│   └── Ejecuta menú moderno o fallback
│
├── menu-moderno.py         # Menú moderno (Python + Rich)
│   ├── Banner animado
│   ├── Tabla de componentes
│   ├── Progress bars
│   ├── Menú de gestión
│   └── Integración con scripts bash
│
└── menu-interactivo.sh     # Menú whiptail (legacy)
    └── Compatibilidad con sistemas viejos
```

## Comparación

| Feature             | whiptail | Python + Rich | C/Rust |
|---------------------|----------|---------------|--------|
| Aspecto Moderno     | ❌       | ✅            | ✅     |
| Sin Compilación     | ✅       | ✅            | ❌     |
| Progress Bars       | ❌       | ✅            | ✅     |
| Tablas Bonitas      | ❌       | ✅            | ⚠️     |
| Fácil Mantener      | ⚠️       | ✅            | ❌     |
| Rápido Desarrollo   | ❌       | ✅            | ❌     |
| Preinstalado        | ⚠️       | ✅            | ❌     |

## Personalización

### Cambiar Colores

Edita `menu-moderno.py`:

```python
# Banner
Panel.fit(
    Text(banner, style="bold red"),  # Cambia 'red' por 'cyan', 'green', etc.
```

### Agregar Componentes

```python
components = {
    # ... componentes existentes ...
    8: {
        "name": "Tu Nuevo Componente",
        "desc": "Descripción",
        "script": "--tu-flag"
    }
}
```

### Cambiar Banner

```python
banner = """
TU BANNER
ASCII ART
AQUÍ
"""
```

## Troubleshooting

### "Rich not found"
```bash
pip install --user rich
# o
python3 -m pip install --user rich
```

### "Python not found"
```bash
# Arch
sudo pacman -S python

# Ubuntu/Debian
sudo apt install python3

# Fedora
sudo dnf install python3
```

### "Permission denied"
```bash
chmod +x scripts/instalador
chmod +x scripts/menu-moderno.py
```

### Volver al menú viejo
Opción 20 en `install.sh` usa whiptail (el menú viejo).

## Screenshots

### Antes (whiptail)
```
┌──────────────────────────────────────────────┐
│ Selecciona componentes:                     │
│                                              │
│ [X] 1. Terminal Tools                       │
│ [ ] 2. Shells                               │
│ [ ] 3. Editores                             │
│                                              │
│      <OK>              <Cancel>             │
└──────────────────────────────────────────────┘
```
❌ Aspecto antiguo  
❌ No muestra estado  
❌ Sin progress feedback

### Después (Python + Rich)
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
│ 4  │ CLI Utilities            │ fzf, ripgrep, bat          │ ●        │
└────┴──────────────────────────┴────────────────────────────┴──────────┘

Instalando Terminal Tools   ━━━━━━━━━━━━━━━━━━━━━━━━ 100% ✓
```
✅ Aspecto moderno  
✅ Muestra estado en tiempo real  
✅ Progress bars animados  
✅ Colores y estilos

## Ventajas Técnicas

### Para el Usuario
- **Más rápido**: Ve qué está pasando en tiempo real
- **Más claro**: Mejor organización visual
- **Más control**: Selección múltiple fácil

### Para el Desarrollador
- **Más mantenible**: Código Python limpio
- **Más extensible**: Agregar features es fácil
- **Más portable**: Funciona en cualquier Linux

## Roadmap

- [ ] Agregar modo dark/light
- [ ] Guardar preferencias de usuario
- [ ] Modo no interactivo (--auto flag)
- [ ] Profiles preconfigurados (gaming, dev, minimal)
- [ ] Detección automática de hardware
- [ ] Estimación de tiempo de instalación
- [ ] Rollback automático en caso de error
- [ ] Logs con formato bonito

## Conclusión

**Python + Rich es la mejor opción para este proyecto** porque:

1. ✅ **Sin compilación** (vs C/Rust)
2. ✅ **Preinstalado** en casi todos los Linux
3. ✅ **Interfaz moderna** (vs whiptail)
4. ✅ **Fácil de mantener** (vs C/Rust)
5. ✅ **Desarrollo rápido** (agregar features toma minutos)
6. ✅ **Multiplataforma** (Linux, Mac, WSL)

El menú **se ve profesional, es funcional y es fácil de modificar**. Perfecto para un proyecto de dotfiles. 🚀
