ARG BASE_IMAGE=local:latest
FROM $BASE_IMAGE

# Use bash instead of sh for RUN commands
SHELL ["/bin/bash", "-c"]
# This is read to determine terminal profile shell in VS Code
ENV SHELL=/bin/bash
# User colors in terminal
ENV TERM=xterm-256color
# Override VS Code as git editor
ENV GIT_EDITOR=nano
# Set locale
ENV LANG=${LANG:-C.UTF-8}

# Capture the --build-args or use default values
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create new user (unless that user already exists) + give sudo permissions
RUN if ! id -u "$USER_UID" &>/dev/null; then \
        groupadd --gid "$USER_GID" "$USERNAME" \
        && useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME"; \
    fi \
    && apt-get update && apt-get install -y sudo \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Essential packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    curl \
    fontconfig \
    git \
    grep \
    jq \
    locales \
    nano \
    wget \
    sudo \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Nerd Fonts
RUN wget --no-check-certificate https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip \
    && unzip UbuntuMono.zip -d UbuntuMono \
    && mkdir -p /usr/share/fonts/truetype \
    && mv UbuntuMono /usr/share/fonts/truetype \
    && fc-cache -f \
    && rm UbuntuMono.zip

# clangd
RUN clangd_url=$(curl -s https://api.github.com/repos/clangd/clangd/releases/latest | jq -r '.assets[].browser_download_url' | grep 'clangd-linux') \
    && clangd_version=$(curl -s "https://api.github.com/repos/clangd/clangd/releases/latest" | jq -r '.tag_name') \
    && wget --no-check-certificate -O clangd.zip $clangd_url \
    && unzip clangd.zip \
    && cp clangd_$clangd_version/bin/clangd /usr/local/bin \
    && cp -r clangd_$clangd_version/lib/clang /usr/local/lib \
    && ln -sf /usr/local/bin/clangd /usr/bin/clangd \
    && rm -r clangd.zip clangd_$clangd_version

# fd
RUN apt-get update && apt-get install -y fd-find \
    && ln -s "$(which fdfind)" /usr/bin/fd \
    && rm -rf /var/lib/apt/lists/*

# nnn
RUN git clone https://github.com/jarun/nnn.git \
    && cd nnn && git tag --sort=-creatordate | head -n1 | xargs git checkout \
    && apt-get update && apt-get install -y pkg-config libncursesw5-dev libreadline-dev \
    && make strip install O_NERD=1 \
    && cd .. && rm -rf nnn \
    && rm -rf /var/lib/apt/lists/*

# Lazygit
RUN lazygit_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*') \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_version}/lazygit_${lazygit_version}_Linux_x86_64.tar.gz" \
    && tar xf lazygit.tar.gz -C /usr/local/bin lazygit \
    && rm lazygit.tar.gz

# Make non-root user the default
USER $USER_UID
WORKDIR /home/$USERNAME

# fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    && ~/.fzf/install --key-bindings --completion --update-rc

CMD ["bash"]
