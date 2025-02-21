source /usr/share/cachyos-fish-config/cachyos-config.fish

# Aliases
## generic
alias ..='cd ..'
alias grep='rg'
alias mkdir='mkdir -pv'

## git
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gca='git commit --amend'
alias gcm='git commit -m'
alias gcan='git commit --amend --no-edit'
alias gfp='git fetch -p'
alias gp='git pull'
alias gr='git rebase'
alias gl='git log'
alias gb='git branches'
alias gbr='git branches -r'

## ls
alias ls='eza'
alias l='eza -l --all --group-directories-first --git'
alias ll='eza -l --all --all --group-directories-first --git'
alias lt='eza -T --git-ignore --level=2 --group-directories-first'
alias llt='eza -lT --git-ignore --level=2 --group-directories-first'
alias lT='eza -T --git-ignore --level=4 --group-directories-first'

## ps
alias psmem="ps auxf | sort -nr -k 4"
alias psmem10="ps auxf | sort -nr -k 4 | head -10"

# Paths
## rust
fish_add_path -g ~/.cargo/bin
fish_add_path -g ~/.local/bin

## go
fish_add_path -g /usr/local/go/bin
fish_add_path -g ~/go/bin

## emscripten
# fish_add_path ~/git/emscripten-core/emsdk
# fish_add_path ~/git/emscripten-core/emsdk/upstream/emscripten
# EMSDK_QUIET=1 source ~/git/emscripten-core/emsdk/emsdk_env.fish 2&>/dev/null

if status is-interactive
    # Commands to run in interactive sessions can go here
    # Starship
    source (starship init fish --print-full-init | psub)

    # Start Zellij
    if set -q ZELLIJ; or not set -q ALACRITTY_LOG
    else
        zellij
    end
end
