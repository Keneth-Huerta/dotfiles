# 🔗 Guía de Enlaces Simbólicos

## ¿Qué es un Enlace Simbólico (Symlink)?

Un **enlace simbólico** es como un "atajo" o "acceso directo" que apunta a otro archivo o carpeta.

### Ejemplo Visual:
```
Tu sistema:                    Tu repositorio:
~/.zshrc  ───────────────→    ~/Documents/repos/dotfiles/config/zsh/.zshrc
(symlink)                      (archivo real)
```

Cuando editas `~/.zshrc`, en realidad estás editando el archivo en tu repo.

---

## 🎯 Ventajas de Usar Symlinks

✅ **Cambios automáticos** - Editas `~/.zshrc` y el cambio ya está en el repo
✅ **Git tracking** - Git detecta los cambios automáticamente
✅ **Sincronización fácil** - Mismo archivo en todas tus computadoras
✅ **Backup automático** - Tus configs siempre están en Git
✅ **Centralizado** - Todo en un solo lugar: tu repo

---

## 📋 Cómo Usar desde install.sh

### Ver Estado de tus Symlinks:
```bash
./install.sh
# Selecciona opción 19) Ver estado de enlaces simbólicos

# Te mostrará:
# ✓ .zshrc → config/zsh/.zshrc (enlazado correctamente)
# ✗ .gitconfig (existe pero NO es symlink)
# ⊘ .tmux.conf (no existe)
```

### Crear/Actualizar Symlinks:
```bash
./install.sh
# Selecciona opción 5) Enlazar configuraciones
```

### Actualizar Configuraciones al Repo:
```bash
./install.sh
# Selecciona opción 18) Actualizar configuraciones al repo

# O directamente:
./scripts/update-dotfiles.sh
```

---

## 🛠️ Comandos Manuales

### Ver si un archivo es symlink:
```bash
ls -la ~/.zshrc

# Si es symlink verás:
# lrwxrwxrwx ... .zshrc -> /home/user/Documents/repos/dotfiles/config/zsh/.zshrc
#                          └─ Esto indica que es un enlace
```

### Crear symlink manualmente:
```bash
# Sintaxis: ln -s ORIGEN DESTINO

# Ejemplo:
ln -s ~/Documents/repos/dotfiles/config/zsh/.zshrc ~/.zshrc

# Esto crea un symlink de ~/.zshrc que apunta al archivo en tu repo
```

### Eliminar un symlink (NO elimina el archivo original):
```bash
rm ~/.zshrc  # Solo elimina el enlace, el archivo en el repo sigue ahí
```

### Reemplazar archivo existente por symlink:
```bash
# 1. Hacer backup del archivo actual
mv ~/.zshrc ~/.zshrc.backup

# 2. Crear el symlink
ln -s ~/Documents/repos/dotfiles/config/zsh/.zshrc ~/.zshrc

# 3. (Opcional) Si quieres usar el contenido del backup:
cp ~/.zshrc.backup ~/Documents/repos/dotfiles/config/zsh/.zshrc
```

---

## 💡 Flujo de Trabajo con Symlinks

### Escenario 1: Archivos YA enlazados
```bash
# 1. Editas tu configuración normalmente
nvim ~/.zshrc

# 2. Los cambios YA ESTÁN en el repo automáticamente
cd ~/Documents/repos/dotfiles
git status  # Verás los cambios

# 3. Solo haces commit
git add config/zsh/.zshrc
git commit -m "Actualizar alias de zsh"
git push
```

### Escenario 2: Archivos NO enlazados
```bash
# 1. Tienes un ~/.zshrc normal (no es symlink)
# 2. Lo actualizas al repo
./scripts/update-dotfiles.sh
# Esto COPIA el archivo al repo

# 3. Luego lo enlazas
./install.sh
# Opción 5) Enlazar configuraciones

# 4. Ahora es symlink, cambios futuros son automáticos
```

---

## 🔍 Verificar Todo el Sistema

### Desde install.sh:
```bash
./install.sh
# Opción 19) Ver estado de enlaces simbólicos
```

### Manualmente con un script:
```bash
# Ver todos los symlinks en tu HOME
find ~ -maxdepth 1 -type l -ls

# Ver symlinks en .config
find ~/.config -maxdepth 2 -type l -ls
```

---

## 📊 Tabla de Archivos Comunes

| Archivo/Carpeta | Ubicación en Sistema | Ubicación en Repo | ¿Debería ser symlink? |
|-----------------|---------------------|-------------------|----------------------|
| `.zshrc` | `~/.zshrc` | `config/zsh/.zshrc` | ✅ Sí |
| `.p10k.zsh` | `~/.p10k.zsh` | `config/zsh/.p10k.zsh` | ✅ Sí |
| `kitty/` | `~/.config/kitty/` | `config/kitty/` | ✅ Sí |
| `nvim/` | `~/.config/nvim/` | `config/nvim/` | ⚠️ Opcional* |
| `starship.toml` | `~/.config/starship.toml` | `config/starship/starship.toml` | ✅ Sí |
| `.gitconfig` | `~/.gitconfig` | `config/git/.gitconfig` | ✅ Sí |
| `hypr/` | `~/.config/hypr/` | `config/hypr/` | ✅ Sí |

\* NvChad genera archivos que no quieres en Git (plugins, cache), considera usar solo configs custom.

---

## ⚠️ Cosas Importantes

### ✅ BIEN:
```bash
# Editar el archivo normalmente
nvim ~/.zshrc

# Git detecta el cambio automáticamente
cd ~/Documents/repos/dotfiles
git status
```

### ❌ MAL:
```bash
# NO hagas esto si usas symlinks:
cp ~/algo/.zshrc ~/.zshrc  # Esto REEMPLAZA el symlink con un archivo

# En su lugar:
cp ~/algo/.zshrc ~/Documents/repos/dotfiles/config/zsh/.zshrc
```

### 🛡️ Recuperar symlink roto:
```bash
# Si accidentalmente reemplazaste el symlink:

# 1. Copia el contenido al repo (si tiene cambios importantes)
cp ~/.zshrc ~/Documents/repos/dotfiles/config/zsh/.zshrc

# 2. Elimina el archivo
rm ~/.zshrc

# 3. Recrea el symlink
ln -s ~/Documents/repos/dotfiles/config/zsh/.zshrc ~/.zshrc
```

---

## 🎯 Quick Reference

```bash
# Ver si es symlink
ls -la ~/.zshrc

# Ver estado de todos los symlinks
./install.sh → opción 19

# Crear symlinks
./install.sh → opción 5

# Actualizar configs al repo
./install.sh → opción 18

# Crear symlink manual
ln -s ~/Documents/repos/dotfiles/config/zsh/.zshrc ~/.zshrc

# Ver a dónde apunta un symlink
readlink -f ~/.zshrc
```

---

## 🚀 Resumen

**Con symlinks:**
1. Editas `~/.zshrc` normalmente
2. El cambio ya está en el repo
3. Solo haces `git commit` y `git push`

**Sin symlinks:**
1. Editas `~/.zshrc`
2. Ejecutas `./scripts/update-dotfiles.sh` para copiar al repo
3. Haces `git commit` y `git push`

**Recomendación:** Usa symlinks, es más fácil y automático 🎉
