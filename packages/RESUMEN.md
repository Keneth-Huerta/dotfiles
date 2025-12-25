#  Resumen de Paquetes Instalados
**Fecha de exportación:** 2025-11-15 19:40:25
**Sistema:** Arch - 6.17.8-arch1-1
## Estadísticas
| Tipo | Cantidad | Archivo |
|------|----------|---------|
| Pacman (explícitos) | 268 | pacman-explicit.txt |
| Pacman (nativos) | 1648 | pacman-native.txt |
| AUR | 49 | aur.txt |
| Flatpak | 6 | flatpak.txt |
| Snap | 7 | snap.txt |
| npm (global) | 6 | npm-global.txt |
| pip (global) | 1 | pip-global.txt |
## Cómo restaurar
### Pacman (explícitos)
```bash
sudo pacman -S --needed $(cat pacman-explicit.txt)
```
### AUR (con yay)
```bash
yay -S --needed $(cat aur.txt)
```
### Flatpak
```bash
while read app; do flatpak install -y flathub "$app"; done < flatpak.txt
```
### Snap
```bash
while read app; do sudo snap install "$app"; done < snap.txt
```
### npm global
```bash
while read pkg; do npm install -g "$pkg"; done < npm-global.txt
```
### pip global
```bash
pip install -r pip-global.txt
```
---
Generado por el sistema de exportación de paquetes