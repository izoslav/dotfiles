user=$(whoami)
tools=/home/$user/tools

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# install packaged tools
echo "Installing packages via apt-get..."
sudo apt-get install -y \
	build-essentials \
	cmake \
	rustup \
	stow \
	fzf \
	fish

# install rust tools
echo "Configuring rust..."
rustup default stable

echo "Installing packages via cargo..."
cargo install --locked \
	bat \
	eza \
	starship \
	zellij

# create folders
echo "Downlading and installing other tools..."
mkdir $tools

# download helix
echo "  helix"
wget https://github.com/helix-editor/helix/releases/download/25.01/helix-25.01-x86_64-linux.tar.xz -O $tools/helix.tar.xz
tar xf $tools/helix.tar.xz -C $tools/helix
sudo ln -s /usr/bin/hx $tools/helix/hx

