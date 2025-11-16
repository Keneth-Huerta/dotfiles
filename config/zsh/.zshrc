# ============================================================================
# CONFIGURACIÓN MODERNA DE ZSH CON ESTILO ROJO PREDOMINANTE
# ============================================================================

# Run Fastfetch con estilo
~/.config/fastfetch/smart-fastfetch.sh

# === VARIABLES DE ENTORNO OPTIMIZADAS ===
export COLORTERM=truecolor
export TERM="xterm-256color"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export BROWSER="zen-browser"

# Configuración de colores rojos para comandos
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;31m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;33m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;32m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === CONFIGURACIÓN DE OH MY ZSH ===
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# === CONFIGURACIÓN DE HISTORIAL AVANZADA ===
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# === CONFIGURACIÓN DE AUTOCOMPLETADO ===
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt CORRECT_ALL

# Configurar alias-finder
zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes
zstyle ':omz:plugins:alias-finder' cheaper yes

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
alias rmk='scrub -p dod $1; shred -zun 10 -v $1'
## Habilitar soporte truecolor para terminales modernos
export COLORTERM=truecolor
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# Alias para cmatrix en rojo
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# === PLUGINS MODERNOS Y OPTIMIZADOS ===
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    # Core functionality
    git 
    z
    extract
    colored-man-pages
    alias-finder
    
    # Enhanced navigation and search
    zsh-autosuggestions 
    zsh-syntax-highlighting 
    zsh-history-substring-search
    
    # Development tools
    docker-compose
    kubectl
    sudo
    
    # System tools  
    systemd
    archlinux
    
    # Productivity
    web-search
    copyfile
    copypath
)

# Configuración específica de plugins
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,bg=none"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true

source $ZSH/oh-my-zsh.sh

# === CONFIGURACIÓN DE COLORES PARA SYNTAX HIGHLIGHTING ===
# Configuración después de cargar oh-my-zsh para mejor legibilidad
if [[ -n "${ZSH_HIGHLIGHT_STYLES}" ]]; then
    # Comandos válidos en verde en lugar de rojo
    ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
    ZSH_HIGHLIGHT_STYLES[function]='fg=cyan'
    # Strings en amarillo suave
    ZSH_HIGHLIGHT_STYLES[string]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
    # Errores en rojo pero más suave
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
fi

# === CONFIGURACIÓN DE RENDIMIENTO ===
# Deshabilitar verificación de actualizaciones automáticas para mejorar velocidad
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true

# Optimización de autocompletado
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# === CONFIGURACIÓN DE COLORES MODERNOS ===
# Configurar colores para herramientas específicas
export EZA_COLORS="ur=31:uw=31:ux=31:ue=31:gr=31:gw=31:gx=31:tr=31:tw=31:tx=31:su=31:sf=31:xa=31"
export BAT_THEME="Monokai Extended Red"

# Configurar FZF con colores rojos
export FZF_DEFAULT_OPTS='
  --color=fg:#ffffff,bg:#000000,hl:#dc143c
  --color=fg+:#ffffff,bg+:#1a1a1a,hl+:#ff4444
  --color=info:#dc143c,prompt:#dc143c,pointer:#ff4444
  --color=marker:#ff4444,spinner:#dc143c,header:#dc143c
  --height=40% --layout=reverse --border --margin=1 --padding=1'

# === ALIASES MODERNOS CON ESTILO ROJO ===
# Reemplazar comandos tradicionales con versiones modernas
alias cat='bat --style=numbers --color=always --theme="Monokai Extended Red"'
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -la --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'  
alias tree='eza --tree --icons --color=always'
alias mc='ranger'

# Navegación inteligente
alias cdi='zi'  # interactive cd with fzf
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git con colores mejorados
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gs='git status'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'

# Utilidades de sistema con colores
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# Aliases específicos para Arch Linux
alias pacman='sudo pacman --color=always'
alias paru='paru --color=always'
alias yay='paru --color=always'

# Aliases de utilidad
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'

# Aliases de seguridad y limpieza
alias rmk='scrub -p dod $1; shred -zun 10 -v $1'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# === FUNCIONES AVANZADAS DE PRODUCTIVIDAD ===

# Función mejorada para extraer archivos
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Función para crear directorio y navegar a él
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Función para buscar archivos con fzf
fzf_find() {
    local file
    file=$(find . -type f 2>/dev/null | fzf --preview 'bat --color=always --style=numbers {}' --preview-window=right:60%:wrap)
    [[ -n $file ]] && ${EDITOR:-vim} "$file"
}

# Aliases cortos para la función fzf_find
alias sf='fzf_find'      # sf = search files
#alias find='fzf_find'    # reemplaza find tradicional con la versión interactiva
alias f='fzf_find'       # super corto

# Función para buscar en historial con fzf
fh() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

# Función para procesos con fzf
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# Función para pentesting - crear estructura de directorios
mkt(){
    mkdir -p {nmap,content,exploits,scripts,web,passwords,notes}
    echo -e "\e[1;31mDirectorios creados para pentesting:\e[0m"
    ls -la
}

# Función para extraer puertos de nmap
extractPorts(){
    if [ ! -f "$1" ]; then
        echo -e "\e[1;31m[!] Error: File not found\e[0m"
        return 1
    fi
    
    ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
    ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
    
    echo -e "\n\e[1;31m[*] Extracting information...\e[0m\n" > extractPorts.tmp
    echo -e "\t\e[1;31m[*] IP Address:\e[0m $ip_address"  >> extractPorts.tmp
    echo -e "\t\e[1;31m[*] Open ports:\e[0m $ports\n"  >> extractPorts.tmp
    echo $ports | tr -d '\n' | xclip -sel clip 2>/dev/null || echo $ports | tr -d '\n' | pbcopy 2>/dev/null
    echo -e "\e[1;31m[*] Ports copied to clipboard\e[0m\n"  >> extractPorts.tmp
    cat extractPorts.tmp; rm extractPorts.tmp
}

# Función para mostrar información del sistema con estilo
sysinfo() {
    echo -e "\e[1;31m=== INFORMACIÓN DEL SISTEMA ===\e[0m"
    echo -e "\e[1;31mUsuario:\e[0m $(whoami)"
    echo -e "\e[1;31mHostname:\e[0m $(hostname)"
    echo -e "\e[1;31mSistema:\e[0m $(uname -sr)"
    echo -e "\e[1;31mUptime:\e[0m $(uptime -p)"
    echo -e "\e[1;31mMemoria:\e[0m $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "\e[1;31mDisco:\e[0m $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " usado)"}')"
}

# Función para colores en man pages
man() {
    env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

# === ALIASES ADICIONALES Y PERSONALIZADOS ===
# Aliases para desarrollo
# alias ff="~/.config/fastfetch/smart-fastfetch.sh"  # Comentado, usamos 'f' para archivos
alias myip="ip route get 1.1.1.1 | grep -oP 'src \K[\d.]+'"
alias ports='ss -tulanp'
alias listen='ss -tlnp'

# Aliases modernos adicionales
alias vi='nvim'
alias vim='nvim'
alias top='htop'
alias ps='ps auxf'
alias mount='mount | column -t'
alias wget='wget -c'
alias ping='ping -c 5'

# Aliases para trabajar con archivos
alias ll='eza -la --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'
alias l='eza --icons --color=always --group-directories-first'
alias lla='eza -lha --icons --color=always --group-directories-first'
alias lt='eza --tree --icons --color=always --level=2'
alias lta='eza --tree --icons --color=always --level=2 -a'

# Alias para unimatrix con colores personalizados
alias unimatrix='unimatrix -c red'
alias cmatrix='cmatrix -C red'

# Aliases para Git con mejor formato
alias glog='git log --oneline --decorate --graph --all'
alias gst='git status -sb'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gaa='git add .'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'

# Aliases para Docker (si está instalado)
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dcp='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'

# Modernizar el comando thefuck
# eval "$(thefuck --alias)"  # Comentado debido a conflictos
#alias fuck='thefuck'  # Alias simple y directo

# === CONFIGURACIÓN DE INTEGRACIÓN Y HERRAMIENTAS ===
# NVM configuration optimizada
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Cargar zoxide si está disponible
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Cargar fzf si está disponible  
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# Duplicados eliminados de aliases
# alias myip="ip route get 1.1.1.1 | grep -oP 'src \K[\d.]+'"
# alias ff="~/.config/fastfetch/smart-fastfetch.sh"
# alias unimatrix='unimatrix -c red'

# === CONFIGURACIÓN DE POWERLEVEL10K ===
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# === CONFIGURACIÓN DE PATH OPTIMIZADA ===
# Agregar directorios al PATH si existen
typeset -U path PATH
path=(
    $HOME/scripts
    $HOME/.local/bin
    $HOME/bin
    /usr/local/bin
    $path
)
export PATH

# === CONFIGURACIÓN FINAL Y LIMPIEZA ===
# Cargar configuración local si existe
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Cargar variables de entorno específicas
[ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"

# === KEYBINDINGS MODERNOS ===
# Navegación mejorada en el historial
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey '^R' fzf-history-widget
bindkey '^T' fzf-file-widget
bindkey '^[c' fzf-cd-widget

# === MENSAJE DE BIENVENIDA (convertido a función) ===
# Función para mostrar información de configuración
show_zsh_info() {
    echo -e "\e[1;31m"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║  🚀 ZSH CONFIGURADO CON ESTILO MODERNO Y COLORES ROJOS 🚀   ║"
    echo "║                                                               ║"
    echo "║  Nuevas funciones y aliases disponibles:                      ║"
    echo "║  • f, sf, find - Buscar archivos con fzf                     ║"
    echo "║  • fh - Buscar en historial                                   ║" 
    echo "║  • fkill - Matar procesos interactivamente                    ║"
    echo "║  • mkt - Crear estructura para pentesting                     ║"
    echo "║  • extractPorts - Extraer puertos de nmap                     ║"
    echo "║  • sysinfo - Información del sistema                          ║"
    echo "║  • mkcd - Crear directorio y navegar                          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "\e[0m"
}

# Para mostrar la información, ejecuta: show_zsh_info

eval $(thefuck --alias)

# VS Code shell integration: load code's zsh integration when running inside VS Code terminal
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
