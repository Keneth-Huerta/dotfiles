# ============================================================================
# HOOKS SYSTEM - Pre/Post Installation Hooks
# ============================================================================
# 
# Los hooks permiten ejecutar scripts personalizados en diferentes momentos
# del proceso de instalación:
#
# pre-install.sh   - Antes de iniciar la instalación
# post-install.sh  - Después de completar la instalación
# pre-config.sh    - Antes de crear los symlinks de configuración
# post-config.sh   - Después de crear los symlinks
#
# Todos los hooks son opcionales. Si existen, se ejecutarán automáticamente.
# ============================================================================

# Coloca aquí tus scripts personalizados
# Ejemplo:
#
# hooks/pre-install.sh
# hooks/post-install.sh
# hooks/pre-config.sh
# hooks/post-config.sh
