# =================================================================
# Dev environment container
#
# Build:  docker build -f containers/Dockerfile -t dotfiles-dev .
# Run:    docker run -it -v ~/projects:/workspace dotfiles-dev
# =================================================================
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USER=dev
ARG UID=1000

# ---- base packages ----
RUN apt-get update && apt-get install -y \
    sudo curl wget git ca-certificates gnupg lsb-release \
    build-essential software-properties-common bc \
    zsh tmux \
    && rm -rf /var/lib/apt/lists/*

# ---- create non-root user ----
RUN useradd -m -s /bin/zsh -u $UID $USER \
    && echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ---- copy dotfiles ----
COPY --chown=$USER:$USER . /home/$USER/dotfiles

# ---- switch to user ----
USER $USER
WORKDIR /home/$USER

# ---- run installer (container mode) ----
RUN cd dotfiles && ./install.sh --container 2>&1 || true

# ---- default workspace ----
RUN mkdir -p /workspace
WORKDIR /workspace

CMD ["zsh"]
