#!/bin/bash

# Script para ejecutar fastfetch con diferentes configuraciones según el terminal

# Check if fastfetch is installed
if ! command -v fastfetch >/dev/null 2>&1; then
    echo "fastfetch is not installed. Install it with: sudo pacman -S fastfetch (Arch) or your package manager"
    return 0 2>/dev/null || exit 0
fi

# Detectar el terminal actual
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # En VS Code, usar ASCII
    fastfetch --config ~/.config/fastfetch/ascii.jsonc
elif [[ "$TERM_PROGRAM" == "kitty" ]] || [[ -n "$KITTY_WINDOW_ID" && "$TERM_PROGRAM" != "vscode" ]]; then
    # En Kitty real, usar imagen real
    fastfetch --config ~/.config/fastfetch/kitty.jsonc
else
    # Para otros terminales, usar ASCII por defecto
    fastfetch --config ~/.config/fastfetch/ascii.jsonc
fi
