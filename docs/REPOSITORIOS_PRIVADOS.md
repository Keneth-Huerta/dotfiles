# Guía: Repositorios Privados
## ¿Qué pasa cuando los repos son privados?
Los repositorios privados requieren **autenticación** para clonarse y actualizarse. Hay dos métodos:
### Método 1: SSH (Recomendado)
#### Ventajas
- No necesitas escribir contraseñas
- Más seguro
- Funciona con GitHub, GitLab, Bitbucket
- Compatible con 2FA (autenticación de dos factores)
#### Paso a Paso
**1. Genera tu clave SSH:**
```bash
./scripts/ssh-manager.sh
# Selecciona opción 2: Crear nueva clave SSH
```
**2. Copia la clave pública:**
```bash
./scripts/ssh-manager.sh
# Selecciona opción 3: Copiar clave SSH al portapapeles
```
**3. Agrégala a tu proveedor Git:**
**GitHub:**
- Ve a: https://github.com/settings/keys
- Click en "New SSH key"
- Pega tu clave pública
- Dale un nombre descriptivo (ej: "Arch Linux - Laptop")
**GitLab:**
- Ve a: https://gitlab.com/-/profile/keys
- Pega tu clave pública
- Establece fecha de expiración (opcional)
**Bitbucket:**
- Ve a: https://bitbucket.org/account/settings/ssh-keys/
- Click en "Add key"
- Pega tu clave pública
**4. Verifica la conexión:**
```bash
./scripts/repo-manager.sh
# Selecciona opción 6: Verificar configuración SSH
```
**5. Usa URLs SSH en `repos.list`:**
```bash
# HTTPS (requiere contraseña para repos privados)
https://github.com/usuario/repo-privado.git
# SSH (funciona sin contraseña)
git@github.com:usuario/repo-privado.git
```
**6. Convierte URLs existentes:**
```bash
./scripts/repo-manager.sh
# Selecciona opción 7: Convertir URLs a SSH
```
### Método 2: HTTPS con Token
Si prefieres usar HTTPS, necesitas un **Personal Access Token**:
#### GitHub
1. Ve a: https://github.com/settings/tokens
2. "Generate new token" → "Classic"
3. Selecciona permisos: `repo` (acceso completo a repos)
4. Copia el token
#### Uso
```bash
# Clonar
git clone https://<TOKEN>@github.com/usuario/repo-privado.git
# O configurar credential helper
git config --global credential.helper store
git clone https://github.com/usuario/repo-privado.git
# Te pedirá usuario y token (una sola vez)
```
---
## Diagnóstico de Errores
### Error: "Permission denied (publickey)"
**Causa:** Tu clave SSH no está configurada o no está agregada a GitHub/GitLab
**Solución:**
```bash
# 1. Verifica si tienes claves
ls -la ~/.ssh/
# 2. Si no tienes claves, créalas
./scripts/ssh-manager.sh
# 3. Verifica conexión
ssh -T git@github.com
# 4. Si sale "successfully authenticated" →  funciona
```
### Error: "repository not found"
**Causa:** El repositorio es privado y estás usando HTTPS sin autenticación
**Solución:**
```bash
# Opción 1: Convertir a SSH
./scripts/repo-manager.sh
# Opción 7: Convertir URLs a SSH
# Opción 2: Verificar acceso
# ¿Tienes permisos para ese repo? Verifica en GitHub/GitLab
```
### Error: "fatal: could not read from remote repository"
**Causa:** La clave SSH no está cargada en el agente
**Solución:**
```bash
# Iniciar ssh-agent
eval $(ssh-agent -s)
# Agregar clave
ssh-add ~/.ssh/id_ed25519
# O usar el script
./scripts/ssh-manager.sh
# Opción 6: Configurar ssh-agent
```
---
## Flujo de Trabajo Completo
### Primera Vez (Nuevo Equipo)
```bash
# 1. Clonar dotfiles
git clone git@github.com:tu-usuario/dotfiles.git ~/Documents/repos/dotfiles
cd ~/Documents/repos/dotfiles
# 2. Configurar SSH
./scripts/ssh-manager.sh
# → Opción 2: Crear nueva clave
# → Opción 3: Copiar clave
# → Agregar a GitHub/GitLab
# 3. Auto-detectar repos existentes (si aplica)
./scripts/auto-detect-repos.sh
# 4. Editar repos.list con tus repos privados
nano repos.list
# 5. Verificar SSH
./install.sh
# → Opción 11: Gestión de repositorios
# → Opción 6: Verificar SSH
# 6. Clonar todos tus repos
# → Opción 2: Clonar todos
```
### Sincronizar en Múltiples Equipos
**Equipo A (Trabajo):**
```bash
cd ~/Documents/repos/mi-proyecto
git add .
git commit -m "feat: nueva característica"
git push
```
**Equipo B (Casa):**
```bash
./install.sh
# → Opción 11: Gestión de repositorios
# → Opción 3: Actualizar todos
```
---
## Tips y Mejores Prácticas
### 1. Usa SSH para TODO
```bash
# Configura git para usar SSH por defecto
git config --global url."git@github.com:".insteadOf "https://github.com/"
```
### 2. Múltiples Claves SSH
Si tienes varios proveedores o cuentas:
**~/.ssh/config:**
```ssh
# GitHub personal
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
# GitHub trabajo
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
```
**Uso:**
```bash
# Personal
git clone git@github.com:usuario/repo.git
# Trabajo
git clone git@github-work:empresa/repo.git
# GitLab
git clone git@gitlab.com:usuario/repo.git
```
### 3. Backup Seguro de Claves
```bash
# Solo respalda claves PÚBLICAS (.pub)
./scripts/ssh-manager.sh
# → Opción 4: Backup de claves
# NUNCA compartas claves privadas (sin .pub)
```
### 4. Rotar Claves Regularmente
```bash
# Cada 6-12 meses
# 1. Crear nueva clave
./scripts/ssh-manager.sh
# 2. Agregar a GitHub/GitLab
# 3. Probar con un repo
# 4. Eliminar clave antigua de GitHub/GitLab
# 5. Borrar archivo local
rm ~/.ssh/id_ed25519_old*
```
---
## Verificación del Estado Actual
Tu salida de `status_all` muestra:
### Repositorios con Cambios (14 repos)
```
 tutorias          - 1 archivo nuevo (zip)
 bytebot           - 4 archivos modificados
 Minenfocado       - Muchos archivos .class eliminados (limpieza de build)
 dotfiles          - Cambios en progreso (nuestro trabajo actual)
 paru              - Archivos de build (tar.gz, src/)
```
### ¿Qué hacer?
**Para repos con cambios importantes:**
```bash
cd ~/Documents/repos/bytebot
git add .
git commit -m "chore: actualizar configuración docker"
git push
```
**Para repos con archivos de build:**
```bash
cd ~/Documents/repos/Minenfocado
# Agregar .gitignore para excluir bin/
echo "bin/" >> .gitignore
git add .gitignore
git commit -m "chore: ignore build files"
git push
```
**Para repos limpios (11 repos):**  Todo bien
---
## Resumen Rápido
| Situación | Solución |
|-----------|----------|
| Clonar repo privado | Usar SSH: `git@github.com:usuario/repo.git` |
| Error "Permission denied" | Agregar clave SSH a GitHub/GitLab |
| Múltiples equipos | SSH + repos.list + sync automático |
| Repos ya existen | Usar `auto-detect-repos.sh` |
| Verificar acceso | `./scripts/repo-manager.sh` → Opción 6 |
| Convertir a SSH | `./scripts/repo-manager.sh` → Opción 7 |
---
## Recursos Adicionales
- [GitHub SSH Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [GitLab SSH Docs](https://docs.gitlab.com/ee/user/ssh.html)
- [SSH Key Best Practices](https://www.ssh.com/academy/ssh/keygen)
---
**¿Necesitas ayuda?** 
Ejecuta: `./scripts/repo-manager.sh` → Opción 6 para diagnóstico automático