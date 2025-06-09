ARG BASE_IMAGE=local:latest
FROM $BASE_IMAGE

# Use bash instead of sh for RUN commands
SHELL ["/bin/bash", "-c"]
# This is read to determine terminal profile shell in VS Code
ENV SHELL=/bin/bash
# User colors in terminal
ENV TERM=xterm-256color

# Capture the --build-args or use default values
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create new user (unless that user already exists) + give sudo permissions
RUN if ! id -u "$USER_UID" &>/dev/null; then \
        groupadd --gid "$USER_GID" "$USERNAME" \
        && useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME"; \
    fi \
    && apt-get update \
    && apt-get install -y sudo \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Essential packages
RUN apt-get update && apt-get install -y \
    bash-completion \
    curl \
    git \
    wget \
    zip

# Nerd Fonts
RUN wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip \
    && unzip UbuntuMono.zip -d UbuntuMono \
    && mkdir -p /usr/share/fonts/truetype \
    && mv UbuntuMono /usr/share/fonts/truetype \
    && wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/DroidSansMono.zip \
    && unzip DroidSansMono.zip -d DroidSansMono \
    && mkdir -p /usr/share/fonts/opentype \
    && mv DroidSansMono /usr/share/fonts/opentype \
    && fc-cache -f \
    && rm UbuntuMono.zip DroidSansMono.zip

# clangd
RUN apt-get update && apt-get install -y clangd-19

# fd
RUN apt-get update && apt-get install -y fd-find \
    && ln -s "$(which fdfind)" /usr/bin/fd

# nnn
RUN git clone https://github.com/jarun/nnn.git \
    && cd nnn && git tag --sort=-creatordate | head -n1 | xargs git checkout \
    && apt-get install -y pkg-config libncursesw5-dev libreadline-dev \
    && make strip install O_NERD=1 \
    && cd .. && rm -rf nnn

# # fasd
# RUN wget -O fasd.zip https://github.com/clvv/fasd/archive/refs/tags/1.0.1.zip \
#     && unzip fasd.zip \
#     && cd fasd-1.0.1 && make install && cd .. \
#     && rm -r fasd.zip fasd-1.0.1
    
# Make non-root user the default
USER $USER_UID
WORKDIR /home/$USERNAME

CMD ["bash"]
ENTRYPOINT ["/ros_entrypoint.sh"]