#!/usr/bin/env python3
# ============================================================================
# MENÚ MODERNO CON RICH - Interfaz TUI Elegante
# ============================================================================
# Requiere: pip install rich
# ============================================================================

from rich.console import Console
from rich.prompt import Prompt, Confirm
from rich.panel import Panel
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich import box
from rich.layout import Layout
from rich.text import Text
import subprocess
import sys
import os

console = Console()

# ============================================================================
# BANNER ANIMADO
# ============================================================================

def show_banner():
    console.clear()
    banner = """
    ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
    ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
    ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
    ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
    ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
    ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
    """
    
    panel = Panel(
        Text(banner, style="bold red"),
        title="[bold cyan]Instalador Moderno de Dotfiles[/bold cyan]",
        subtitle="[italic]Powered by Python + Rich[/italic]",
        border_style="bright_blue",
        box=box.DOUBLE
    )
    console.print(panel)
    console.print()

# ============================================================================
# MENÚ PRINCIPAL CON TABLA ELEGANTE
# ============================================================================

def show_main_menu():
    show_banner()
    
    table = Table(
        show_header=True,
        header_style="bold magenta",
        border_style="bright_blue",
        box=box.ROUNDED
    )
    
    table.add_column("#", style="cyan", width=4)
    table.add_column("Componente", style="green")
    table.add_column("Descripción", style="white")
    table.add_column("Estado", justify="center")
    
    components = [
        ("1", "Terminal Tools", "kitty, alacritty, tmux", "⬜"),
        ("2", "Shells", "zsh, fish, oh-my-zsh, p10k", "⬜"),
        ("3", "Editores", "neovim, vim, NvChad", "⬜"),
        ("4", "CLI Utilities", "fzf, ripgrep, bat, eza", "⬜"),
        ("5", "Dev Tools", "node, python, docker, rust", "⬜"),
        ("6", "GUI Environment", "Hyprland, Waybar", "⬜"),
        ("7", "Databases", "postgresql, redis", "⬜"),
    ]
    
    for num, name, desc, status in components:
        table.add_row(num, name, desc, status)
    
    console.print(table)
    console.print()
    
    # Opciones especiales
    console.print("[bold cyan]Opciones Especiales:[/bold cyan]")
    console.print("  [yellow]8[/yellow] - Enlazar configuraciones")
    console.print("  [yellow]9[/yellow] - Actualizar configs al repo")
    console.print("  [yellow]10[/yellow] - Ver estado de symlinks")
    console.print("  [red]0[/red] - Salir")
    console.print()

# ============================================================================
# SELECCIÓN MÚLTIPLE INTERACTIVA
# ============================================================================

def select_components():
    show_main_menu()
    
    console.print("[bold green]💡 Ingresa los números separados por comas (ej: 1,2,3)[/bold green]")
    console.print("[bold green]   O presiona Enter para ver opciones especiales[/bold green]")
    console.print()
    
    selection = Prompt.ask(
        "[bold cyan]Selección[/bold cyan]",
        default=""
    )
    
    if not selection:
        return show_special_menu()
    
    selected = [s.strip() for s in selection.split(',')]
    
    # Confirmar selección
    console.print()
    panel = Panel(
        f"[yellow]Componentes seleccionados: {', '.join(selected)}[/yellow]",
        border_style="yellow"
    )
    console.print(panel)
    
    if Confirm.ask("[bold green]¿Continuar con la instalación?[/bold green]"):
        install_components(selected)
    else:
        console.print("[yellow]Instalación cancelada[/yellow]")

# ============================================================================
# MENÚ DE OPCIONES ESPECIALES
# ============================================================================

def show_special_menu():
    console.clear()
    show_banner()
    
    table = Table(
        show_header=True,
        header_style="bold magenta",
        border_style="bright_blue",
        box=box.ROUNDED
    )
    
    table.add_column("#", style="cyan", width=4)
    table.add_column("Opción", style="green")
    
    options = [
        ("8", "📦 Enlazar configuraciones (symlinks)"),
        ("9", "🔄 Actualizar configs al repositorio"),
        ("10", "🔍 Ver estado de enlaces simbólicos"),
        ("11", "💾 Hacer backup de configs"),
        ("12", "🔑 Gestionar claves SSH"),
        ("13", "❤️  Verificar salud del sistema"),
        ("0", "🚪 Salir"),
    ]
    
    for num, desc in options:
        table.add_row(num, desc)
    
    console.print(table)
    console.print()
    
    choice = Prompt.ask(
        "[bold cyan]Selecciona una opción[/bold cyan]",
        choices=["0", "8", "9", "10", "11", "12", "13"]
    )
    
    execute_special_option(choice)

# ============================================================================
# INSTALACIÓN CON PROGRESO ANIMADO
# ============================================================================

def install_components(selected):
    console.print()
    
    component_map = {
        "1": ("Terminal Tools", "./scripts/install-cli-tools.sh --terminal"),
        "2": ("Shells", "./scripts/install-cli-tools.sh --shells"),
        "3": ("Editores", "./scripts/install-cli-tools.sh --editors"),
        "4": ("CLI Utilities", "./scripts/install-cli-tools.sh --cli"),
        "5": ("Dev Tools", "./scripts/install-cli-tools.sh --dev"),
        "6": ("GUI Environment", "./scripts/install-gui.sh"),
        "7": ("Databases", "./scripts/install-cli-tools.sh --databases"),
    }
    
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console
    ) as progress:
        
        for num in selected:
            if num in component_map:
                name, command = component_map[num]
                task = progress.add_task(f"[cyan]Instalando {name}...", total=None)
                
                result = subprocess.run(
                    command,
                    shell=True,
                    cwd=os.path.dirname(os.path.abspath(__file__)) + "/..",
                    capture_output=True,
                    text=True
                )
                
                progress.remove_task(task)
                
                if result.returncode == 0:
                    console.print(f"[green]✓[/green] {name} instalado correctamente")
                else:
                    console.print(f"[red]✗[/red] Error instalando {name}")
    
    console.print()
    panel = Panel(
        "[bold green]✓ Instalación completada[/bold green]",
        border_style="green",
        box=box.DOUBLE
    )
    console.print(panel)
    console.print()
    
    if Confirm.ask("[cyan]¿Volver al menú principal?[/cyan]"):
        main()

# ============================================================================
# EJECUTAR OPCIÓN ESPECIAL
# ============================================================================

def execute_special_option(choice):
    commands = {
        "8": "./scripts/link-configs.sh",
        "9": "./scripts/update-dotfiles.sh",
        "10": "./install.sh --symlink-status",
        "11": "./scripts/backup-configs.sh",
        "12": "./scripts/ssh-manager.sh",
        "13": "./scripts/health-check.sh",
    }
    
    if choice == "0":
        console.print("[bold green]¡Hasta luego! 👋[/bold green]")
        sys.exit(0)
    
    if choice in commands:
        console.print()
        with console.status(f"[bold cyan]Ejecutando...", spinner="dots"):
            result = subprocess.run(
                commands[choice],
                shell=True,
                cwd=os.path.dirname(os.path.abspath(__file__)) + "/.."
            )
        
        console.print()
        if Confirm.ask("[cyan]¿Volver al menú?[/cyan]"):
            show_special_menu()

# ============================================================================
# MAIN
# ============================================================================

def main():
    try:
        select_components()
    except KeyboardInterrupt:
        console.print("\n[yellow]Instalación cancelada[/yellow]")
        sys.exit(0)

if __name__ == "__main__":
    main()
