# 🔄 Cómo Actualizar tus Dotfiles

## Método 1: Script Automático (Recomendado) ⚡

```bash
cd ~/Documents/repos/dotfiles
./scripts/update-dotfiles.sh
```

### ¿Qué hace?
1. **Copia** todas tus configuraciones actuales del sistema al repositorio
2. **Detecta** si algún archivo ya está enlazado (lo salta automáticamente)
3. **Muestra** qué se actualizó, qué se saltó
4. **Te pregunta** si quieres hacer commit y push a Git

### Ejemplo de uso:
```bash
./scripts/update-dotfiles.sh

# Te mostrará algo como:
# [Terminal y Shell]
# ✓ Kitty actualizado
# → Zsh config (ya enlazado, saltando)
# ✓ Powerlevel10k actualizado
# ...
# 
# Resumen:
# ✓ Actualizados: 8
# ⊘ Saltados: 5
#
# ¿Deseas hacer commit? (s/n)
```

---

## Método 2: Comandos Git Manuales 📝

### Actualizar y commitear:
```bash
cd ~/Documents/repos/dotfiles

# Ver qué cambió
git status

# Agregar todo
git add .

# Hacer commit
git commit -m "Actualizar configuración de kitty"

# Subir a GitHub/GitLab
git push
```

### Actualizar solo un archivo específico:
```bash
# Copiar manualmente
cp ~/.zshrc ~/Documents/repos/dotfiles/config/zsh/.zshrc

# O si ya está enlazado, los cambios ya están ahí
# Solo hace commit:
cd ~/Documents/repos/dotfiles
git add config/zsh/.zshrc
git commit -m "Actualizar .zshrc"
git push
```

---

## Método 3: Alias Rápido (Opcional) 🚀

Agrega a tu `.zshrc`:
```bash
# Actualizar dotfiles
alias dotup='cd ~/Documents/repos/dotfiles && ./scripts/update-dotfiles.sh'

# Solo commitear cambios
alias dotcommit='cd ~/Documents/repos/dotfiles && git add . && git commit -m "Actualizar configs $(date +%Y-%m-%d)"'

# Commitear y subir
alias dotpush='cd ~/Documents/repos/dotfiles && git add . && git commit -m "Actualizar configs $(date +%Y-%m-%d)" && git push'
```

Luego solo ejecutas:
```bash
dotup      # Actualiza y te pregunta por commit
dotcommit  # Commit rápido con fecha
dotpush    # Commit + push en un comando
```

---

## ¿Qué Configuraciones se Actualizan?

El script `update-dotfiles.sh` sincroniza:

### Terminal y Shell:
- ✅ Kitty (`~/.config/kitty/`)
- ✅ Zsh (`~/.zshrc`, `~/.zshenv`)
- ✅ Powerlevel10k (`~/.p10k.zsh`)
- ✅ Fish (`~/.config/fish/`)

### Editores:
- ✅ Neovim/NvChad (`~/.config/nvim/`)

### CLI Tools:
- ✅ Starship (`~/.config/starship.toml`)
- ✅ Tmux (`~/.tmux.conf`)
- ✅ Git (`~/.gitconfig`)

### System Monitors:
- ✅ Btop (`~/.config/btop/`)
- ✅ Fastfetch (`~/.config/fastfetch/`)

### Wayland/Hyprland (si existe):
- ✅ Hyprland (`~/.config/hypr/`)
- ✅ Waybar (`~/.config/waybar/`)
- ✅ Wofi, Swaylock, WLogout

---

## Flujo de Trabajo Recomendado 💡

### Cuando cambias algo:
```bash
# 1. Haces cambios en tu sistema (ej: editas ~/.zshrc)
nvim ~/.zshrc

# 2. Actualizas el repo
cd ~/Documents/repos/dotfiles
./scripts/update-dotfiles.sh

# 3. El script:
#    - Copia los cambios
#    - Te pregunta si hacer commit
#    - Te pregunta si hacer push

# ¡Listo! Tus cambios están guardados y sincronizados
```

### Si usas enlaces simbólicos:
```bash
# Si tu ~/.zshrc es un symlink al repo,
# los cambios YA ESTÁN en el repo automáticamente

# Solo necesitas:
cd ~/Documents/repos/dotfiles
git add .
git commit -m "Actualizar .zshrc"
git push
```

---

## Tips y Trucos 🎯

### Ver qué archivos están enlazados:
```bash
ls -la ~/.zshrc      # Si apunta a tu repo, dice "-> /home/..."
ls -la ~/.config/kitty/
```

### Actualizar solo Git sin commit automático:
```bash
cd ~/Documents/repos/dotfiles
./scripts/update-dotfiles.sh
# Cuando pregunte por commit, responde 'n'

# Luego haz commit manual:
git add config/zsh/.zshrc config/kitty/
git commit -m "Actualizar tema de kitty y alias de zsh"
git push
```

### Backup antes de actualizar:
```bash
# El script automáticamente hace backup de archivos
# que sobrescribe, creando .old
```

---

## Resumen Rápido ⚡

**Para actualizar TODO:**
```bash
./scripts/update-dotfiles.sh
```

**Para actualizar solo algo específico:**
```bash
cp ~/.zshrc ~/Documents/repos/dotfiles/config/zsh/.zshrc
cd ~/Documents/repos/dotfiles
git add config/zsh/.zshrc
git commit -m "Actualizar .zshrc"
git push
```

**Con alias configurado:**
```bash
dotup      # Actualiza todo
dotpush    # Commit + push rápido
```

¡Así de fácil! 🎉
