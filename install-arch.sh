#!/bin/bash

# Get the directory of the script.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# Install terminfo for Wezterm.
echo "Creating terminfo for Wezterm..."
tempfile=$(mktemp) &&
	curl -o "$tempfile" https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo &&
	tic -x -o "$HOME/.terminfo" "$tempfile" &&
	rm "$tempfile"
echo "...done!"

bash <"$DOTFILES_DIR/create-symlinks.sh"

# Install pacman key.
sudo pacman-key --init

# Install base packages.
echo "Updating system and installing base packages..."
sudo pacman -Sv --noconfirm --needed --disable-download-timeout \
	git \
	base-devel
echo "...done!"

# Install yay and remaining packages.
echo "Installing base, extra, and AUR packages..."
mkdir -p "$HOME/.yay"
cd "$HOME/.yay" || exit
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin || exit
makepkg -si --noconfirm
yay -Syuv --noconfirm --needed --disable-download-timeout \
	azure-cli \
	bat \
	curl \
	direnv \
	dotnet-sdk \
	eza \
	fd \
	fzf \
	git-delta \
	github-cli \
	go \
	lazygit \
	lua \
	python \
	python-pip \
	python-setuptools \
	ripgrep \
	rust \
	thefuck \
	tlrc-bin \
	unzip \
	wezterm \
	zsh \
	bun-bin \
	neovim-nightly-bin \
	volta-bin \
	zoxide \
	zsh-theme-powerlevel10k-git \
	zsh-vi-mode-git &&
	yay -Sccv --noconfirm
echo "...done!"

# Install fzf-git key bindings.
echo "Installing fzf-git key bindings..."
git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/.fzf-git"
echo "...done!"

# Install node and npm.
echo "Installing node..."
volta install node@latest
# Add node to PATH so it can be used by neovim plugins during sync.
export PATH="$HOME/.volta/bin:$PATH"
echo "...done!"

# Update neovim plugins.
echo "Installing Neovim plugins..."
nvim --headless "+Lazy! sync" "+sleep 5" +MasonUpdate "+sleep 5" +TSUpdateSync "+sleep 5" +qa
echo "...done!"

# Change user's default shell to ZSH.
echo "Authorizing ZSH and setting default shell..."
sudo sh -c "echo $(which zsh) >> /etc/shells"
sudo chsh -s "$(which zsh)" "$USER"
echo "...done!"

echo "All done! Please restart your shell to apply changes."
