# Directorio de Paquetes
Este directorio contiene las listas de todos los paquetes instalados en el sistema, exportados automáticamente.
## Contenido
### Archivos generados automáticamente:
- **`pacman-explicit.txt`** - Paquetes oficiales instalados explícitamente (268 paquetes)
- **`pacman-native.txt`** - Todos los paquetes nativos de Arch (1648 paquetes)
- **`aur.txt`** - Paquetes del AUR (49 paquetes)
- **`flatpak.txt`** - Aplicaciones Flatpak (6 paquetes)
- **`snap.txt`** - Paquetes Snap (7 paquetes)
- **`npm-global.txt`** - Paquetes npm instalados globalmente (6 paquetes)
- **`pip-global.txt`** - Paquetes pip instalados globalmente (1 paquete)
- **`RESUMEN.md`** - Resumen con estadísticas y comandos de restauración
## Actualizar listas
Para actualizar las listas de paquetes con lo que tienes instalado actualmente:
```bash
cd ~/dotfiles
./scripts/export-packages.sh
```
O desde el menú principal:
```bash
./install.sh
# Opción 7
```
## Restaurar paquetes
### En una instalación nueva de Arch:
```bash
# 1. Paquetes oficiales (explícitos)
sudo pacman -S --needed $(cat pacman-explicit.txt)
# 2. Instalar yay (helper de AUR)
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
# 3. Paquetes AUR
yay -S --needed $(cat aur.txt)
# 4. Flatpak (si usas)
sudo pacman -S flatpak
while read app; do flatpak install -y flathub "$app"; done < flatpak.txt
# 5. Snap (si usas)
yay -S snapd
sudo systemctl enable --now snapd.socket
while read app; do sudo snap install "$app"; done < snap.txt
```
## Paquetes destacados de tu sistema
### Gaming y Emulación
- `gamehub` - Gestor de juegos
- `heroic-games-launcher-bin` - Epic Games y GOG
- `hydra-launcher-bin` - Launcher de juegos
- `pcsx2` - Emulador PS2
- `sklauncher-bin` - Minecraft launcher
- `elyprismlauncher-bin` - Launcher Minecraft
### Desarrollo
- `android-studio` - Desarrollo Android
- `intellij-idea-ultimate-edition` - IDE Java
- `visual-studio-code-bin` - VS Code
- `eclipse-platform` - Eclipse IDE
- `opencode-bin` - Editor de código
### Multimedia
- `ani-cli` - Ver anime en terminal
- `mpvpaper` - Video como wallpaper
- `youtube-music-bin` - YouTube Music
- `spotify` - Spotify
- `waifu2x-converter-cpp` - Upscaling de imágenes
### Navegadores y Apps
- `zen-browser-bin` - Navegador Zen
- `notion-app-electron` - Notion
- `whatsapp-for-linux-git` - WhatsApp
- `brave-bin` - Brave browser
### Utilidades
- `stacer-bin` - Optimizador de sistema
- `balena-etcher` - Crear USB booteable
- `nomachine` - Acceso remoto
- `netbird` - VPN mesh
- `anki-bin` - Flashcards para aprender
### Diversión
- `bongocat` - Bongo Cat en tu escritorio
- `tty-clock` - Reloj en terminal
- `unimatrix-git` - Efecto Matrix
- `hidamari` - Clima en terminal
### Hyprland/Wayland
- `swaylock-effects` - Lockscreen con efectos
- `wlogout` - Menú de logout
- `mpvpaper` - Video wallpapers
### Sistema
- `paru-bin` - AUR helper alternativo
- `snapd` - Soporte para Snap
- `scrub` - Limpieza de archivos
## Notas
- Las listas se generan automáticamente cada vez que ejecutas el script de backup
- **Importante:** Revisa los paquetes antes de instalar masivamente en un sistema nuevo
- Algunos paquetes AUR pueden requerir dependencias específicas
- Los archivos se actualizan con la fecha actual en `RESUMEN.md`
## Seguridad
Estos archivos **NO contienen:**
- Contraseñas
- Tokens de autenticación
- Configuraciones privadas
Solo contienen los nombres de los paquetes instalados.
---
*Última actualización: 2025-11-15 19:40:25*
*Total de paquetes: 1985 (268 explícitos + 49 AUR + 6 flatpak + 7 snap + 6 npm + 1 pip + resto dependencias)*