# Documentación
Esta carpeta contiene la documentación completa del sistema de dotfiles v2.0.
## Contenido
### [FEATURES.md](FEATURES.md)
Documentación exhaustiva de todas las características del sistema:
- 10 características principales implementadas
- Sistema de perfiles (6 perfiles predefinidos)
- Detección de hardware
- Modo dry-run
- Sistema de backups
- Verificación post-instalación
- Sistema de hooks
- Detección de conflictos
- Verificación de espacio
- Logs mejorados
- Health check
- Gestión de repositorios Git
- Gestión de claves SSH
- Auto-ubicación del repositorio
**Cuándo leer:** Para entender todas las capacidades del sistema.
---
### [PERMISOS_SUDO.md](PERMISOS_SUDO.md)
Guía completa sobre el sistema de manejo de permisos sudo:
- Cómo funciona el caché de sudo
- Verificación de permisos
- Ejecución segura de comandos
- Limpieza automática
- Troubleshooting de permisos
- Mejores prácticas de seguridad
**Cuándo leer:** 
- Si tienes problemas con permisos
- Quieres entender cómo se maneja sudo
- Necesitas configurar sudo en tu sistema
---
### [REPOSITORIOS_PRIVADOS.md](REPOSITORIOS_PRIVADOS.md)
Guía paso a paso para trabajar con repositorios privados:
- Configuración de SSH para GitHub/GitLab
- Métodos de autenticación (SSH vs HTTPS)
- Solución de errores comunes
- Flujo de trabajo completo
- Tips y mejores prácticas
- Manejo de múltiples claves SSH
**Cuándo leer:**
- Necesitas clonar repositorios privados
- Tienes errores "Permission denied"
- Quieres configurar SSH correctamente
- Trabajas con múltiples equipos
---
## Inicio Rápido
Si es tu primera vez, lee en este orden:
1. **[../README.md](../README.md)** - Introducción y guía de instalación
2. **[FEATURES.md](FEATURES.md)** - Entender qué puede hacer el sistema
3. **[PERMISOS_SUDO.md](PERMISOS_SUDO.md)** - Si tienes problemas con sudo
4. **[REPOSITORIOS_PRIVADOS.md](REPOSITORIOS_PRIVADOS.md)** - Si trabajas con repos privados
---
## Otros Recursos
- [hooks/README.md](../hooks/README.md) - Sistema de hooks
- [ssh-backup/README.md](../ssh-backup/README.md) - Seguridad SSH
- [user-scripts/README.md](../user-scripts/README.md) - Scripts personalizados
- [packages/README.md](../packages/README.md) - Gestión de paquetes
---
## Contribuir a la Documentación
Si encuentras algo que falta o necesita mejorarse:
1. Edita el archivo correspondiente
2. Mantén el formato claro y consistente
3. Agrega ejemplos prácticos
4. Incluye comandos específicos
5. Commit y push
---
## Buscar en la Documentación
```bash
# Buscar en todos los archivos de documentación
grep -r "término" docs/
# Buscar solo en títulos (líneas con #)
grep "^#.*término" docs/*.md
# Buscar comandos específicos
grep "^\`\`\`bash" docs/*.md -A 10
```
---
**Última actualización:** Diciembre 2024  
**Versión:** 2.0