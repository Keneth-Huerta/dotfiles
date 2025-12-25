# Sugerencias de Window Rules - Para Implementar Después

## ** Aplicaciones específicas:**

### Navegadores
- Firefox/Brave en workspace específico
- Reglas de transparencia según estado
- Posicionamiento automático

### Comunicación
- Discord flotante en tamaño específico (workspace 3)
- Telegram centrado y flotante
- Notificaciones persistentes

### Multimedia
- Spotify en workspace 4 con transparencia
- VLC con reglas de fullscreen mejoradas
- Reproductores de música con controles flotantes

### Herramientas del sistema
- pavucontrol (audio) flotante y centrado
- blueman-manager flotante
- Gestores de red centrados

### Desarrollo
- VS Code en workspace 2
- Terminales específicos con transparencia
- IDEs con workspace dedicados

## ** Tipos de ventanas:**

### Ventanas flotantes
- Centrado automático para diálogos
- Tamaños específicos por tipo
- Posicionamiento inteligente

### Diálogos y popups
- Steam popups mejorados
- VSCode popups posicionados
- Menús contextuales optimizados

### Ventanas de configuración
- Siempre flotantes y centradas
- Tamaño mínimo garantizado
- Sin decoraciones innecesarias

### Aplicaciones de gaming
- Desactivar compositor automáticamente
- Fullscreen real para juegos
- Reducir latencia

## ** Comportamientos especiales:**

### Screen sharing
- xwaylandvideobridge invisible
- OBS optimizado
- Zoom/Teams mejorado

### Screenshots
- Flameshot optimizado multi-monitor
- Área de selección mejorada
- Herramientas de edición flotantes

### Lockscreen
- Aplicaciones críticas sobre bloqueo
- Notificaciones importantes visibles
- Controles de emergencia

### Workspace assignment
- Navegadores → workspace 2
- Comunicación → workspace 3  
- Multimedia → workspace 4
- Gaming → workspace 5

## ** Efectos visuales:**

### Transparencias dinámicas
- Terminales: 0.9 activo, 0.8 inactivo
- Navegadores: 0.95 activo, 0.85 inactivo
- Flotan

### Bordes personalizados
- Activo: gradiente rojo
- Gaming: verde
- Desarrollo: azul
- Comunicación: morado

### Animaciones específicas
- Ventanas rápidas: `popin` 
- Aplicaciones pesadas: `slide`
- Diálogos: `fade`

### Blur personalizado
- Terminales: blur alto
- Navegadores: blur medio
- Gaming: sin blur

## ** Casos específicos a implementar:**

### Fixes conocidos
```ini
# Steam popups
windowrule = stayfocused, title:^(Steam)$
windowrule = minsize 1 1, title:^(Steam)$

# VSCode popups 
windowrule = move onscreen cursor, class:^(code)$

# Discord optimización
windowrule = workspace 3, class:^(discord)$
windowrule = opacity 0.95, class:^(discord)$
```

### Gaming optimizations
```ini
# Desactivar efectos para gaming
windowrule = immediate, class:^(steam_app_)(.*)
windowrule = fullscreen, class:^(gamescope)$
windowrule = noborder, class:^(steam_app_)(.*)
```

## ** Notas de implementación:**
- Revisar cada regla con `hyprctl clients`
- Probar orden de precedencia
- Verificar compatibilidad XWayland vs Wayland
- Documentar casos edge
