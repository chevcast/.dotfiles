FROM archlinux:latest

# Place docker environment file early so we can detect during build that we are running in a container.
RUN touch /.dockerenv

# Define default user and group.
ENV USERNAME=catdad
ENV USER_UID=1000
ENV USER_GID=1000

# Upgrade system, install sudo, and clean up.
RUN pacman -Syuv --noconfirm && \
	pacman -Sv --noconfirm sudo && \
	pacman -Sccv --noconfirm

# Create a non-root user with sudo privileges.
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
	useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
	echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} && \
	chmod 0440 /etc/sudoers.d/${USERNAME}

# Switch to the new user.
USER ${USERNAME}

# Set user and home variables.
ENV USER=${USERNAME}
ENV HOME=/home/${USERNAME}

# Copy .dotfiles into image, taking ownership as we do.
COPY --chown=${USERNAME} ./ ${HOME}/.dotfiles

# Run install script.
WORKDIR ${HOME}
RUN ./.dotfiles/install-arch.sh

# Set user-specific environment variables.
ENV SHELL=/bin/zsh
ENV TERM=xterm-256color
# Needed to prevent Wezterm from trying to integrate with systemd within the container.
ENV WEZTERM_SHELL_SKIP_ALL=1

# Start Zsh login session by default.
CMD ["zsh", "-l"]
