---
estado: INMUTABLE
categoria_documental: REPORTE
titulo: Diagnóstico — por qué instaladores, Neovim y symlinks sirven a medias
fecha: 2026-10-18
autor: Keneth Huerta
entorno: Termux (Android), zsh 5.9.2, neovim 0.12.5, repo en ~/Documents/repos/dotfiles
plantilla: NA
---

# Diagnóstico — instaladores, Neovim y symlinks

Reporte del estado del repositorio `dotfiles` tras instalar en Termux. Documenta
por qué varias piezas "funcionan a medias": el conflicto no era de una sola
cosa, sino de tres causas raíz independientes que se suman.

## 0. Resumen ejecutivo

| # | Síntoma observado | Causa raíz | Estado |
|---|---|---|---|
| 1 | `nvim` arranca vacío (sin NvChad) | `config/nvim` registrado como submódulo **sin `.gitmodules`** → carpeta vacía | CORREGIDO |
| 2 | Solo 3 symlinks en `$HOME`; apps sin config | `link-configs.sh` nunca corrió completo; `link_git` apuntaba a un archivo inexistente | CORREGIDO |
| 3 | `.zshrc` con ruta de otra máquina | Línea `export PATH="/home/valge/..."` arrastrada de otro usuario/equipo | CORREGIDO |
| 4 | Instaladores abortan en Termux | `install-packages.sh` con `set -e` + `sudo`/`pacman` directo; `install-gui.sh` sin guard | PARCIAL (ver §4) |
| 5 | `starship` y otras utilidades no instaladas | `install_prompts` no llegó a ejecutarse; fallos silenciados con `2>/dev/null` | PENDIENTE |

## 1. Neovim: submódulo sin `.gitmodules` (corregido)

`config/nvim` estaba en el índice de Git con modo `160000` (gitlink de
submódulo) pero **el repositorio no tenía `.gitmodules`**:

```
$ git ls-tree HEAD config/nvim
160000 commit e3572e1f5e1c297212c3deeb17b7863139ce663e	config/nvim

$ git submodule status
fatal: no submodule mapping found in .gitmodules for path 'config/nvim'
```

Al clonar, Git crea `config/nvim` **vacío** y nunca descarga el contenido.
El symlink `~/.config/nvim → config/nvim` era "válido" pero apuntaba a la nada,
así que `nvim` corría con la configuración por defecto, contradiciendo el
`README.md` (línea 88) y `scripts/install-cli-tools.sh:298-303`, que afirman que
la config incluye NvChad.

El commit `e3572e1` corresponde a `NvChad/starter`. Se restauró el submódulo:

- `.gitmodules` con `path = config/nvim`, `url = https://github.com/NvChad/starter`;
- `git submodule update --init config/nvim` → checkout en `e3572e1` (NvChad v2.5).

Verificación: `~/.config/nvim/init.lua` existe y `git submodule status` queda
limpio. Los plugins se descargan solos en el primer arranque de `nvim`.

## 2. Symlinks: nunca se aplicaron y uno era código muerto (corregido)

En `$HOME` solo existían tres enlaces (`.zshrc`, `.p10k.zsh`, `nvim`). Faltaban
`kitty`, `fastfetch`, `btop`, `starship.toml`, `git`, etc.
`link-configs.sh --all` nunca había corrido de forma completa.

Además, `link_git` (`scripts/link-configs.sh:122`) verificaba
`config/git/.gitconfig`, pero en el repo solo existe
`config/git/.gitconfig.example` (el `.gitconfig` real está en `.gitignore` por
ser dato personal). Resultado: el enlace de Git era **código muerto**.

Correcciones en `scripts/link-configs.sh`:

1. `link_git` ahora: enlaza si existe `config/git/.gitconfig`; si no, conserva
   un `~/.gitconfig` local sin pisarlo; si no hay ninguno, informa y omite.
2. `link_all` es consciente del entorno: en Termux (Android) omite las configs
   de escritorio Wayland (Hyprland, Waybar, Kitty, Rofi, Dunst, Wlogout,
   Swaylock, MPV) y enlaza solo las de CLI (zsh, nvim, starship, tmux, btop,
   fastfetch, ranger).
3. Se ejecutó `./scripts/link-configs.sh --all`: se crearon los symlinks de
   `starship.toml`, `btop` y `fastfetch` (además de re-crear los existentes).

## 3. `.zshrc`: ruta de otra máquina y duplicados (corregido)

`config/zsh/.zshrc` terminaba con:

```
# Added by Antigravity CLI installer
export PATH="/home/valge/.local/bin:$PATH"      # ← usuario/ruta de otra máquina
export PATH="$HOME/.npm-global/bin:$PATH"
# Added by core-termux bun installer
export PATH="/data/data/com.termux/files/home/.cache/.bun/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"            # ← duplicado
```

`/home/valge` no existe en este equipo y el `~/.local/bin` aparecía dos veces.
Se reemplazó por un bloque único y neutro (sin rutas absolutas de una sola
máquina). Verificación: `zsh -n config/zsh/.zshrc` pasa y ya no hay `/home/`
ni `valge`.

Nota: `.zshrc:12` invoca `~/.config/fastfetch/smart-fastfetch.sh`, que antes no
existía porque `fastfetch` no estaba enlazado; con §2 ya resuelve.

## 4. Instaladores (parcialmente corregido; pendiente de fondo)

### 4.1 `install.sh`

- **Opción 3 del menú** llamaba a `install-gui.sh` (100% `pacman`) sin
  protección, aunque el flag `--gui` sí la tenía. En Termux reventaba.
  Corregido: ahora la opción 3 avisa y omite si `PKG_MANAGER != pacman`.
- **`--dry-run` es inerte** (`install.sh:860`): solo asigna la variable y
  retorna; no simula nada.
- El log de instalación muestra `Opción desconocida: +`: se invocó el
  instalador con un argumento no soportado y terminó en el `case` de error.
- **Log duplicado**: cada `log_*` escribe con `tee -a` y además con `>>`
  (`install.sh:166-198`), por eso `.dotfiles-install.log` tiene cada línea dos
  veces.

### 4.2 `scripts/install-packages.sh` (pendiente)

- `set -e` (línea 9): cualquier fallo aborta el script completo.
- Usa `sudo` y `pacman` **directos** (líneas 32, 48, 85, 89, 274, 314…), sin
  pasar por `pkg_install` de `distro-utils.sh`, que sí sabe mapear a `pkg`.
  En Termux no existe `sudo`.
- `install_paru` (línea 303) **no tiene guard de distro** (a diferencia de
  `install_yay`); si se llama fuera de Arch intenta `pacman`.
- Las listas de paquetes incluyen software inexistente en Termux (`firefox`,
  `docker`, `networkmanager`, `mpv`, `thunar`…). `pkg_install` los salta o
  falla paquete por paquete, pero ensucia el resultado.

### 4.3 `scripts/install-gui.sh` (pendiente)

Script íntegramente `pacman`. Mitigado desde el menú, pero sigue sin guard si se
invoca directo (`./scripts/install-gui.sh`).

### 4.4 Flujo completo en Termux

`install.sh → full_install` llama `install-packages.sh --all`,
`install-gui.sh`, `install-cli-tools.sh --all` y `link-configs.sh --all`.
Los tres primeros fallan total o parcialmente en Termux (puntos 4.1-4.3); el
cuarto es el que dejaba el sistema a medias. Las llamadas van con `|| true`,
así que los fallos quedan ocultos y solo se notan al usar las herramientas.

## 5. Instalaciones silenciosamente fallidas (pendiente)

- `starship` no está instalado ni enlazado: `install_prompts` no llegó a
  ejecutarse en la corrida observada. `install_starship`
  (`distro-utils.sh:869`) intenta `pkg_install starship 2>/dev/null` y, si
  falla, cae al instalador oficial de `starship.rs`; los errores se silencian,
  por lo que es fácil no enterarse.
- `config.sh` (con `GIT_NAME`, `GIT_EMAIL`, temas, etc.) solo lo `source`a
  `install.sh`; `install-cli-tools.sh` y `link-configs.sh` no lo cargan, así que
  variables como `GIT_NAME` no se usan en esos flujos.
- `install.sh:ensure_correct_location` fija la ruta destino hard-coded
  (`~/Documents/repos/dotfiles`).

## 6. Criterio de verificación aplicado

- `git submodule status` sin error; `config/nvim/init.lua` presente.
- `zsh -n config/zsh/.zshrc` exitoso; sin `/home/` ni `valge`.
- `link-configs.sh --all` corre en Termux sin crear enlaces de escritorio.
- `~/.config/{starship.toml,btop,fastfetch,nvim}` resuelven al repo.

## 7. Trabajo pendiente (propuesto, no aplicado)

1. `install-packages.sh`: quitar `set -e`; eliminar `sudo`/`pacman` directos y
   delegar todo a `pkg_install`; agregar guard a `install_paru`; filtrar
   paquetes no aplicables a `PKG_MANAGER=pkg`.
2. `install-gui.sh`: guard de distro al inicio (si `PKG_MANAGER != pacman`,
   avisar y salir 0).
3. `install.sh`: implementar `--dry-run` real; unificar el log (una sola
   escritura por línea) y corregir la causa del `Opción desconocida: +`.
4. `install_starship`: dejar de silenciar con `2>/dev/null` y reportar el
   fallo; ser idempotente.
5. Decidir si `config.sh` se carga desde todos los sub-scripts o se elimina de
   los que no lo usan.

## Errata (2026-10-18)

Los puntos §4 y §7 de este reporte se resolvieron en la misma sesión. Cambios
posteriores al sellado de este documento:

- `scripts/install-packages.sh`: eliminado `set -e`; `install_paru` ahora tiene
  guard de distro. Verificado en Termux con `DRY_RUN=true`.
- `scripts/install-gui.sh`: guard de distro en `main()` (omite sin error fuera
  de Arch) y se añadió `log_warn`, que se usaba sin definirse.
- `install.sh`: se unificó el log (una línea por destino); `--dry-run` ahora
  activa el modo simulación y cae al menú; un flag desconocido ya no aborta.
- `scripts/distro-utils.sh`: `DRY_RUN` global; `pkg_update`, `pkg_refresh` y
  `pkg_install` respetan la simulación; `install_starship` deja de silenciar
  errores y verifica el binario; mapeo de `firefox`/`networkmanager` a SKIP en
  Termux.

Con esto, el flujo `install.sh → install-packages.sh` se ejecuta sin abortar en
Termux. Queda como deuda menor: los pasos que clonan git (oh-my-zsh, plugins,
p10k) no respetan `DRY_RUN`.
