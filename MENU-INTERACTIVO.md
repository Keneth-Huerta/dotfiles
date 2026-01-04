# 🎯 Menú Interactivo Mejorado

## ❓ ¿Por qué Bash?

**Bash se usó porque:**
- ✅ Viene preinstalado en TODAS las distribuciones Linux
- ✅ Acceso directo a comandos del sistema (`pacman`, `apt`, etc.)
- ✅ Es el estándar para scripts de instalación
- ✅ No requiere compilar ni instalar dependencias

**PERO** se agregó un menú interactivo moderno usando `whiptail`/`dialog` que permite:
- ✅ Selección múltiple con checkbox (Espacio para seleccionar)
- ✅ Interfaz visual más amigable
- ✅ Navegación con flechas
- ✅ Enter para confirmar

---

## 🚀 Cómo Usar el Menú Interactivo

### Opción 1: Desde install.sh
```bash
./install.sh
# Selecciona: 20) Menú interactivo mejorado
```

### Opción 2: Directamente
```bash
./scripts/menu-interactivo.sh
```

---

## 🎨 Características del Menú Interactivo

### Selección Múltiple:
```
┌─────── Instalador de Dotfiles ───────┐
│ Selecciona qué instalar:             │
│                                       │
│ [X] Shells (zsh, fish, powerlevel10k)│
│ [ ] Editores (neovim, NvChad)        │
│ [X] Utilidades CLI (fzf, ripgrep)    │
│ [ ] Herramientas de desarrollo       │
│                                       │
│ Usa: ↑↓ navegar, Espacio seleccionar│
│      Enter confirmar                  │
└───────────────────────────────────────┘
```

**Controles:**
- `↑/↓` - Navegar entre opciones
- `Espacio` - Marcar/desmarcar opción
- `Enter` - Confirmar selección
- `Tab` - Cambiar entre botones (OK/Cancel)
- `Esc` - Cancelar

---

## 🔧 Solución a los Enlaces Rotos

### Problema Detectado:
```
✗ .p10k.zsh (existe pero NO es symlink)
✗ Fish (existe pero NO es symlink)
✗ Wofi (existe pero NO es symlink)
⊘ .zshenv (no existe)
⊘ Tmux (no existe)
```

### Solución Automática:

Ahora cuando ejecutes:
```bash
./install.sh
# Opción 19) Ver estado de enlaces simbólicos
```

Si detecta archivos sin enlazar, **te preguntará si quieres arreglarlos**:
```
💡 Archivos sin enlazar detectados

¿Deseas arreglarlos ahora? (s/n)
```

Si respondes `s`:
1. Hace backup de los archivos existentes (`archivo.backup-20260103-123456`)
2. Crea los symlinks correctos
3. Te muestra qué se arregló

---

## 📋 Comparación: Menú Normal vs Interactivo

### Menú Normal (actual):
```bash
./install.sh
# → Selecciona una opción a la vez
# → Enter después de cada selección
# → Vuelves al menú para la siguiente
```

**Ventajas:**
- Simple y directo
- Funciona en cualquier terminal
- No requiere dependencias

**Desventajas:**
- Solo una opción a la vez
- Más pasos para múltiples instalaciones

---

### Menú Interactivo (nuevo):
```bash
./scripts/menu-interactivo.sh
# → Selecciona MÚLTIPLES opciones con Espacio
# → Enter UNA vez para instalar todo
# → Interfaz visual con checkbox
```

**Ventajas:**
- ✅ Selección múltiple
- ✅ Más rápido para instalar varias cosas
- ✅ Interfaz visual moderna
- ✅ Menos clics/teclas

**Desventajas:**
- Requiere `whiptail` (se instala automáticamente si falta)

---

## 🎯 Casos de Uso

### Caso 1: Instalación Rápida de Varias Cosas
```bash
./scripts/menu-interactivo.sh

# Marcas con Espacio:
# [X] Shells
# [X] Editores  
# [X] CLI Tools

# Enter → Instala todo de una vez
```

### Caso 2: Ver y Arreglar Symlinks
```bash
./install.sh
# Opción 19) Ver estado de enlaces

# Si hay problemas:
¿Deseas arreglarlos ahora? (s/n) s

# Resultado:
Backup: .p10k.zsh.backup-20260103
✓ .p10k.zsh enlazado
✓ Fish enlazado
✓ Wofi enlazado
```

### Caso 3: Actualizar Configs y Commitear
```bash
./install.sh
# Opción 18) Actualizar configuraciones

# El script:
# 1. Copia configs actuales al repo
# 2. Te pregunta si hacer commit
# 3. Te pregunta si hacer push
```

---

## 🆚 ¿Cuándo usar cada uno?

### Usa el Menú Normal (./install.sh):
- Primera instalación
- Necesitas ver todas las opciones
- Quieres más control paso a paso
- Terminal muy básica

### Usa el Menú Interactivo (./scripts/menu-interactivo.sh):
- Ya sabes qué instalar
- Quieres instalar múltiples cosas
- Prefieres interfaz visual
- Instalación más rápida

---

## 🐛 Solución a Problemas Comunes

### "whiptail no encontrado"
```bash
# Arch/Manjaro
sudo pacman -S libnewt

# Ubuntu/Debian
sudo apt install whiptail

# El script lo instala automáticamente si falta
```

### "Los symlinks se rompieron"
```bash
./install.sh
# → Opción 19) Ver estado de enlaces
# → Responde 's' para arreglarlos automáticamente
```

### "Quiero volver a crear los enlaces"
```bash
./install.sh
# → Opción 5) Enlazar configuraciones
# Esto recreará TODOS los enlaces
```

---

## 💡 Tips

1. **Primera vez:** Usa `./install.sh` para ver todas las opciones
2. **Después:** Usa `./scripts/menu-interactivo.sh` para instalar múltiples cosas rápido
3. **Mantenimiento:** Usa opción 18 (Actualizar configs) y 19 (Ver symlinks)

---

## 🎉 Resumen

**Lenguaje:** Bash (estándar, no requiere instalación)
**Menú mejorado:** Agregado con `whiptail` para selección múltiple
**Symlinks rotos:** Ahora se pueden arreglar automáticamente (opción 19)

```bash
# Menú interactivo:
./scripts/menu-interactivo.sh

# Arreglar symlinks:
./install.sh → opción 19

# Actualizar configs:
./install.sh → opción 18
```

¡Ahora es más funcional y fácil de usar! 🚀
