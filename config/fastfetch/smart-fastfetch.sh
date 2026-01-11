#!/bin/bash

# Script para ejecutar fastfetch con diferentes configuraciones según el terminal

# Check if fastfetch is installed
if ! command -v fastfetch >/dev/null 2>&1; then
    echo "fastfetch is not installed. Please install it using your package manager."
    # Exit gracefully whether sourced or executed
    [[ ${BASH_SOURCE[0]} != "${0}" ]] && return 0 || exit 0
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
