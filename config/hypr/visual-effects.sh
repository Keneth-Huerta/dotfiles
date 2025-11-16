#!/bin/bash

# Dynamic Visual Effects Script for Hyprland
# Añade efectos visuales dinámicos y bonitos

HYPR_CONFIG="$HOME/.config/hypr"

# Function to set rainbow border colors (animated)
set_rainbow_borders() {
    echo "🌈 Activando bordes arcoíris dinámicos..."
    hyprctl keyword general:col.active_border "rgba(ff0000ee) rgba(ff8800ee) rgba(ffff00ee) rgba(88ff00ee) rgba(00ff00ee) rgba(00ff88ee) rgba(00ffffff) rgba(0088ffee) rgba(0000ffee) rgba(8800ffee) rgba(ff00ffee) rgba(ff0088ee) 45deg"
    hyprctl keyword general:border_size 3
    notify-send "🌈 Bordes Arcoíris" "Bordes dinámicos activados" -t 2000
}

# Function to set elegant borders
set_elegant_borders() {
    echo "✨ Activando bordes elegantes rojos..."
    hyprctl keyword general:col.active_border "rgba(ff4444ee) rgba(ff0000ee) 45deg"
    hyprctl keyword general:col.inactive_border "rgba(883333aa)"
    hyprctl keyword general:border_size 2
    notify-send "✨ Bordes Elegantes Rojos" "Estilo rojo aplicado" -t 2000
}

# Function to toggle window blur effects
toggle_blur_intensity() {
    current_size=$(hyprctl getoption decoration:blur:size | grep -o '[0-9]*' | head -1)
    
    if [ "$current_size" -eq 8 ]; then
        # Set intense blur
        hyprctl keyword decoration:blur:size 15
        hyprctl keyword decoration:blur:passes 4
        hyprctl keyword decoration:blur:vibrancy 0.3
        notify-send "🌊 Blur Intenso" "Efectos de desenfoque maximizados" -t 2000
    else
        # Set normal blur
        hyprctl keyword decoration:blur:size 8
        hyprctl keyword decoration:blur:passes 3
        hyprctl keyword decoration:blur:vibrancy 0.21
        notify-send "🌊 Blur Normal" "Efectos de desenfoque normalizados" -t 2000
    fi
}

# Function to set animation speed
set_animation_speed() {
    speed=$1
    case $speed in
        "fast")
            hyprctl keyword animations:animation "windows,1,3,bounce,popin 80%"
            hyprctl keyword animations:animation "workspaces,1,4,easeOutQuint,slide"
            notify-send "⚡ Animaciones Rápidas" "Velocidad aumentada" -t 2000
            ;;
        "normal")
            hyprctl keyword animations:animation "windows,1,6,bounce,popin 80%"
            hyprctl keyword animations:animation "workspaces,1,8,easeOutQuint,slide"
            notify-send "🎭 Animaciones Normales" "Velocidad estándar" -t 2000
            ;;
        "slow")
            hyprctl keyword animations:animation "windows,1,10,bounce,popin 80%"
            hyprctl keyword animations:animation "workspaces,1,12,easeOutQuint,slide"
            notify-send "🐌 Animaciones Lentas" "Velocidad reducida para contemplar" -t 2000
            ;;
    esac
}

# Function to cycle through beautiful window rounding
cycle_rounding() {
    current_rounding=$(hyprctl getoption decoration:rounding | grep -o '[0-9]*' | head -1)
    
    case $current_rounding in
        "12")
            hyprctl keyword decoration:rounding 20
            notify-send "🔄 Esquinas Redondeadas" "Rounding: 20px (Extra suave)" -t 2000
            ;;
        "20")
            hyprctl keyword decoration:rounding 5
            notify-send "🔄 Esquinas Redondeadas" "Rounding: 5px (Minimalista)" -t 2000
            ;;
        *)
            hyprctl keyword decoration:rounding 12
            notify-send "🔄 Esquinas Redondeadas" "Rounding: 12px (Elegante)" -t 2000
            ;;
    esac
}

# Function to apply seasonal theme
apply_seasonal_theme() {
    month=$(date +%m)
    
    case $month in
        "12"|"01"|"02") # Winter - Rojos invernales
            hyprctl keyword general:col.active_border "rgba(ff6666ee) rgba(cc3333ee) 45deg"
            hyprctl keyword decoration:blur:vibrancy 0.15
            notify-send "❄️ Tema Invernal Rojo" "Rojos fríos y elegantes aplicados" -t 3000
            ;;
        "03"|"04"|"05") # Spring - Rojos primaverales
            hyprctl keyword general:col.active_border "rgba(ff4444ee) rgba(ff8888ee) 45deg"
            hyprctl keyword decoration:blur:vibrancy 0.25
            notify-send "🌸 Tema Primaveral Rojo" "Rojos frescos y vibrantes aplicados" -t 3000
            ;;
        "06"|"07"|"08") # Summer - Rojos intensos
            hyprctl keyword general:col.active_border "rgba(ff0000ee) rgba(cc0000ee) 45deg"
            hyprctl keyword decoration:blur:vibrancy 0.3
            notify-send "☀️ Tema Veraniego Rojo" "Rojos intensos y brillantes aplicados" -t 3000
            ;;
        "09"|"10"|"11") # Autumn - Rojos otoñales
            hyprctl keyword general:col.active_border "rgba(cc4444ee) rgba(884444ee) 45deg"
            hyprctl keyword decoration:blur:vibrancy 0.2
            notify-send "🍂 Tema Otoñal Rojo" "Rojos cálidos y terrosos aplicados" -t 3000
            ;;
    esac
}

# Function to create particle effect simulation
create_particle_effect() {
    echo "✨ Simulando efectos de partículas con ventanas..."
    
    # Create temporary particle windows
    for i in {1..8}; do
        (sleep 0.1 && kitty --class="particle-$i" -e sh -c "echo '✨'; sleep 2") &
    done
    
    # Apply special rules for particle windows
    hyprctl keyword windowrule "float,class:^particle-.*$"
    hyprctl keyword windowrule "size 50 50,class:^particle-.*$"
    hyprctl keyword windowrule "noborder,class:^particle-.*$"
    hyprctl keyword windowrule "noblur,class:^particle-.*$"
    hyprctl keyword windowrule "opacity 0.7,class:^particle-.*$"
    
    notify-send "✨ Efecto de Partículas" "Simulación visual creada" -t 2000
}

# Main menu
show_menu() {
    echo "🎨 Dynamic Visual Effects for Hyprland"
    echo "======================================"
    echo "1. 🌈 Rainbow borders"
    echo "2. ✨ Elegant borders"
    echo "3. 🌊 Toggle blur intensity"
    echo "4. ⚡ Fast animations"
    echo "5. 🎭 Normal animations"
    echo "6. 🐌 Slow animations"
    echo "7. 🔄 Cycle window rounding"
    echo "8. 🌍 Apply seasonal theme"
    echo "9. ✨ Particle effect simulation"
    echo "0. Exit"
    echo ""
}

# Process command line arguments
case $1 in
    "rainbow") set_rainbow_borders ;;
    "elegant") set_elegant_borders ;;
    "blur") toggle_blur_intensity ;;
    "fast") set_animation_speed "fast" ;;
    "normal") set_animation_speed "normal" ;;
    "slow") set_animation_speed "slow" ;;
    "rounding") cycle_rounding ;;
    "seasonal") apply_seasonal_theme ;;
    "particles") create_particle_effect ;;
    *)
        show_menu
        read -p "Select option (0-9): " choice
        case $choice in
            1) set_rainbow_borders ;;
            2) set_elegant_borders ;;
            3) toggle_blur_intensity ;;
            4) set_animation_speed "fast" ;;
            5) set_animation_speed "normal" ;;
            6) set_animation_speed "slow" ;;
            7) cycle_rounding ;;
            8) apply_seasonal_theme ;;
            9) create_particle_effect ;;
            0) echo "👋 ¡Hasta luego!" ;;
            *) echo "❌ Opción inválida" ;;
        esac
        ;;
esac
