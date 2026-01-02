#!/usr/bin/env bash
# ============================================================================
# QUICK START - Inicio Rápido
# ============================================================================
# Comandos más comunes para diferentes escenarios
# ============================================================================

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                     INSTALADOR CLI - INICIO RÁPIDO                       ║
║              Ahora funciona en Arch, Ubuntu, Fedora, y más              ║
╚══════════════════════════════════════════════════════════════════════════╝

📋 COMANDOS MÁS COMUNES:

1️⃣  INSTALACIÓN RÁPIDA (Escuela/Trabajo):
   ./scripts/install-cli-tools.sh --packages kitty zsh neovim git starship

2️⃣  INSTALAR SHELLS + OH-MY-ZSH:
   ./scripts/install-cli-tools.sh --shells

3️⃣  INSTALAR EDITORES (vim, neovim, LazyVim):
   ./scripts/install-cli-tools.sh --editors

4️⃣  INSTALAR UTILIDADES CLI (fzf, ripgrep, bat, htop, etc):
   ./scripts/install-cli-tools.sh --cli

5️⃣  INSTALAR HERRAMIENTAS DE DESARROLLO:
   ./scripts/install-cli-tools.sh --dev

6️⃣  INSTALAR TODO:
   ./scripts/install-cli-tools.sh --all

7️⃣  MODO INTERACTIVO (Menú):
   ./scripts/install-cli-tools.sh

8️⃣  ACTUALIZAR SISTEMA:
   ./scripts/install-cli-tools.sh --update

9️⃣  VER AYUDA:
   ./scripts/install-cli-tools.sh --help

────────────────────────────────────────────────────────────────────────────

💡 EJEMPLOS ESPECÍFICOS:

Solo kitty y zsh:
  ./scripts/install-cli-tools.sh --packages kitty zsh

Setup mínimo de desarrollo:
  ./scripts/install-cli-tools.sh --packages \
    kitty zsh neovim git fzf ripgrep bat htop tmux starship

Setup completo (shells + editor + utilidades):
  ./scripts/install-cli-tools.sh --shells
  ./scripts/install-cli-tools.sh --editors
  ./scripts/install-cli-tools.sh --cli

────────────────────────────────────────────────────────────────────────────

� SISTEMA DE GESTIÓN DE ERRORES:

✅ Búsqueda automática de alternativas
✅ Log de paquetes fallidos: ~/.dotfiles-failed-packages.log
✅ Resumen al final con sugerencias
✅ No se detiene en errores, continúa con los demás paquetes

Ejemplo:
  Si "fastfetch" no está disponible, automáticamente intenta instalar
  "neofetch" o "screenfetch" como alternativa.

Ver más: docs/ERROR-HANDLING.md

────────────────────────────────────────────────────────────────────────────

�🔧 DESPUÉS DE INSTALAR:

1. Vincular configuraciones:
   ./scripts/link-configs.sh

2. Cambiar shell a zsh:
   chsh -s $(which zsh)

3. Reiniciar terminal o:
   source ~/.zshrc

────────────────────────────────────────────────────────────────────────────

📚 DOCUMENTACIÓN:

- Guía completa: docs/CLI-INSTALL-GUIDE.md
- Changelog: CHANGELOG-MULTI-DISTRO.md
- Ver ejemplo: ./scripts/example-usage.sh

────────────────────────────────────────────────────────────────────────────

✨ FUNCIONA EN:
   ✅ Arch Linux (y derivados)
   ✅ Ubuntu / Debian (y derivados)
   ✅ Fedora / RHEL (y derivados)
   ✅ openSUSE
   ✅ Void Linux

────────────────────────────────────────────────────────────────────────────
EOF
