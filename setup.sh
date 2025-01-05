#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Running as root..."
	exec sudo -- "$0" $(whoami)
	exit
fi

user=$1
tools=/home/$user/tools

# versions
helix_version=25.01

# install packaged tools
echo "Installing packages via apt-get..."
sudo apt-get install -y \
	build-essentials \
	cmake \
	stow \
	fzf \
	fish \
	ripgrep \
	just \
	rustup \
	go \
	sqlite3

# install rust tools
echo "Configuring rust..."
rustup default stable

echo "Installing packages via cargo..."
cargo install --locked \
	bat \
	eza \
	starship \
	zellij

# install go tools
echo "Installing go packages..."
echo "  gow"
go install github.com/mitranim/gow@latest
echo "  goose"
go install github.com/pressly/goose/v3/cmd/goose@latest

# create folders
echo "Downlading and installing other tools..."
mkdir $tools

# download helix
echo "  helix $helix_version"
wget https://github.com/helix-editor/helix/releases/download/$helix_version/helix-$helix_version-x86_64-linux.tar.xz -O $tools/helix.tar.xz
tar xf $tools/helix.tar.xz --transform="s/helix-$helix_version-x86_64-linux/helix/" -C $tools
sudo ln -sf $tools/helix/hx /usr/bin/hx
rm $tools/helix.tar.xz

# run stow
echo "Creating symlinks to dotfiles..."
stow . -t /home/$user

echo "Done!"
