#!/bin/bash

# Install Xcode Command Line Tools.
echo "Installing XCode Command Line Tools..."
xcode-select --install
echo "...done!"

# Install terminfo for wezterm.
echo "Creating terminfo for Wezterm..."
tempfile=$(mktemp) &&
	curl -o "$tempfile" https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo &&
	tic -x -o "$HOME/.terminfo" "$tempfile" &&
	rm "$tempfile"
echo "...done!"

bash <"create-symlinks.sh"

# Install Homebrew.
echo "Installing Homebrew..."
export HOMEBREW_NO_ENV_HINTS=1
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Source Homebrew shell configuration.
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "...done!"

# Add formulae taps.
echo "Updating system and installing base packages..."
brew tap jesseduffield/lazygit
brew tap oven-sh/bun
brew tap wez/wezterm-linuxbrew

# Update Homebrew.
brew update && brew upgrade

ulimit -n 3072

# Install a bunch of stuff.
brew install \
	azure-cli \
	bat \
	bun \
	direnv \
	dotnet \
	eza \
	fd \
	fzf \
	gcc \
	gh \
	git-delta \
	golang \
	lazygit \
	lua \
	fastfetch \
	powerlevel10k \
	python \
	ripgrep \
	rust \
	thefuck \
	tlrc \
	volta \
	wezterm \
	zoxide \
	zsh-vi-mode \
	zsh
echo "...done!"

# Install fzf-git key bindings.
echo "Installing fzf-git key bindings..."
git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/.fzf-git"
echo "...done!"

# Install node and pnpm.
echo "Installing node..."
volta install node@latest
# Add node to PATH so it can be used by neovim plugins during sync.
PATH="$HOME/.volta/bin:$PATH"
echo "...done!"

# Install neovim nightly.
echo "Installing neovim nightly..."
brew install neovim --HEAD || {
	# If status code not zero then install neovim nightly from source.
	echo "Failed to install neovim nightly from brew. Installing from source..."
	git clone https://github.com/neovim/neovim /neovim && (cd /neovim || exit)
	make CMAKE_BUILD_TYPE=Release
	sudo make install
}
echo "...done!"

echo "Installing Neovim plugins..."
nvim --headless "+Lazy! sync" "+sleep 5" +MasonUpdate "+sleep 5" +TSUpdateSync "+sleep 5" +qa
echo "...done!"

echo "Authorizing ZSH and setting default shell..."
sudo sh -c "echo $(which zsh) >> /etc/shells"
sudo chsh -s "$(which zsh)" "$USER"
echo "...done!"

echo "All done! Please restart your shell to apply changes."
