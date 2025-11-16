# Hyprland Configuration - Modular Setup

Este directorio contiene una configuración modular de Hyprland organizada para facilitar el m### 🖥️ Multi-Monitor Support
- `Super + Alt + M` - Auto-configurar monitores
- `Super + Alt + Shift + M` - Alternar modo single/dual
- `Super + Ctrl + Alt + M` - Estado de monitores
- `Super + Ctrl + ←/→` - Enfocar monitor izquierdo/derecho
- `Super + Ctrl + Shift + ←/→` - Mover ventana a monitor izquierdo/derecho
- `Super + Alt + F6` - Detección manual de monitores
- `Super + Alt + Shift + F6` - Reiniciar monitor watcher

**Distribución de workspaces:**
- **Un monitor:** workspaces 1-10 en pantalla principal
- **Dos monitores:** workspaces 1-5 en principal, 6-10 en secundario

**Detección automática:** El sistema detecta automáticamente cuando conectas/desconectas monitores la personalización.

## Estructura de archivos

### Archivo principal
- **`hyprland.conf`** - Archivo principal que carga todos los módulos

### Módulos de configuración
- **`hyprland.conf`** - Archivo principal que carga todos los módulos
- **`autostart.conf`** - Aplicaciones y servicios que se inician automáticamente (¡MEJORADO!)
- **`appearance.conf`** - Configuración visual, animaciones y decoraciones (¡OPTIMIZADO!)
- **`keybinds.conf`** - Todos los atajos de teclado y bindings de mouse (¡MEJORADO!)
- **`windowrules.conf`** - Reglas específicas para aplicaciones y ventanas
- **`variables.conf`** - Variables personalizadas para fácil customización (¡NUEVO!)
- **`advanced.conf`** - Configuraciones avanzadas y optimizaciones (¡NUEVO!)

### Scripts y herramientas
- **`toggle-mode.sh`** - Script para alternar entre modos de rendimiento (¡NUEVO!)
- **`WINDOW_RULES_TODO.md`** - Lista de mejoras pendientes para window rules (¡NUEVO!)

## Nuevas características añadidas

### ✅ Keybindings expandidos (v2.0)
- **Más aplicaciones**: Shortcuts para Discord, Spotify, GIMP, VS Code, etc.
- **Gestión avanzada de ventanas**: Agrupación, centrado, pin de ventanas
- **Shortcuts de productividad**: Picker de emojis, monitor del sistema, notas rápidas
- **Controles multimedia mejorados**: Control fino de volumen y brillo
- **Modo gaming**: Desactivar blur y animaciones para mejor rendimiento
- **Herramientas de desarrollo**: Shortcuts para terminal, editor, Git UI
- **Screenshots avanzados**: Captura de pantalla completa, ventana activa, con editor
- **Navegación de workspaces**: Alt+Tab entre workspaces, movimiento rápido

### ✅ Sistema de variables personalizado
- **Centralización**: Todas las aplicaciones definidas en un solo lugar
- **Fácil personalización**: Cambia tu aplicación preferida editando `variables.conf`
- **Comandos complejos**: Variables para comandos largos y frecuentes
- **Consistencia**: Misma aplicación usada en todos los shortcuts

### ✅ Animaciones optimizadas (v3.0)
- **Mejor rendimiento**: Animaciones más rápidas y suaves
- **Nuevas curvas bezier**: Movimientos más naturales
- **Configuración específica**: Diferentes animaciones por tipo de ventana
- **Optimización de blur**: Configuraciones mejoradas para mejor FPS

### ✅ Autostart mejorado (v4.0)
- **Servicios esenciales**: Audio, red, notificaciones automáticas
- **Aplicaciones organizadas**: Por categorías (productividad, desarrollo, gaming)
- **Configuración modular**: Fácil activar/desactivar grupos de aplicaciones
- **Optimización del sistema**: Variables de entorno y servicios necesarios

### ✅ Configuración avanzada (v5.0)
- **Modos de rendimiento**: Gaming, batería, alto rendimiento
- **Workspaces organizados**: Nombres y asignaciones específicas
- **Layer rules**: Optimizaciones para waybar, notificaciones, launchers
- **Gestures mejorados**: Control táctil avanzado
- **Script de toggle**: Cambio rápido entre modos

## Ventajas de esta organización

1. **Mantenimiento más fácil**: Cada aspecto de la configuración está en su propio archivo
2. **Personalización modular**: Puedes modificar solo las partes que necesites
3. **Respaldo selectivo**: Puedes hacer backup de módulos específicos
4. **Compartir configuraciones**: Fácil intercambio de configuraciones específicas
5. **Depuración simplificada**: Errores más fáciles de localizar

## Cómo personalizar

### Para personalizar aplicaciones preferidas:
Edita `variables.conf` y cambia las variables como:
```bash
$browser = firefox        # Cambia tu navegador preferido
$textEditor = nvim       # Cambia tu editor preferido
$music = spotify         # Cambia tu reproductor de música
```

### Para añadir nuevas aplicaciones al autostart:
Edita `autostart.conf` y añade líneas como:
```bash
exec-once = tu-aplicacion &
```

### Para modificar keybindings:
Edita `keybinds.conf` y añade o modifica bindings:
```bash
bind = $mainMod, tecla, accion, parametros
```

### Para cambiar la apariencia:
Edita `appearance.conf` para modificar:
- Colores de bordes
- Transparencias
- Animaciones
- Blur y efectos

### Para añadir reglas de ventanas:
Edita `windowrules.conf` para aplicaciones específicas:
```bash
windowrulev2 = float,class:^(nombre-clase)$
```

## Nuevos shortcuts útiles

### 🎯 Aplicaciones rápidas
- `Super + D` - Discord
- `Super + Shift + M` - Spotify  
- `Super + G` - GIMP
- `Super + Shift + G` - VS Code
- `Super + A` - Control de audio
- `Super + Shift + A` - Bluetooth

### ⚡ Productividad
- `Super + .` - Selector de emojis
- `Super + ,` - Monitor del sistema (htop)
- `Super + Shift + ,` - Monitor avanzado (btop)
- `Super + /` - Selector de colores
- `Super + I` - Nota rápida
- `Super + V` - Historial del portapapeles

### 🎮 Modo Gaming
- `Super + F1/F2` - Activar/desactivar blur
- `Super + F3/F4` - Activar/desactivar animaciones

### 📸 Screenshots avanzados
- `Print` - Pantalla completa
- `Alt + Print` - Ventana activa
- `Ctrl + Print` - Área con editor
- `Super + Print` - Área al portapapeles

### 🏢 Workspaces
- `Alt + Tab` - Workspace anterior
- `Super + [/]` - Workspace izquierda/derecha
- `Super + Ctrl + [/]` - Mover ventana izquierda/derecha

### 🖥️ Multi-Monitor Support
- `Super + Alt + M` - Auto-configurar monitores
- `Super + Alt + Shift + M` - Alternar modo single/dual
- `Super + Ctrl + Alt + M` - Estado de monitores
- `Super + Ctrl + ←/→` - Enfocar monitor izquierdo/derecho
- `Super + Ctrl + Shift + ←/→` - Mover ventana a monitor izquierdo/derecho
- `Super + Alt + F5` - Detección manual de monitores
- `Super + Alt + Shift + F5` - Reiniciar monitor watcher

**Distribución de workspaces:**
- **Un monitor:** workspaces 1-10 en pantalla principal
- **Dos monitores:** workspaces 1-5 en principal, 6-10 en secundario (izquierda por defecto)

**Detección automática:** El sistema detecta automáticamente cuando conectas/desconectas monitores

## Script de modos de rendimiento

### 🚀 Toggle de modos rápido
```bash
# Cambiar a modo gaming (máximo rendimiento)
~/.config/hypr/toggle-mode.sh gaming

# Cambiar a modo normal
~/.config/hypr/toggle-mode.sh normal

# Modo ahorro de batería
~/.config/hypr/toggle-mode.sh battery

# Ver estado actual
~/.config/hypr/toggle-mode.sh status
```

### 🎮 Modos disponibles:
- **Normal**: Todas las características habilitadas
- **Gaming**: Sin blur, sin animaciones, gaps mínimos
- **Battery**: Optimizado para ahorro de energía
- **Performance**: Balance entre características y rendimiento

## Monitor Manager

### 🖥️ Gestión automática de monitores
```bash
# Auto-configurar monitores (detecta automáticamente)
~/.config/hypr/scripts/monitor-manager.sh auto

# Ver estado actual de monitores
~/.config/hypr/scripts/monitor-manager.sh status

# Alternar entre modo single/dual
~/.config/hypr/scripts/monitor-manager.sh toggle

# Forzar configuración de un solo monitor
~/.config/hypr/scripts/monitor-manager.sh single

# Forzar configuración dual (requiere 2 monitores) - secundario a la izquierda
~/.config/hypr/scripts/monitor-manager.sh dual

# Configurar dual con monitor secundario a la izquierda
~/.config/hypr/scripts/monitor-manager.sh dual-left

# Configurar dual con monitor secundario a la derecha  
~/.config/hypr/scripts/monitor-manager.sh dual-right

# Mover workspace interactivamente
~/.config/hypr/scripts/monitor-manager.sh move
```

### 👁️ Monitor Watcher (Detección Automática)
```bash
# Ver estado del daemon de monitoreo
~/.config/hypr/scripts/monitor-watcher.sh status

# Iniciar/parar daemon de monitoreo
~/.config/hypr/scripts/monitor-watcher.sh start
~/.config/hypr/scripts/monitor-watcher.sh stop

# Activar detección manual
~/.config/hypr/scripts/monitor-watcher.sh trigger

# Ver logs de detección
~/.config/hypr/scripts/monitor-watcher.sh logs
```

### 🔧 Características:
- **Auto-detección**: Detecta automáticamente monitores conectados
- **Hotplug support**: Se reconfigura automáticamente al conectar/desconectar
- **Monitor watcher daemon**: Monitoreo continuo en segundo plano
- **Posicionamiento flexible**: Monitor secundario a izquierda o derecha
- **Workspace distribution**: Distribuye workspaces inteligentemente
- **Wallpaper sync**: Reinicia automáticamente el wallpaper de video
- **Persistent config**: Guarda configuración en `~/.config/hypr/monitors.conf`
- **Keybinds dedicados**: Atajos rápidos para todas las funciones

## Recarga de configuración

Después de hacer cambios, recarga la configuración con:
- `Super + R` (atajo de teclado)
- `hyprctl reload` (en terminal)

## Troubleshooting

Si hay errores después de la reorganización:
1. Verifica que todos los archivos `.conf` existen
2. Revisa la sintaxis en cada módulo
3. Usa `hyprctl reload` para ver mensajes de error
4. Consulta los logs de Hyprland para detalles específicos
