FROM ubuntu:noble

ENV distro=ubuntu2404
ENV distro_codename=noble
ENV user=zhiqiangz

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ARG USER_UID=1000
ARG USER_GID=1000

SHELL ["/bin/bash", "-c"]

# =========================
# Base packages
# =========================
RUN apt update && apt install -y \
    ca-certificates \
    software-properties-common \
    gpg gnupg gnupg2 \
    openssh-server \
    sudo \
    fish \
    curl \
    wget \
    vim \
    locales \
    file \
    tldr \
    net-tools \
    telnet \
    iputils-ping \
    unzip \
    p7zip-full \
    7zip \
    ffmpeg \
    jq \
    poppler-utils \
    imagemagick \
    ripgrep \
    tmux \
    git \
    python3 \
    gettext \
    gcc \
    libstdc++-12-dev \
    cmake \
    make \
    ninja-build \
    bear \
    bat \
    lldb clangd clang-format \
    btop && \
    update-ca-certificates && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# =========================
# User setup
# =========================
RUN if getent passwd $USER_UID >/dev/null; then \
        userdel -r "$(getent passwd $USER_UID | cut -d: -f1)"; \
    fi && \
    if getent group $USER_GID >/dev/null; then \
        groupdel "$(getent group $USER_GID | cut -d: -f1)"; \
    fi && \
    groupadd -g $USER_GID "$user" && \
    useradd -m -u $USER_UID -g $USER_GID -s "$(which fish)" "$user" && \
    usermod -aG sudo "$user" && \
    passwd -l "$user" && \
    echo "$user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$user" && \
    chmod 0440 "/etc/sudoers.d/$user"

# =========================
# SSH setup
# =========================
RUN mkdir -p /var/run/sshd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AllowUsers $user" >> /etc/ssh/sshd_config

# =========================
# fzf
# =========================
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/.fzf && \
    /tmp/.fzf/install \
        --key-bindings \
        --completion \
        --no-update-rc \
        --no-bash \
        --no-zsh \
        --no-fish && \
    cp /tmp/.fzf/bin/fzf /usr/bin/fzf && \
    rm -rf /tmp/.fzf

# =========================
# eza apt source
# =========================
RUN mkdir -p /etc/apt/keyrings && \
    curl -s -o - https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        > /etc/apt/sources.list.d/gierens.list && \
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list && \
    apt update && \
    apt install -y eza

# =========================
# fastfetch
# =========================
RUN curl -o /tmp/fastfetch.deb -L \
        https://github.com/fastfetch-cli/fastfetch/releases/download/2.37.0/fastfetch-linux-amd64.deb && \
    dpkg -i /tmp/fastfetch.deb && \
    rm -f /tmp/fastfetch.deb

# =========================
# fd
# =========================
RUN curl -o /tmp/fd.deb -L \
        https://github.com/sharkdp/fd/releases/download/v10.2.0/fd_10.2.0_amd64.deb && \
    dpkg -i /tmp/fd.deb && \
    rm -f /tmp/fd.deb

# =========================
# dust
# =========================
RUN curl -sSfL https://raw.githubusercontent.com/bootandy/dust/refs/heads/master/install.sh | sh

ARG INSTALL_CUDA=false
ARG INSTALL_LLVM=false
ARG LLVM_VERSION=21

# =========================
# Optional CUDA
# =========================
COPY install_pkg/cuda_install.sh /tmp/cuda_install.sh

RUN if [ "$INSTALL_CUDA" = "true" ]; then \
        bash /tmp/cuda_install.sh "$distro"; \
    else \
        echo "Skip CUDA installation"; \
    fi

# =========================
# Optional LLVM
# =========================
RUN if [ "$INSTALL_LLVM" = "true" ]; then \
        curl -s -o - https://apt.llvm.org/llvm-snapshot.gpg.key \
            | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc > /dev/null && \
        echo "deb http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-${LLVM_VERSION} main" \
            > /etc/apt/sources.list.d/llvm.list && \
        echo "deb-src http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-${LLVM_VERSION} main" \
            >> /etc/apt/sources.list.d/llvm.list && \
        apt update && apt install -y \
            clang-${LLVM_VERSION} \
            lld-${LLVM_VERSION} \
            lldb-${LLVM_VERSION} \
            llvm-${LLVM_VERSION} \
            clangd-${LLVM_VERSION} \
            clang-format-${LLVM_VERSION} && \
        update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 100 && \
        update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} 100 && \
        update-alternatives --install /usr/bin/opt opt /usr/bin/opt-${LLVM_VERSION} 100 && \
        update-alternatives --install /usr/bin/llc llc /usr/bin/llc-${LLVM_VERSION} 100 && \
        update-alternatives --install /usr/bin/lld lld /usr/bin/lld-${LLVM_VERSION} 100 && \
        update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-${LLVM_VERSION} 100 && \
        update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-${LLVM_VERSION} 100 && \
        update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${LLVM_VERSION} 100 && \
        update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-${LLVM_VERSION} 100 && \
        update-alternatives --install /usr/bin/FileCheck FileCheck /usr/bin/FileCheck-${LLVM_VERSION} 100; \
    else \
        echo "Skip LLVM installation"; \
    fi

# =========================
# User config
# =========================
USER $user
WORKDIR /home/$user

COPY --chown=$user:$user install_pkg/user_basic_install.sh /home/$user/user_basic_install.sh
COPY --chown=$user:$user set_proxy.sh /home/$user/set_proxy.sh

RUN bash /home/$user/user_basic_install.sh

# =========================
# Entrypoint
# =========================
USER root

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# ENTRYPOINT CMD
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "${user}"]
CMD ["/usr/sbin/sshd", "-D"]

EXPOSE 22
