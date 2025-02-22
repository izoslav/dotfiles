#!/bin/bash
set -euo pipefail

# prompt for sudo password
prompt=$(sudo -v 2>&1)
if [ $? -ne 0 ]; then
	echo "Elevated privilege required!"
	exit 
fi

# pacman
sudo pacman -Su
sudo pacman -Sy

sudo pacman -S --needed --noconfirm \
  starship \
  helix \
  zed \
  just \
  git-delta \
  htop \
  github-cli \
  stow \
  xclip \
  xorg-xhost \
  scrot \
  grub-customizer \
  task \
  go \
  gopls \
  delve \
  sqlc \
  rustup \
  docker \
  cachyos-gaming-meta \
  steam \
  discord \
  thunderbird

# paru
paru -S --needed --noconfirm \
  brave-beta-bin \
  dutree-bin

# go
go install github.com/pressly/goose/v3/cmd/goose@latest
go install github.com/mitranim/gow@latest
go install github.com/a-h/templ/cmd/templ@latest

# rust
rustup update stable

# git config
git config --global core.pager delta &>/dev/null
git config --global interactive.diffFilter 'delta --color-only' &>/dev/null
git config --global delta.navigate true &>/dev/null
git config --global merge.conflictStyle zdiff3 &>/dev/null

# stow
stow . -t ~
