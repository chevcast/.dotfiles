FROM alpine:latest

# Most of the time a user will be using a capable terminal emulator so we set a reasonable default.
ENV TERM=xterm-256color

# Copy only nvim configuratoin.
COPY ./nvim /root/.config/nvim

# Install the bare minimum packages to support Neovim and plugins.
RUN apk update && apk upgrade && apk add --no-cache \
	build-base \
	cmake \
	coreutils \
	curl \
	fd \
	gettext-tiny-dev \
	git \
	lazygit \
	lua \
	neovim \
	neovim-doc \
	nodejs \
	npm \
	python3 \
	py3-pip \
	ripgrep \
	unzip

# Update Neovim plugins.
RUN nvim --headless "+Lazy! sync" "+sleep 5" +MasonUpdate "+sleep 5" +TSUpdateSync "+sleep 5" +qa

# Setup default entrypoint.
WORKDIR /root
ENTRYPOINT ["nvim"]
CMD []
