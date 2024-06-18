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

export SSL_CERT_DIR=/etc/ssl/certs
export EDITOR="nvim"
export HOMEBREW_NO_ENV_HINTS=1
export DIRENV_LOG_FORMAT=
