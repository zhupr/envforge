# =================================================================
# Dev environment container
#
# Build:  docker build -f containers/Dockerfile -t dotfiles-dev .
# Run:    docker run -it -v ~/projects:/workspace dotfiles-dev
# =================================================================
ARG BASE_IMAGE=ubuntu:26.04
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG USER=dev
ARG UID=1001

# ---- base packages (use TUNA mirror for speed/reliability) ----
ARG APT_MIRROR=""
RUN sed -i "s|http://ports.ubuntu.com/ubuntu-ports/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/|g; s|http://archive.ubuntu.com/ubuntu/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g" /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true \
    && apt-get update && apt-get install -y --fix-missing \
    sudo curl wget git ca-certificates gnupg lsb-release \
    build-essential software-properties-common bc zsh tmux \
    && rm -rf /var/lib/apt/lists/*

# ---- create non-root user ----
RUN id "$USER" >/dev/null 2>&1 || useradd -o -m -s /bin/zsh -u "$UID" "$USER" \
    && echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ---- copy dotfiles ----
COPY --chown=$USER:$USER . /home/$USER/dotfiles

# ---- switch to user ----
USER $USER
WORKDIR /home/$USER

# NOTE: ./install.sh --container alone installs NOTHING (it only forces
# apt mode; component flags still required). Use --all explicitly.
# Add --offline AFTER running scripts/download_offline.sh on a host with
# network, then rebuild with --build-arg OFFLINE=true
ARG OFFLINE=false
ARG SKIP_GO_TOOLS=true
ARG RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
ARG RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
RUN cd dotfiles && export RUSTUP_DIST_SERVER=$RUSTUP_DIST_SERVER RUSTUP_UPDATE_ROOT=$RUSTUP_UPDATE_ROOT SKIP_GO_TOOLS=$SKIP_GO_TOOLS GITHUB_MIRROR=https://ghfast.top/https://github.com && if [ "$OFFLINE" = "true" ]; then ./install.sh --all --offline; else ./install.sh --all; fi

# ---- default workspace ----
USER root
RUN mkdir -p /workspace && chown $USER:$USER /workspace
USER $USER
WORKDIR /workspace

CMD ["zsh"]
