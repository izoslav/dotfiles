# Paths

fish_add_path /opt/homebrew/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/go/bin

# Variables

set -gx GOPATH ~/go
set -gx PKG_CONFIG_PATH /opt/homebrew/opt/openssl/lib/pkgconfig
set -gx HOMEBREW_GITHUB_API_TOKEN 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
set -gx LIBRARY_PATH "$LIBRARY_PATH:$(brew --prefix)/lib"

# Other

function check_releases
    echo
    releasecheck --platforms PS4,PS5,PC,Switch
    echo
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ruby
status --is-interactive; and rbenv init - fish | source

# prompt
starship init fish | source


test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

