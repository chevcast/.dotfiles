# If we are in WSL then configure Windows path variables.
if command -v powershell.exe > /dev/null ; then
	export WINHOME=$(wslpath -u "$(powershell.exe '$env:Userprofile' | tr -d '\r')")
	export APPDATA=$WINHOME/AppData/Roaming
	export DESKTOP=$WINHOME/Desktop
	export DOWNLOADS=$WINHOME/Downloads
	# If Google Drive is mounted then set some more path variables.
	if [[ -d "/mnt/g" ]] ; then
		export GDRIVE="/mnt/g/My Drive"
		export GBACKUPS="/mnt/g/My Drive/Backups"
	fi
fi

# Source Homebrew shell configuration.
[[ -d "/opt/homebrew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -d "/home/linuxbrew/.linuxbrew" ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# If Bun is installed then add it to our PATH.
[[ -d "$HOME/.bun" ]] && export PATH="$HOME/.bun/bin:$PATH"

# If Volta is installed then add it to our PATH.
[[ -d "$HOME/.volta/bin" ]] && export PATH="$HOME/.volta/bin:$PATH"

# If cargo is installed then source its env file.
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# If there is a local bin directory then add it to our PATH.
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# If Go is installed then add it to PATH.
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"
[[ -d "$HOME/go/bin" ]] && export PATH="$PATH:$HOME/go/bin"

# Define function to check if we should run system updates.
TIMESTAMP_FILE="$HOME/.last_update_check"
check_last_run() {
	if [ -f "$TIMESTAMP_FILE" ]; then
		last_run=$(date -r "$TIMESTAMP_FILE" +%s)
		current_time=$(date +%s)
		time_diff=$((current_time - last_run))
		if [ $time_diff -lt 86400 ]; then
			return 1 # Less than 24 hours.
		fi
	fi
	return 0 # More than 24 hours or timestamp file doesn't exist.
}

updoot() {
	echo "System packages have not been updated in more than 24 hours. Updating system packages..."

	# If yay is installed then use it to /update the system.
	command -v yay &> /dev/null && yay -Syuv --needed --noconfirm --disable-download-timeout

	# If brew is installed then update and upgrade.
	command -v brew &> /dev/null && brew update -v && brew upgrade -v

	echo "System packages have been updated."

	echo "Updating Github CLI..."

	# If gh is installed and not authenticated then ask user to authenticate.
	if command -v gh &> /dev/null && ! gh auth status &> /dev/null ; then
		echo "Github CLI is installed but not authenticated."
		gh auth login --web -h github.com
	fi

	# If gh is installed, authenticated, and copilot CLI is not installed then install it.
	if command -v gh &> /dev/null && gh auth status &> /dev/null && ! gh copilot -v &> /dev/null ; then
		gh extension install github/gh-copilot --force
	fi

	# If gh is installed then update its extensions.
	command -v gh &> /dev/null && gh extension upgrade --all

	echo "Github CLI has been updated."

	# Update the timestamp file
	touch "$TIMESTAMP_FILE"
}

# Check if we should run system updates.
if check_last_run; then
	updoot
fi

export SSL_CERT_DIR=/etc/ssl/certs
export EDITOR="nvim"
export HOMEBREW_NO_ENV_HINTS=1
export DIRENV_LOG_FORMAT=
