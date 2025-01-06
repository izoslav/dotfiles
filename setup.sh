#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Running as root..."
	exec sudo -- "$0" $(whoami)
	exit
fi

# TODO organize into functions
# TODO prettier formatting
# TODO add git config

user=$1
tools=/home/$user/tools

# versions
go_version=1.23.4
helix_version=25.01

# update apt
sudo apt-get update

# download links
go_url=https://go.dev/dl/go$go_version.linux-amd64.tar.gz
helix_url=https://github.com/helix-editor/helix/releases/download/$helix_version/helix-$helix_version-x86_64-linux.tar.xz

# install packaged tools
cat << EOF
Installing packages via apt-get...
  build-essential  - basic complilers and tools
  cmake            - build system
  stow             - symlink manager
  fzf              - fuzzy finder
  fish             - shell
  git-delta        - diff viewer
  ripgrep          - grep replacement
  just             - task runner
  rustup           - rust installation manager
  sqlite3          - cli for sqlite3
EOF
sudo apt-get install -y \
	build-essential \
	cmake \
	stow \
	fzf \
	fish \
	git-delta \
	ripgrep \
	just \
	rustup \
	sqlite3 \
	&>/dev/null

# install rust tools
echo "Configuring rust..."
rustup default stable &>/dev/null

echo "Installing packages via cargo..."
echo "  bat      - improved cat"
cargo install --locked bat &>/dev/null
echo "  eza      - ls replacement"
cargo install --locked eza &>/dev/null
echo "  starship - shell prompt"
cargo install --locked starship &>/dev/null
echo "  zellij   - terminal multiplexer"
cargo install --locked zellij &>/dev/null

# install go
echo "Installing go $go_version"
wget $go_url -O $tools/go.tar.gz &>/dev/null
rm -rf /usr/local/go &>/dev/null
tar xzf $tools/go.tar.gz -C /usr/local &>/dev/null
rm $tools/go.tar.gz &>/dev/null
export PATH=$PATH:/usr/local/go/bin &>/dev/null

# install go tools
export GOBIN=/home/$user/go/bin

echo "Installing go packages..."
echo "  delve - debugger"
go install github.com/go-delve/delve/cmd/dlv@latest &>/dev/null
echo "  goose - migration runner"
go install github.com/pressly/goose/v3/cmd/goose@latest &>/dev/null
echo "  gopls - language server"
go install golang.org/x/tools/gopls@latest &>/dev/null
echo "  gow   - go watch"
go install github.com/mitranim/gow@latest &>/dev/null

# create folders
echo "Downlading and installing other tools..."
mkdir -p $tools

# download helix
echo "  helix $helix_version"
wget $helix_url -O $tools/helix.tar.xz &>/dev/null
tar xf $tools/helix.tar.xz --transform="s/helix-$helix_version-x86_64-linux/helix/" -C $tools &>/dev/null
sudo ln -sf $tools/helix/hx /usr/bin/hx &>/dev/null
rm $tools/helix.tar.xz &>/dev/null

# run stow
echo "Creating symlinks to dotfiles..."
mkdir -p /home/$user/.config
stow . -t /home/$user &>/dev/null

echo "Done!"
