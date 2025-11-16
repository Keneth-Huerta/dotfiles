# 🚀 GUÍA RÁPIDA DE USO

## ⚡ Para instalación inmediata

### Escenario 1: Nueva instalación de Arch Linux
```bash
# Después de instalar Arch base
sudo pacman -S git
git clone https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
# Opción 1 (Instalación completa)
```

### Escenario 2: En la escuela/trabajo (solo herramientas)
```bash
git clone https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
# Opción 8 (Instalación rápida)
```

### Escenario 3: Actualizar configuraciones
```bash
cd ~/dotfiles
git pull
./install.sh
# Opción 5 (Enlazar configs)
```

---

## 📋 Checklist ANTES de usar por primera vez

- [ ] Editar `config.sh` con tu información personal
- [ ] Cambiar `USER_NAME` y `USER_EMAIL`
- [ ] Configurar `GIT_NAME` y `GIT_EMAIL`
- [ ] Elegir tu `DEFAULT_SHELL` (fish/zsh)
- [ ] Verificar conexión a internet
- [ ] Tener permisos sudo

---

## 🎯 Opciones del menú

1. **Instalación completa** → Todo (GUI + apps + configs)
2. **Instalar paquetes** → Solo pacman/AUR/flatpak
3. **Instalar GUI** → Hyprland + SDDM + temas
4. **Herramientas CLI** → vim, zsh, fish, etc.
5. **Enlazar configs** → Crear symlinks
6. **Hacer backup** → Guardar configs actuales
7. **Actualizar sistema** → pacman -Syu
8. **Instalación rápida** → Solo esenciales (5 min)
0. **Salir**

---

## 🔧 Personalización rápida

### Cambiar colores de Hyprland
```bash
nano ~/dotfiles/config/hypr/hyprland.conf
# Buscar: border_color
# Cambiar: rgb(dc143c) por tu color
```

### Cambiar prompt
```bash
nano ~/dotfiles/config/starship/starship.toml
# Editar formato y colores
```

### Agregar alias personalizados
```bash
nano ~/dotfiles/config/fish/config.fish
# O
nano ~/dotfiles/config/zsh/.zshrc
```

---

## 💾 Sincronizar cambios a GitHub

```bash
cd ~/dotfiles
./install.sh  # Opción 6 (backup)
git add .
git commit -m "Update: $(date +%Y-%m-%d)"
git push
```

---

## 🐛 Problemas comunes

### "No hay internet"
```bash
sudo systemctl start NetworkManager
nmtui
```

### "Permission denied"
```bash
chmod +x install.sh
chmod +x scripts/*.sh
```

### "yay no funciona"
```bash
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### "Configs no se aplican"
```bash
cd ~/dotfiles
./scripts/link-configs.sh
```

---

## 📦 Scripts individuales

Si prefieres usar scripts directamente:

```bash
# Solo paquetes
./scripts/install-packages.sh

# Solo GUI
./scripts/install-gui.sh

# Solo CLI tools
./scripts/install-cli-tools.sh

# Enlazar configs
./scripts/link-configs.sh

# Backup
./scripts/backup-configs.sh
```

---

## 🎨 Estructura de configuraciones

```
~/.config/
├── hypr/          → Hyprland
├── waybar/        → Barra superior
├── kitty/         → Terminal
├── fish/          → Fish shell
├── nvim/          → Neovim
├── rofi/          → Launcher
├── dunst/         → Notificaciones
└── starship.toml  → Prompt

~/
├── .zshrc         → Zsh config
├── .gitconfig     → Git config
└── .tmux.conf     → Tmux config
```

---

## ⚠️ IMPORTANTE

1. **Backup primero:** Siempre ejecuta opción 6 antes de cambios grandes
2. **No en root:** No ejecutes como root, usa tu usuario normal
3. **Git config:** El archivo `.gitconfig` contiene tu email, edítalo
4. **Personaliza:** Revisa `config.sh` antes del primer uso

---

## 🚀 Siguiente paso después de instalar

```bash
# Reiniciar el sistema
sudo reboot

# O recargar shell
exec $SHELL

# Verificar
fastfetch
```

---

## 📞 Soporte

Si algo no funciona:
1. Lee el README.md completo
2. Verifica los logs de error
3. Revisa permisos de scripts
4. Asegúrate de tener internet
5. Comprueba que estás en Arch Linux

---

**¡Listo! Ahora tienes un sistema completo de dotfiles automatizado. 🎉**
