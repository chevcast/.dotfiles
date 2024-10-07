# Set the terminal title to the current directory.
function chpwd {
	echo "\x1b]1337;SetUserVar=panetitle=$(echo -n $(basename $(pwd)) | base64)\x07"
}
chpwd

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
# if check_last_run; then
# 	updoot
# fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable vi mode
bindkey -v

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Define custom prompt segmenet outside of generated .p10k.zsh file so it doesn't get overwritten.
prompt_customprefix() {
	p10k segment -f "#0f0" -t '🦇🧛🎃'
	# p10k segment -f "#0f0" -t '📜'
}
# typeset index=0 # Adjust this to move the segment left or right.
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
#   "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]:0:$index}"
#   customprefix 
#   "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]:$index}"
# )
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
	customprefix
	os_icon
	dir
	vcs
	newline
	prompt_char
)
# typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND="#FF6AC1"
# typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND="#FF5c57"

# If running in wezterm, source the shell integration script.
[[ "$TERM" = "wezterm" ]] && source "$HOME/.dotfiles/wezterm-shell-integration.sh"
command -v direnv &> /dev/null && eval "$(direnv hook zsh)"

# If gh-copilot is installed then configure its default aliases.
# ghcs - Github Copilot Suggest
# ghce - Github Copilot Explain
gh copilot -v &> /dev/null && eval "$(gh copilot alias -- zsh)"

# If homebrew is installed then source zsh plugins from their brew locations.
# Otherwise source from their default locations.
if command -v brew &> /dev/null; then
	source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
	source "$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
else
	source "/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme"
	source "/usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
fi

# If fzf is installed them pull in its shell completion and key bindings.
if command -v fzf &> /dev/null ; then
	eval "$(fzf --zsh)"
	# If fd is also installed then use it as the default fzf functionality.
	if command -v fd &> /dev/null ; then
		export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
		export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
		export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
		export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
		export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
		_fzf_compgen_path() {
			fd --hidden --exclude .git . "$1"
		}
		_fzf_compgen_dir() {
			fd --type=d --hidden --exclude .git . "$1"
		}
		_fzf_comprun() {
			local command=$1
			shift
			case "$command" in
				cd)				fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
				export|unset)	fzf --preview "eval 'echo {}=\$'{}" "$@" ;;
				ssh)				fzf --preview 'dig {}' "$@" ;;
				*)					fzf --preview "--preview 'bat -n --color=always --line-range :500 {}'" "$@" ;;
			esac
		}
	fi
	# If fzf-git is installed then pull in its shell completion and key bindings.
	if [[ -f ~/.fzf-git/fzf-git.sh ]]; then
		source ~/.fzf-git/fzf-git.sh
		# Set keybindings for zsh-vi-mode insert mode
		function zvm_after_init() {
			zvm_bindkey viins "^P" up-line-or-beginning-search
			zvm_bindkey viins "^N" down-line-or-beginning-search
			for o in files branches tags remotes hashes stashes lreflogs each_ref; do
				eval "zvm_bindkey viins '^g^${o[1]}' fzf-git-$o-widget"
				eval "zvm_bindkey viins '^g${o[1]}' fzf-git-$o-widget"
			done
		}
		# Set keybindings for zsh-vi-mode normal and visual modes
		function zvm_after_lazy_keybindings() {
			for o in files branches tags remotes hashes stashes lreflogs each_ref; do
				eval "zvm_bindkey vicmd '^g^${o[1]}' fzf-git-$o-widget"
				eval "zvm_bindkey vicmd '^g${o[1]}' fzf-git-$o-widget"
				eval "zvm_bindkey visual '^g^${o[1]}' fzf-git-$o-widget"
				eval "zvm_bindkey visual '^g${o[1]}' fzf-git-$o-widget"
			done
		}
	fi
fi

if command -v thefuck &> /dev/null ; then
	eval $(thefuck --alias)
	eval $(thefuck --alias fk)
fi

command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"

HISTFILE="$HOME/.zsh_history"
SAVEHIST=10000
HISTSIZE=10000
setopt SHARE_HISTORY

# Set personal aliases.
alias cat="bat --paging=never"
alias help="run-help"
alias lg="lazygit"
alias ll="eza --color=always --all --long --git --icons=always --no-time --no-permissions"
alias nv="nvim"
alias vi="nvim"
alias vim="nvim"
alias cd="z"
alias ff="fastfetch"

export KOMOREBI=false
function komo() {
	if [[ $KOMOREBI == true ]]; then
		komorebic.exe stop --whkd
		KOMOREBI=false
	elif [[ $KOMOREBI == false ]]; then
		komorebic.exe start --whkd
		KOMOREBI=true
	fi
}
