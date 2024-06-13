#!/bin/bash

# Ensure directories exist.
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/gh-copilot"
mkdir -p "$HOME/.backup_dotfiles"

# List of files to check
files=(
	"$HOME/.config/nvim"
	"$HOME/.config/gh-copilot/config.yml"
	"$HOME/.gitconfig"
	"$HOME/.p10k.zsh"
	"$HOME/.wezterm.lua"
	"$HOME/.zprofile"
	"$HOME/.zshrc"
)

# Backup any existing files that are not symlinks.
echo "Backing up existing files..."
for file in "${files[@]}"; do
	if [ ! -L "$file" ]; then
		echo "Backing up '$file'"
		mv "$file" "$HOME/.backup_dotfiles/"
	fi
done
echo "...done! Backups were saved to $HOME/.backup_dotfiles/"

# Create symlinks.
echo "Creating symlinks to .dotfiles config files..."
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim/"
ln -sf "$DOTFILES_DIR/gh-copilot/config.yml" "$HOME/.config/gh-copilot/config.yml"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
ln -sf "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
echo "...done!"
