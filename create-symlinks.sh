#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

# Declare an associative array of files to symlink.
declare -A files=(
	["$HOME/.config/nvim"]="$DOTFILES_DIR/nvim"
	["$HOME/.config/wezterm"]="$DOTFILES_DIR/wezterm"
	["$HOME/.config/gh-copilot/config.yml"]="$DOTFILES_DIR/gh-copilot/config.yml"
	["$HOME/.gitconfig"]="$DOTFILES_DIR/.gitconfig"
	["$HOME/.p10k.zsh"]="$DOTFILES_DIR/.p10k.zsh"
	["$HOME/.wezterm.lua"]="$DOTFILES_DIR/.wezterm.lua"
	["$HOME/.zprofile"]="$DOTFILES_DIR/.zprofile"
	["$HOME/.zshrc"]="$DOTFILES_DIR/.zshrc"
)

# Backup any existing files that are not symlinks and create symlinks.
echo "Backing up existing files and creating symlinks..."
for file in "${!files[@]}"; do
	# Backup existing files or symlinks if they are not the symlinks we want.
	if [ -e "$file" ] && [ "$(readlink -f "$file")" != "${files[$file]}" ]; then
		echo "Backing up '$file'..."
		mv "$file" "$HOME/.backup_dotfiles/"
	fi
	# Create any missing parent directories.
	mkdir -p "$(dirname "$file")"
	# Create symlinks if they are not already the symlinks we want.
	if [ "$(readlink -f "$file")" != "${files[$file]}" ]; then
		ln -sf "${files[$file]}" "$file"
	fi
done
echo "...done! Backups were saved to $HOME/.backup_dotfiles/ and symlinks were created."

# If WSL then create a Windows symbolic links in Windows user directory.
if command -v powershell.exe &>/dev/null; then
	echo "Creating Windows symlink to wezterm config file..."
	WEZTERM_CONFIG_PATH=$(echo "//wsl.localhost/Arch${DOTFILES_DIR}/.wezterm.lua" | sed 's/\//\\/g')
	if powershell.exe -Command "Test-Path \$env:USERPROFILE\\.wezterm.lua" >/dev/null; then
		powershell.exe -Command "Remove-Item -Recurse -Force \$env:USERPROFILE\\.wezterm.lua" >/dev/null
	fi
	powershell.exe -Command "New-Item -ItemType SymbolicLink -Path \$env:USERPROFILE\\.wezterm.lua -Target ${WEZTERM_CONFIG_PATH}" >/dev/null
	echo "...done!"

	echo "Creating Windows symlink to wezterm directory..."
	WEZTERM_DIR_PATH=$(echo "//wsl.localhost/Arch${DOTFILES_DIR}/wezterm" | sed 's/\//\\/g')
	if powershell.exe -Command "Test-Path \$env:USERPROFILE\\.wezterm" >/dev/null; then
		powershell.exe -Command "Remove-Item -Recurse -Force \$env:USERPROFILE\\.wezterm" >/dev/null
	fi
	powershell.exe -Command "New-Item -ItemType SymbolicLink -Path \$env:USERPROFILE\\.wezterm -Target ${WEZTERM_DIR_PATH}" >/dev/null
	echo "...done!"

	echo "Creating Windows symlink to nvim config directory..."
	NVIM_CONFIG_PATH=$(echo "//wsl.localhost/Arch${DOTFILES_DIR}/nvim" | sed 's/\//\\/g')
	if powershell.exe -Command "Test-Path \$env:USERPROFILE\\AppData\\Local\\nvim" >/dev/null; then
		powershell.exe -Command "Remove-Item -Recurse -Force \$env:USERPROFILE\\AppData\\Local\\nvim" >/dev/null
	fi
	powershell.exe -Command "New-Item -ItemType SymbolicLink -Path \$env:USERPROFILE\\AppData\\Local\\nvim -Target ${NVIM_CONFIG_PATH}" >/dev/null
	echo "...done!"
fi
