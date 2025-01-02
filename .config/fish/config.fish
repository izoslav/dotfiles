if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Aliases
alias ls='eza'
alias l='eza -l --all --group-directories-first --git'
alias ll='eza -l --all --all --group-directories-first --git'
alias lt='eza -T --git-ignore --level=2 --group-directories-first'
alias llt='eza -lT --git-ignore --level=2 --group-directories-first'
alias lT='eza -T --git-ignore --level=4 --group-directories-first'

# Paths
## rust
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin

## go
fish_add_path /usr/local/go/bin
fish_add_path ~/go/bin

# Starship
source (/home/izoslav/.cargo/bin/starship init fish --print-full-init | psub)

# Start Zellij
if set -q ZELLIJ
else
    zellij
end
