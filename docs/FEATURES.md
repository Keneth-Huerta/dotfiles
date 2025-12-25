# 🚀 NUEVAS CARACTERÍSTICAS - Dotfiles v2.0

## 📋 Índice
1. [Sistema de Perfiles](#sistema-de-perfiles)
2. [Detección de Hardware](#detección-de-hardware)
3. [Modo Dry-Run](#modo-dry-run)
4. [Sistema de Backups Mejorado](#sistema-de-backups-mejorado)
5. [Verificación Post-Instalación](#verificación-post-instalación)
6. [Sistema de Hooks](#sistema-de-hooks)
7. [Detección de Conflictos](#detección-de-conflictos)
8. [Verificación de Espacio](#verificación-de-espacio)
9. [Health Check](#health-check)
10. [Gestión de Repositorios](#gestión-de-repositorios)
11. [Gestión de Claves SSH](#gestión-de-claves-ssh)
12. [Auto-ubicación del Repositorio](#auto-ubicación-del-repositorio)

---

## 🎯 Sistema de Perfiles

### ¿Qué es?
Perfiles predefinidos que instalan solo lo que necesitas según el uso de tu computadora.

### Perfiles Disponibles

#### 📦 Minimal
Sistema base con Hyprland, ideal para VMs o computadoras con recursos limitados.
- Hyprland + GDM
- Waybar + Kitty
- Zsh básico
- **Sin extras**

#### 🖥️ Desktop
Para uso diario con multimedia y navegación.
- Todo de Minimal +
- Firefox, Chromium
- VLC, MPV
- LibreOffice
- Nautilus

#### 🎮 Gaming
Optimizado para juegos.
- Todo de Desktop +
- Steam, Lutris
- Wine, Winetricks
- GameMode, MangoHUD
- Discord
- **Multilib habilitado**

#### 💻 Developer
Herramientas completas de desarrollo.
- Todo de Minimal +
- IDEs (VS Code, IntelliJ, Android Studio)
- Docker, VirtualBox
- Git, GitHub CLI
- Node.js, Python, Rust, Go, Java

#### 🔒 Pentesting
Para seguridad y pentesting.
- Todo de Developer +
- **BlackArch habilitado**
- Wireshark, Nmap
- Metasploit, BurpSuite
- Aircrack-ng, Hashcat
- VirtualBox

#### 🌟 Full
**Todo incluido** - Gaming + Dev + Pentesting + Multimedia

### Cómo usar

```bash
./install.sh
# Selecciona opción 1 (Instalación completa)
# Se te preguntará qué perfil quieres usar
```

O editar directamente:
```bash
# Cargar perfil en tus scripts
source scripts/profiles/gaming.profile
```

---

## 🔍 Detección de Hardware

### ¿Qué detecta?
- **GPU**: Intel, NVIDIA, AMD (recomienda drivers automáticamente)
- **CPU**: Detecta fabricante y modelo
- **Tipo de sistema**: Laptop vs Desktop
- **Bluetooth**: Si está disponible
- **WiFi**: Detecta dispositivos inalámbricos
- **Touchpad**: Para laptops
- **Audio**: Dispositivos de audio

### Uso

```bash
./install.sh
# Opción 14: Detección de hardware
```

O directamente:
```bash
./scripts/detect-hardware.sh
```

### Ejemplo de salida

```
Detectando GPU...
  ✓ GPU NVIDIA detectada: NVIDIA GeForce RTX 3060

Detectando CPU...
  ✓ CPU: AMD Ryzen 5 5600X

Detectando tipo de sistema...
  ✓ PC de escritorio

Recomendaciones:
  → nvidia
  → nvidia-utils
  → nvidia-settings
```

---

## 🧪 Modo Dry-Run

### ¿Qué es?
Vista previa de lo que se instalará **SIN ejecutar nada**. Perfecto para ver qué hará el script antes de correrlo.

### Cómo usar

```bash
DRY_RUN=true ./install.sh
```

O en scripts individuales:
```bash
DRY_RUN=true ./scripts/install-packages.sh
```

### Ejemplo

```
[DRY-RUN] sudo pacman -S hyprland
[DRY-RUN] sudo pacman -S waybar
[DRY-RUN] Instalaría: kitty
[DRY-RUN] systemctl enable gdm
```

---

## 💾 Sistema de Backups Mejorado

### Características
- **Timestamps**: Cada backup tiene fecha y hora
- **Organizado**: `~/.config-backups/backup-20241224-153045/`
- **Metadata**: Muestra tamaño y cantidad de archivos
- **Script de restauración**: Fácil recuperación

### Uso

**Crear backup:**
```bash
./install.sh
# Opción 6: Backup de configuraciones
```

**Restaurar backup:**
```bash
./install.sh
# Opción 13: Restaurar backup

# O directamente:
./scripts/restore-backup.sh
```

**Listar backups:**
```bash
./scripts/restore-backup.sh
# Opción 2: Listar backups
```

### Estructura

```
~/.config-backups/
├── backup-20241224-120000/
│   ├── hypr/
│   ├── waybar/
│   └── kitty/
├── backup-20241224-153045/
└── backup-20241225-090000/
```

---

## ✅ Verificación Post-Instalación

### ¿Qué hace?
Verifica que todo se instaló correctamente después de la instalación.

### Verifica
- ✓ Paquetes instalados vs. lista de paquetes
- ✓ Servicios habilitados y activos
- ✓ Configuraciones (symlinks) correctos
- ✓ **Re-intenta** instalar paquetes fallidos

### Uso

```bash
./install.sh
# Opción 16: Verificar instalación

# O al final de instalación completa (automático)
```

### Ejemplo

```
╔════════════════════════════════════════════════════╗
║     VERIFICACIÓN DE PAQUETES
╚════════════════════════════════════════════════════╝

✓ hyprland
✓ waybar
✗ some-package

════════════════════════════════════════
Total: 198 | Instalados: 197 | Faltantes: 1
════════════════════════════════════════

¿Deseas intentar instalarlos ahora? [Y/n]:
```

---

## 🪝 Sistema de Hooks

### ¿Qué son?
Scripts personalizados que se ejecutan en momentos específicos del proceso de instalación.

### Hooks Disponibles
- `pre-install.sh` - Antes de instalar
- `post-install.sh` - Después de instalar
- `pre-config.sh` - Antes de crear symlinks
- `post-config.sh` - Después de crear symlinks

### Cómo usar

1. Copia el ejemplo:
```bash
cp hooks/pre-install.sh.example hooks/pre-install.sh
```

2. Edita el hook:
```bash
nano hooks/pre-install.sh
```

3. Hazlo ejecutable:
```bash
chmod +x hooks/pre-install.sh
```

### Ejemplo de uso

```bash
# hooks/post-install.sh
#!/usr/bin/env bash

# Limpiar cache de pacman
sudo pacman -Sc --noconfirm

# Configurar servicios personalizados
systemctl --user enable my-service

# Notificación
notify-send "Instalación completada" "¡Todo listo!"
```

---

## ⚠️ Detección de Conflictos

### ¿Qué detecta?
- Múltiples display managers (GDM, SDDM, LightDM)
- Shells conflictivos en configs
- Paquetes incompatibles

### Uso

Automático al iniciar `install.sh`, pero puedes ejecutarlo manualmente:

```bash
source scripts/install.sh
check_conflicts
```

### Ejemplo

```
Detectando posibles conflictos...
  ⚠ Múltiples display managers detectados: GDM SDDM
  → Esto puede causar conflictos al iniciar el sistema
```

---

## 💽 Verificación de Espacio

### ¿Qué hace?
Verifica que hay suficiente espacio en disco antes de instalar.

### Uso

Automático en instalación completa, o manualmente:

```bash
source scripts/install.sh
check_disk_space 20  # Requiere 20GB
```

### Ejemplo

```
Verificando espacio en disco...
Espacio disponible: 45GB
Espacio requerido: 20GB
✓ Espacio en disco suficiente
```

---

## 🏥 Health Check

### ¿Qué verifica?
- Sistema (Arch Linux, internet, pacman)
- Repositorios (multilib, blackarch)
- Display Manager (GDM/SDDM)
- Componentes de Hyprland
- Shell y Terminal
- Configuraciones (symlinks)
- Servicios (NetworkManager, Docker, Bluetooth)
- AUR helpers (yay, paru)

### Uso

```bash
./install.sh
# Opción 15: Verificar salud del sistema

# O directamente:
./scripts/health-check.sh
```

### Ejemplo

```
╔════════════════════════════════════════════════════╗
║     HEALTH CHECK SYSTEM
╚════════════════════════════════════════════════════╝

[1/9] Sistema
  ✓ Arch Linux detectado
  ✓ Conexión a internet
  ✓ Pacman funcionando

[2/9] Repositorios
  ✓ Repositorio multilib habilitado
  ⚠ BlackArch no configurado

SALUD DEL SISTEMA: 85%
```

---

## 📦 Gestión de Repositorios

### ¿Qué es?
Sistema avanzado para gestionar todos tus repositorios Git en un solo lugar, con soporte para repositorios privados.

### Características
- Clona todos tus repos de una vez
- Actualiza todos con un comando
- Ve el estado de todos con detalles
- Lista organizada en `repos.list`
- **🆕 Auto-detección** de repos existentes
- **🔒 Soporte para repos privados** (SSH/HTTPS)
- **✅ Verificación de configuración SSH**
- **🔄 Conversión automática** a URLs SSH
- Diagnóstico inteligente de errores

### Configurar

1. **Opción A: Auto-detectar repos existentes**
```bash
./scripts/auto-detect-repos.sh
# Escanea ~/Documents/repos, ~/repos, ~/projects, etc.
# Genera repos.list automáticamente
```

2. **Opción B: Crear lista manualmente**
```bash
nano repos.list
```

3. Agregar repositorios:
```
# Repositorios públicos (HTTPS)
https://github.com/usuario/proyecto1
https://github.com/usuario/proyecto2 ~/custom/path

# Repositorios privados (SSH - recomendado)
git@github.com:usuario/privado.git
git@gitlab.com:usuario/otro-privado.git
```

### Uso

```bash
./install.sh
# Opción 11: Gestionar repositorios
# Opción 17: Auto-detectar repositorios existentes

# O directamente:
./scripts/repo-manager.sh
./scripts/auto-detect-repos.sh
```

### Opciones del Repo Manager
1. **Listar** - Ver repos configurados y su estado
2. **Clonar todos** - Clonar todos los repos de la lista
   - Detecta repos privados (SSH)
   - Verifica autenticación SSH
   - Diagnóstico inteligente de errores
3. **Actualizar todos** - `git pull` en todos
   - Detecta cambios sin commit
   - Muestra resumen de actualizaciones
4. **Ver estado** - `git status` detallado en todos
5. **Editar lista** - Editar `repos.list`
6. **🆕 Verificar SSH** - Checa configuración SSH
   - Verifica claves SSH
   - Prueba GitHub/GitLab
   - Estado de ssh-agent
7. **🆕 Convertir a SSH** - Convierte URLs HTTPS a SSH
   - Útil para repos privados
   - Crea backup automático

### Repositorios Privados

Para clonar/actualizar repositorios privados:

**1. Configurar SSH (una vez):**
```bash
./scripts/ssh-manager.sh
# Opción 2: Crear nueva clave
# Opción 3: Copiar clave pública

# Agregar la clave a:
# - GitHub: https://github.com/settings/keys
# - GitLab: https://gitlab.com/-/profile/keys
```

**2. Verificar conexión:**
```bash
./scripts/repo-manager.sh
# Opción 6: Verificar configuración SSH
```

**3. Convertir URLs (si necesario):**
```bash
./scripts/repo-manager.sh
# Opción 7: Convertir URLs a SSH
# Convierte: https://github.com/user/repo.git
# A:         git@github.com:user/repo.git
```

**4. Clonar:**
```bash
./scripts/repo-manager.sh
# Opción 2: Clonar todos
```

📚 **Guía Completa**: Ver [REPOSITORIOS_PRIVADOS.md](REPOSITORIOS_PRIVADOS.md)

### Ejemplo de Salida

**Clonando con verificación SSH:**
```
╔════════════════════════════════════════════════════╗
║     CLONANDO REPOSITORIOS
╚════════════════════════════════════════════════════╝

→ Clonando mi-proyecto-privado...
   Tipo: privado (SSH)
   URL: git@github.com:usuario/mi-proyecto-privado.git
✓ mi-proyecto-privado clonado exitosamente

════════════════════════════════════════
Total: 5 | Clonados: 3 | Fallidos: 0 | Omitidos: 2
════════════════════════════════════════
```

**Estado con detalles:**
```
╔════════════════════════════════════════════════════╗
║     ESTADO DE REPOSITORIOS
╚════════════════════════════════════════════════════╝

▸ proyecto1 (branch: main)
  ✓ Limpio

▸ proyecto2 (branch: develop)
  Cambios:
     M src/main.js
    ?? nuevos-archivos.txt
```

**Verificación SSH:**
```
╔════════════════════════════════════════════════════╗
║     VERIFICACIÓN SSH
╚════════════════════════════════════════════════════╝

✓ Claves SSH encontradas:
   • id_ed25519

→ Verificando GitHub...
✓ GitHub: Autenticado correctamente

→ Verificando GitLab...
✓ GitLab: Autenticado correctamente

✓ ssh-agent está ejecutándose
```

---

## 🔐 Gestión de Claves SSH

### ¿Qué hace?
Gestiona tus claves SSH de forma segura y fácil.

### Características
- Crear nuevas claves (ed25519)
- Listar claves con fingerprints
- Copiar claves al portapapeles
- **Backup seguro** (solo claves públicas)
- Restaurar desde backup
- Configurar ssh-agent

### Uso

```bash
./install.sh
# Opción 12: Gestionar claves SSH

# O directamente:
./scripts/ssh-manager.sh
```

### Crear clave nueva

```
Nombre de la clave: id_github
Email para la clave: tu@email.com

✓ Clave creada exitosamente

Clave pública:
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIxxx... tu@email.com
```

### Backup de claves

```bash
# Solo respalda claves PÚBLICAS (.pub)
# Las privadas NUNCA se suben al repo
./scripts/ssh-manager.sh
# Opción 4: Backup
```

**⚠️ IMPORTANTE**: 
- Solo las claves públicas (`.pub`) se respaldan
- Las claves privadas permanecen en `~/.ssh/`
- El `.gitignore` previene subir claves privadas

### Transferir entre computadoras

1. **Computadora A** (origen):
```bash
# Backup de claves públicas
./scripts/ssh-manager.sh  # Opción 4

# Commit y push
git add ssh-backup/
git commit -m "Add SSH public keys"
git push
```

2. **Computadora B** (destino):
```bash
# Pull del repo
git pull

# Restaurar claves públicas
./scripts/ssh-manager.sh  # Opción 5

# Copiar manualmente las claves privadas (USB, etc.)
```

---

## 📂 Auto-ubicación del Repositorio

### ¿Qué hace?
Mueve automáticamente el repositorio a `~/Documents/repos/dotfiles` si está en otra ubicación.

### Uso

```bash
./scripts/init-dotfiles.sh
```

### Flujo

1. Detecta ubicación actual
2. Si no está en `~/Documents/repos/dotfiles`:
   - Pregunta si quieres moverlo
   - Hace backup si el destino existe
   - Mueve el repositorio
   - Te avisa de la nueva ubicación

### Ejemplo

```
[1/3] Verificando ubicación del repositorio...
⚠ El repositorio está en: /home/user/Downloads/dotfiles
Ubicación recomendada: /home/user/Documents/repos/dotfiles

¿Deseas mover el repositorio? [Y/n]: y

Moviendo repositorio...
✓ Repositorio movido exitosamente
Nueva ubicación: /home/user/Documents/repos/dotfiles

⚠ IMPORTANTE: Ejecuta el script desde la nueva ubicación:
  cd /home/user/Documents/repos/dotfiles
  ./install.sh
```

---

## 🚀 Quick Start - Nuevas Características

### Primera vez en una nueva computadora

```bash
# 1. Clonar el repo
git clone https://github.com/tuusuario/dotfiles
cd dotfiles

# 2. Inicializar (mueve a ubicación correcta)
./scripts/init-dotfiles.sh

# 3. Ejecutar desde la nueva ubicación
cd ~/Documents/repos/dotfiles

# 4. Detectar hardware
./install.sh  # Opción 14

# 5. Elegir perfil e instalar
./install.sh  # Opción 1

# 6. Restaurar claves SSH
./scripts/ssh-manager.sh  # Opción 5

# 7. Clonar tus repos
./scripts/repo-manager.sh  # Opción 2
```

### Transferir configuraciones entre computadoras

**Computadora A:**
```bash
# Backup de todo
./scripts/backup-configs.sh
./scripts/ssh-manager.sh  # Backup SSH
./scripts/export-packages.sh

# Commit y push
git add .
git commit -m "Backup from Computer A"
git push
```

**Computadora B:**
```bash
# Clonar
git clone https://github.com/tuusuario/dotfiles
cd dotfiles

# Inicializar
./scripts/init-dotfiles.sh

# Instalar con el mismo perfil
./install.sh  # Opción 1

# Restaurar SSH y repos
./scripts/ssh-manager.sh  # Opción 5
./scripts/repo-manager.sh  # Opción 2
```

---

## 📊 Comparación de Características

| Característica | Antes | Ahora |
|---------------|-------|-------|
| Perfiles | ❌ | ✅ 6 perfiles |
| Hardware | ❌ Manual | ✅ Auto-detección |
| Dry-Run | ❌ | ✅ |
| Backups | Básico | ✅ Con timestamps |
| Verificación | ❌ | ✅ Post-install |
| Hooks | ❌ | ✅ Pre/Post |
| Conflictos | ❌ | ✅ Auto-detección |
| Espacio | ❌ | ✅ Verificación |
| Health Check | ❌ | ✅ Completo |
| Repos | ❌ Manual | ✅ Auto-gestión |
| SSH | ❌ Manual | ✅ Gestión completa |
| Ubicación | ❌ Manual | ✅ Auto-movimiento |

---

## 🎓 Tips y Mejores Prácticas

### 1. Usar Perfiles
En lugar de instalar todo, usa el perfil apropiado:
- **Laptop de escuela**: Minimal o Desktop
- **PC gaming**: Gaming
- **Workstation**: Developer
- **Laptop personal**: Full

### 2. Health Check Regular
Ejecuta el health check después de:
- Actualizar el sistema
- Instalar nuevos paquetes
- Cambiar configuraciones

### 3. Backups Frecuentes
```bash
# Antes de cambios grandes
./scripts/backup-configs.sh
```

### 4. Gestionar Repos
Mantén `repos.list` actualizado con todos tus proyectos importantes.

### 5. SSH Seguro
- ✅ Respalda claves públicas en el repo
- ❌ NUNCA subas claves privadas
- 💡 Usa diferentes claves para diferentes servicios

### 6. Hooks Personalizados
Crea hooks para:
- Limpieza automática post-install
- Configuraciones específicas de empresa/escuela
- Notificaciones personalizadas

---

## 🐛 Solución de Problemas

### El health check falla
```bash
# Ver detalles
./scripts/health-check.sh

# Verificar servicios específicos
systemctl status NetworkManager
systemctl status gdm
```

### Conflicto de display managers
```bash
# Ver cuál está habilitado
systemctl list-unit-files | grep -E "(gdm|sddm|lightdm)"

# Deshabilitar el no deseado
sudo systemctl disable sddm
sudo systemctl enable gdm
```

### Paquetes no se instalan
```bash
# Verificar
./scripts/post-install-verify.sh

# Reinstalar fallidos manualmente
sudo pacman -S paquete-fallido
```

### No puedo mover el repo
```bash
# Hazlo manualmente
mkdir -p ~/Documents/repos
mv /ubicacion/actual/dotfiles ~/Documents/repos/
cd ~/Documents/repos/dotfiles
```

---

## 📝 Notas Importantes

1. **Perfiles**: El perfil "Full" instala ~200 paquetes (~15-20GB)
2. **Hooks**: Los hooks son opcionales, el script funciona sin ellos
3. **SSH**: Solo las claves `.pub` se respaldan automáticamente
4. **Repos**: Necesitas acceso (SSH configurado) para clonar repos privados
5. **Hardware**: La detección es automática pero las recomendaciones son sugerencias

---

## 🔮 Próximas Características

- [ ] Sincronización automática con GitHub
- [ ] Perfiles personalizados (crear los tuyos)
- [ ] Exportar/Importar configuración completa
- [ ] Dashboard web para gestionar dotfiles
- [ ] Notificaciones de actualización de repos

---

## 📚 Documentación Adicional

- [QUICK_START.md](QUICK_START.md) - Guía rápida de inicio
- [hooks/README.md](hooks/README.md) - Sistema de hooks detallado
- [scripts/profiles/](scripts/profiles/) - Documentación de perfiles

---

**¿Preguntas?** Crea un issue en el repositorio.

**¡Feliz configuración! 🎉**
