# 🔐 SSH Keys Backup

Este directorio contiene **SOLO** las claves SSH **PÚBLICAS** (.pub) de respaldo.

## ⚠️ IMPORTANTE - Seguridad

### ✅ Lo que SÍ se guarda aquí:
- Claves públicas (`.pub`)
- Archivo `config` de SSH
- Este README

### ❌ Lo que NUNCA se debe guardar:
- ❌ Claves privadas (sin extensión .pub)
- ❌ Archivos `id_rsa`, `id_ed25519`, `id_ecdsa` (sin .pub)
- ❌ Cualquier archivo sin extensión .pub

## 🛡️ Protección

El `.gitignore` está configurado para:
```gitignore
ssh-backup/*          # Ignora TODO por defecto
!ssh-backup/*.pub     # EXCEPTO archivos .pub
!ssh-backup/config    # EXCEPTO config
!ssh-backup/README.md # EXCEPTO este README
```

Esto previene accidentalmente subir claves privadas.

## 📝 Uso

### Crear backup de claves SSH:
```bash
./scripts/ssh-manager.sh
# Opción 4: Backup de claves
```

### Restaurar claves SSH:
```bash
./scripts/ssh-manager.sh
# Opción 5: Restaurar claves
```

## 🔄 Transferir entre computadoras

**Computadora A (origen):**
```bash
# Backup
./scripts/ssh-manager.sh  # Opción 4

# Commit y push
git add ssh-backup/
git commit -m "Add SSH public keys"
git push
```

**Computadora B (destino):**
```bash
# Pull
git pull

# Restaurar públicas
./scripts/ssh-manager.sh  # Opción 5

# Copiar privadas manualmente (USB, etc.)
# O crear nuevas claves
```

## 📋 Contenido típico

Después del backup, este directorio contiene:

```
ssh-backup/
├── README.md           (este archivo)
├── config              (configuración SSH)
├── id_ed25519.pub      (clave pública GitHub)
├── id_rsa_work.pub     (clave pública trabajo)
└── id_ecdsa_server.pub (clave pública servidor)
```

## 🚨 Recordatorios

1. **NUNCA** ejecutes `git add ssh-backup/id_*` (sin .pub)
2. Si ves archivos sin `.pub` aquí, **elimínalos inmediatamente**
3. Las claves privadas deben estar solo en `~/.ssh/`
4. Revisa con `git status` antes de hacer commit

## 🔍 Verificar seguridad

```bash
# Ver qué se subirá
git status

# Ver diferencias
git diff ssh-backup/

# Si ves archivos sin .pub:
git reset ssh-backup/archivo_privado
rm ssh-backup/archivo_privado
```

## 📚 Más información

- [ssh-manager.sh](../scripts/ssh-manager.sh) - Script de gestión
- [FEATURES.md](../docs/FEATURES.md) - Documentación completa
- [GitHub SSH Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

**Recuerda**: La seguridad de tus claves SSH es tu responsabilidad. 🔐
