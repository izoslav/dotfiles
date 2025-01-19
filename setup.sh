#!/bin/bash

# prompt for sudo password
prompt=$(sudo -v 2>&1)
if [ $? -ne 0 ]; then
	echo "Elevated privilege required!"
	exit 
fi

# TODO add git config
# TODO error checking
# TODO enable running single steps

user=$(whoami)
tools=/home/$user/tools

# versions
go_version=1.23.4
helix_version=25.01
helix_version_check=25.1

# download links
go_url=https://go.dev/dl/go$go_version.linux-amd64.tar.gz
helix_url=https://github.com/helix-editor/helix/releases/download/$helix_version/helix-$helix_version-x86_64-linux.tar.xz

# decorators
function print_done {
	printf "\e[32mdone\e[0m\n"
}

function print_skip {
	printf "\e[33mskip\e[0m\n"
}

function print_fail {
	printf "\e[31mfail\e[0m\n"
}

# main
function main {
	echo "Starting setup..."
	install_apt_packages
	install_rust
	install_cargo_packages
	install_go
	install_go_packages
	install_tools
	install_docker

	setup_git_delta
	run_stow
	change_shell
}

# install packaged tools
function install_apt_packages {
	declare -A packages

	packages+=(
		["build-essential"]="basic compilers and tools"
		["cmake"]="build system"
		["stow"]="symlink manager"
		["fzf"]="fuzzy finder"
		["fish"]="shell"
		["git-delta"]="diff viewer"
		["ripgrep"]="grep replacement"
		["just"]="task runner"
		["rustup"]="rust installation manager"
		["sqlite3"]="sqlite3 cli"
	)

	# update apt
	echo "Updating package list..."
	sudo apt-get update &>/dev/null

	# get the column len
	longest_name=0
	for package in ${!packages[@]}; do
		if [[ ${longest_name} -le ${#package} ]]; then
			longest_name=${#package}
		fi
	done

	# install packages one by one
	echo "Installing packages..."
	for package in ${!packages[@]}; do
		printf "  installing %-${longest_name}s - %s... " "${package}" "${packages[${package}]}"
		sudo apt-get install -y ${package} &>/dev/null
		if [[ $? -eq 0 ]]; then
			print_done
		else
			print_fail
		fi
	done
}

# install rust stable
function install_rust {
	printf "Configuring rust... "
	rustup default stable &>/dev/null
	rustup upgrade &>/dev/null
	print_done
}

# install cargo packages
function install_cargo_packages {
	declare -A packages

	packages+=(
		["bat"]="improved cat"
		["eza"]="ls replacement"
		["starship"]="shell prompt"
		["zellij"]="terminal multiplexer"
	)

	# get the column len
	longest_name=0
	for package in ${!packages[@]}; do
		if [[ ${longest_name} -le ${#package} ]]; then
			longest_name=${#package}
		fi
	done

	# install packages one by one
	echo "Installing cargo packages..."
	for package in ${!packages[@]}; do
		printf "  installing %-${longest_name}s - %s... " "${package}" "${packages[${package}]}"
		cargo install --locked ${package} &>/dev/null
		if [[ $? -eq 0 ]]; then
			print_done
		else
			print_fail
		fi
	done
}

# install go
function install_go {
	printf "Installing go $go_version... "

	if [[ $(go version 2>/dev/null) == *${go_version}* ]]; then
		print_skip
		return
	fi

	wget $go_url -O $tools/go.tar.gz &>/dev/null
	sudo rm -rf /usr/local/go &>/dev/null
	sudo tar xzf $tools/go.tar.gz -C /usr/local &>/dev/null
	rm $tools/go.tar.gz &>/dev/null
	print_done
}

# install go packages
function install_go_packages {
	export PATH=$PATH:/usr/local/go/bin &>/dev/null

	declare -A packages
	declare -A urls

	packages+=(
		["delve"]="debugger"
		["goose"]="db migration runner"
		["gopls"]="language server"
		["gow"]="go watch"
	)

	urls+=(
		["delve"]="github.com/go-delve/delve/cmd/dlv@latest"
		["goose"]="github.com/pressly/goose/v3/cmd/goose@latest"
		["gopls"]="golang.org/x/tools/gopls@latest"
		["gow"]="github.com/mitranim/gow@latest"
	)

	# get the column len
	longest_name=0
	for package in ${!packages[@]}; do
		if [[ ${longest_name} -le ${#package} ]]; then
			longest_name=${#package}
		fi
	done

	# install packages one by one
	echo "Installing go packages..."
	for package in ${!packages[@]}; do
		printf "  installing %-${longest_name}s - %s... " "${package}" "${packages[${package}]}"
		go install ${urls[${package}]} &>/dev/null
		if [[ $? -eq 0 ]]; then
			print_done
		else
			print_fail
		fi
	done
}

function install_tools {
	# create folders
	echo "Downlading and installing other tools..."
	mkdir -p $tools

	printf "  installing helix $helix_version... "
	if [[ $(hx --version 2>/dev/null) == *"${helix_version_check}"* ]]; then
		print_skip
		return
	fi

	wget $helix_url -O $tools/helix.tar.xz &>/dev/null
	tar xf $tools/helix.tar.xz --transform="s/helix-$helix_version-x86_64-linux/helix/" -C $tools &>/dev/null
	sudo ln -sf $tools/helix/hx /usr/bin/hx &>/dev/null
	rm $tools/helix.tar.xz &>/dev/null

	print_done
}

function install_docker {
	printf "Installing docker..."

	docker --version &>/dev/null
	if [[ $? -eq 0 ]]; then
		print_skip
		return
	fi

	printf "  adding docker's GPG key... "
	sudo apt-get update &>/dev/null
	sudo apt-get install ca-certificates curl &>/dev/null
	sudo install -m 0755 -d /etc/apt/keyrings &>/dev/null
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc &>/dev/null
	sudo chmod a+r /etc/apt/keyrings/docker.asc &>/dev/null
	print_done

	printf "  adding docker respository to apt sources... "
	sudo rm /etc/apt/sources.list.d/docker.list &>/dev/null
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update &>/dev/null
	print_done

	printf "  installing docker packages...\n"
	packages=("docker-ce" "docker-ce-cli" "containerd.io" "docker-buildx-plugin" "docker-compose-plugin")
	for i in ${!packages[@]}; do
		printf "    installing ${packages[${i}]}... "
		sudo apt-get install -y ${packages[${i}]} &>/dev/null
		if [[ $? -eq 0 ]]; then
			print_done
		else
			print_fail
		fi
	done
}

function run_stow {
	printf "Creating symlinks to dotfiles... "

	stow --version &>/dev/null
	if [[ $? -ne 0 ]]; then
		print_fail
		return
	fi
	
	mkdir -p /home/$user/.config
	stow . -t /home/$user &>/dev/null
	print_done
}

function change_shell {
	printf "Changing default shell to fish... "

	fish --version &>/dev/null
	if [[ $? -ne 0 ]]; then
		print_fail
		return
	fi

	sudo chsh $(whoami) -s /usr/bin/fish &>/dev/null
	print_done
}

function setup_git_delta {
	printf "Switching git diff to delta... "

	git config --global core.pager delta &>/dev/null
	git config --global interactive.diffFilter 'delta --color-only' &>/dev/null
	git config --global delta.navigate true &>/dev/null
	git config --global merge.conflictStyle zdiff3 &>/dev/null

	print_done
}

# entrypoint
main
