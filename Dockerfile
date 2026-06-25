ARG BASE_IMAGE
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
ENV LANG=C.UTF-8

# Capture the --build-args or use default values
ARG USERNAME
ARG USER_UID
ARG USER_GID=$USER_UID

# Essential packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash-completion \
        git \
        locales \
        nano \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Create new user (unless that user already exists) + give sudo permissions
RUN if ! id -u "$USER_UID" &>/dev/null; then \
        groupadd --gid "$USER_GID" "$USERNAME" \
        && useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME"; \
    fi \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME" \
    && chmod 0440 "/etc/sudoers.d/$USERNAME"

# Make non-root user the default
USER $USER_UID
WORKDIR /home/$USERNAME

# Prevent "To run command as administrator..." welcome message
RUN touch ~/.hushlogin

CMD ["bash"]
