# 🔒 Manejo de Permisos y Sudo

## Sistema Implementado

El sistema de dotfiles ahora tiene un **manejo robusto y seguro de permisos sudo**, implementado en todos los scripts principales.

---

## ✅ Características Implementadas

### 1. **Verificación de Usuario**
```bash
check_root()
```
- ❌ **Rechaza ejecución como root** (evita problemas de permisos)
- ✅ Verifica que el usuario esté en el grupo `wheel` o `sudo`
- ✅ Muestra mensaje claro de error con soluciones

**Ejemplo de salida:**
```
[ERROR] ⚠️  NO EJECUTES ESTE SCRIPT COMO ROOT
[ERROR] Usa tu usuario normal. El script pedirá sudo cuando sea necesario.

Ejemplo correcto:
  ./install.sh

Incorrecto:
  sudo ./install.sh  ← ¡NO HAGAS ESTO!
```

### 2. **Verificación de Acceso Sudo**
```bash
check_sudo_access()
```
- ✅ Verifica si el usuario puede usar sudo
- ✅ Detecta si está en grupo wheel/sudo
- ✅ Guía al usuario para configurar sudo si falta

**Si no tienes sudo:**
```
[ERROR] Tu usuario no está en el grupo 'wheel' o 'sudo'
[ERROR] Necesitas permisos de administrador para instalar paquetes

Solución:
  1. Agrega tu usuario al grupo wheel:
     su -c 'usermod -aG wheel valge'
  2. Asegúrate que wheel tiene permisos en /etc/sudoers:
     su -c 'visudo'  # Descomenta: %wheel ALL=(ALL:ALL) ALL
  3. Cierra sesión y vuelve a entrar
```

### 3. **Caché de Contraseña Sudo**
```bash
cache_sudo()
```
- ✅ Pide la contraseña **una sola vez** al inicio
- ✅ Mantiene el caché activo durante toda la instalación
- ✅ Renueva automáticamente cada 4 minutos
- ✅ Proceso en segundo plano para mantener sesión

**Experiencia del usuario:**
```
[INFO] Este script necesita permisos de administrador para instalar paquetes
Por favor, ingresa tu contraseña sudo:
[sudo] password for valge: ********

[SUCCESS] Credenciales sudo verificadas y cacheadas

# A partir de aquí, no se vuelve a pedir contraseña
```

### 4. **Ejecución Segura de Comandos**
```bash
run_sudo comando arg1 arg2
```
- ✅ Ejecuta comandos con sudo de forma centralizada
- ✅ Verifica que el caché esté activo
- ✅ Maneja errores con códigos de salida
- ✅ Registra fallos en el log con contexto

**Ejemplos:**
```bash
# Antes (inseguro)
sudo pacman -S paquete

# Ahora (seguro)
run_sudo pacman -S paquete
```

### 5. **Limpieza al Salir**
```bash
cleanup_sudo()
trap cleanup_sudo EXIT INT TERM
```
- ✅ Mata el proceso de keepalive al finalizar
- ✅ Se ejecuta en salida normal, Ctrl+C, o error
- ✅ No deja procesos huérfanos

---

## 📋 Flujo Completo

### Instalación Normal

```
1. Usuario ejecuta: ./install.sh

2. Script verifica:
   ✓ No se ejecuta como root
   ✓ Usuario está en grupo wheel
   ✓ Usuario puede usar sudo

3. Primera operación que necesita sudo:
   [INFO] Este script necesita permisos de administrador
   Por favor, ingresa tu contraseña sudo:
   [sudo] password: ********
   
4. Caché activado:
   [SUCCESS] Credenciales sudo verificadas y cacheadas
   
5. Proceso keepalive inicia en segundo plano
   (renueva cada 4 minutos)

6. Todas las operaciones sudo usan run_sudo():
   - Instalar paquetes
   - Modificar configuración del sistema
   - Habilitar servicios
   - Actualizar sistema

7. Al finalizar (éxito o error):
   - cleanup_sudo() mata proceso keepalive
   - Caché sudo expira normalmente

8. ¡Instalación completa sin volver a pedir contraseña!
```

---

## 🔧 Scripts Actualizados

### Archivos modificados:

1. **install.sh** (+100 líneas)
   - Funciones de manejo de sudo
   - Verificación de permisos
   - Cache de credenciales
   - Limpieza automática

2. **scripts/install-packages.sh** (+30 líneas)
   - Caché sudo local
   - Reemplazo de todos los `sudo` por `run_sudo`

---

## 🎯 Casos de Uso

### Caso 1: Usuario Normal (Con Sudo)
```bash
$ ./install.sh
[INFO] Este script necesita permisos de administrador
Por favor, ingresa tu contraseña sudo:
[sudo] password for valge: ********

[SUCCESS] Credenciales sudo verificadas y cacheadas
# ... instalación continúa sin más prompts ...
```

### Caso 2: Usuario Sin Sudo
```bash
$ ./install.sh
[ERROR] Tu usuario no está en el grupo 'wheel' o 'sudo'
[ERROR] Necesitas permisos de administrador para instalar paquetes

Solución:
  1. Agrega tu usuario al grupo wheel:
     su -c 'usermod -aG wheel valge'
  ...
```

### Caso 3: Ejecutado Como Root (Incorrecto)
```bash
$ sudo ./install.sh
[ERROR] ⚠️  NO EJECUTES ESTE SCRIPT COMO ROOT
[ERROR] Usa tu usuario normal. El script pedirá sudo cuando sea necesario.

Ejemplo correcto:
  ./install.sh
```

### Caso 4: Usuario Cancela (Ctrl+C)
```bash
$ ./install.sh
[sudo] password: ********
[INFO] Instalando paquetes...
^C
# cleanup_sudo() se ejecuta automáticamente
# Proceso keepalive terminado limpiamente
```

---

## 🔐 Seguridad

### Principios Implementados:

1. **Principio de Mínimo Privilegio**
   - ✅ Solo pide sudo cuando es necesario
   - ✅ No ejecuta todo el script como root
   - ✅ Cada comando sudo es explícito

2. **Verificación Previa**
   - ✅ Valida permisos antes de empezar
   - ✅ Falla rápido si hay problemas
   - ✅ Mensajes claros de error

3. **Limpieza de Recursos**
   - ✅ Mata procesos hijos al salir
   - ✅ No deja sesiones sudo abiertas
   - ✅ Maneja señales de terminación

4. **Transparencia**
   - ✅ Log de todos los comandos sudo
   - ✅ Usuario sabe qué se ejecuta con privilegios
   - ✅ Errores explicados claramente

---

## 🧪 Testing

### Probar Verificaciones:

```bash
# 1. Probar como usuario normal (correcto)
./install.sh

# 2. Probar como root (debe fallar)
sudo ./install.sh
# Debería mostrar: "NO EJECUTES ESTE SCRIPT COMO ROOT"

# 3. Probar sin estar en grupo wheel
# (simular en VM o usuario de prueba)

# 4. Probar Ctrl+C durante instalación
./install.sh
# <durante instalación presiona Ctrl+C>
# Verificar que proceso keepalive termina:
ps aux | grep "sudo -n true"  # No debería estar
```

### Verificar Caché Sudo:

```bash
# Iniciar instalación
./install.sh

# En otra terminal:
watch -n 1 'ps aux | grep -E "(sudo|keepalive)"'

# Deberías ver:
# 1. Proceso principal (./install.sh)
# 2. Proceso keepalive (while true; do sleep 240; sudo -n true)
# 3. Al terminar: ambos desaparecen
```

---

## 💡 Mejores Prácticas

### Para Usuarios:

1. **NUNCA ejecutes con sudo:**
   ```bash
   ❌ sudo ./install.sh
   ✅ ./install.sh
   ```

2. **Asegúrate de estar en grupo wheel:**
   ```bash
   groups | grep wheel
   ```

3. **Si necesitas root, usa su:**
   ```bash
   su -c 'usermod -aG wheel tu_usuario'
   # Luego cierra sesión y entra de nuevo
   ```

### Para Desarrolladores:

1. **Siempre usa run_sudo:**
   ```bash
   ❌ sudo pacman -S paquete
   ✅ run_sudo pacman -S paquete
   ```

2. **Cachea sudo al inicio de scripts largos:**
   ```bash
   cache_sudo || exit 1
   # ... resto del script ...
   ```

3. **Maneja errores de sudo:**
   ```bash
   if ! run_sudo comando; then
       log_error "Falló comando con sudo"
       return 1
   fi
   ```

---

## 📊 Comparación Antes/Después

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| **Verificación inicial** | ❌ No | ✅ Completa |
| **Pide contraseña** | ❌ Múltiples veces | ✅ Una sola vez |
| **Manejo de errores** | ❌ Básico | ✅ Robusto |
| **Limpieza al salir** | ❌ No | ✅ Automática |
| **Mensajes de error** | ❌ Genéricos | ✅ Con soluciones |
| **Detección de root** | ✅ Sí | ✅ Mejorado |
| **Log de comandos sudo** | ❌ No | ✅ Sí |

---

## 🐛 Troubleshooting

### Problema: "sudo: a password is required"
**Causa:** Usuario no está en grupo wheel o sudo no está configurado
**Solución:**
```bash
# Agregar a grupo wheel
su -c 'usermod -aG wheel $USER'

# Verificar configuración sudoers
su -c 'visudo'
# Descomenta: %wheel ALL=(ALL:ALL) ALL

# Cerrar sesión y volver a entrar
```

### Problema: "command not found: run_sudo"
**Causa:** Script antiguo o no se cargaron las funciones
**Solución:**
```bash
# Re-clonar el repositorio
git pull origin master

# O verificar que install.sh tiene las funciones
grep -n "run_sudo()" install.sh
```

### Problema: Proceso keepalive no termina
**Causa:** Script terminó de forma abrupta (kill -9)
**Solución:**
```bash
# Encontrar y matar manualmente
ps aux | grep "sleep 240"
kill <PID>
```

---

## 📚 Referencias

- [Sudo Man Page](https://man.archlinux.org/man/sudo.8)
- [ArchWiki: Sudo](https://wiki.archlinux.org/title/Sudo)
- [ArchWiki: Users and Groups](https://wiki.archlinux.org/title/Users_and_groups)

---

## ✅ Resumen

El sistema ahora:
- ✅ Verifica permisos antes de empezar
- ✅ Pide contraseña una sola vez
- ✅ Mantiene caché activo automáticamente
- ✅ Limpia recursos al terminar
- ✅ Maneja errores robustamente
- ✅ Guía al usuario en problemas
- ✅ Es seguro y transparente

**¡Ya no tendrás que ingresar tu contraseña múltiples veces durante la instalación!** 🎉
