#!/bin/bash

# Script de lanzamiento moderno para wlogout
# Lanzar wlogout con configuración personalizada y supresión de warnings
exec wlogout \
    --layout "$HOME/.config/wlogout/layout" \
    --css "$HOME/.config/wlogout/style.css" \
    --buttons-per-row 3 \
    --column-spacing 30 \
    --row-spacing 30 \
    --protocol layer-shell 2>/dev/null
