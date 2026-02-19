FROM ubuntu:noble

ENV distro=ubuntu2404
ENV distro_codename=noble
ENV user=zhiqiangz

RUN apt update 
RUN apt install -y \
    ca-certificates && update-ca-certificates

# COPY apt/cn_sources.list /etc/apt/sources.list
# RUN apt update 
RUN apt update && apt install -y \
    software-properties-common gpg gnupg gnupg2 \
    openssh-server sudo zsh curl wget vim locales

# ================ docker build only begin ================
ENV TZ=Asia/Shanghai
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN useradd -m -s $(which zsh) $user && \
    usermod -aG sudo $user && \
    passwd -l $user && \
    echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user && \
    chmod 0440 /etc/sudoers.d/$user

RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'AllowUsers $user' >> /etc/ssh/sshd_config
# ================ docker build only end ================

RUN apt update 

RUN apt install -y \
    file \
    tldr \
    net-tools telnet iputils-ping \
    unzip p7zip-full 7zip\
    ffmpeg jq poppler-utils imagemagick \
    ripgrep \
    tmux \
    git \
    gettext

# install compiler toolchain
RUN apt install -y \
    gcc \
    libstdc++-12-dev \
    cmake \
    make \
    ninja-build \
    bear 


RUN git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/.fzf
RUN /tmp/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-zsh --no-fish && \
    cp /tmp/.fzf/bin/fzf /usr/bin

RUN curl -s -o - https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
RUN chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

RUN curl -o /tmp/fastfetch.deb -L https://github.com/fastfetch-cli/fastfetch/releases/download/2.37.0/fastfetch-linux-amd64.deb && \
    dpkg -i /tmp/fastfetch.deb && \
    rm -f /tmp/fastfetch.deb

RUN curl -o /tmp/fd.deb -L https://github.com/sharkdp/fd/releases/download/v10.2.0/fd_10.2.0_amd64.deb && \
    dpkg -i /tmp/fd.deb && \
    rm -f /tmp/fd.deb

# ================ docker build only begin ================
RUN curl -fsSL https://github.com/neovim/neovim/archive/refs/tags/v0.10.4.zip -o /tmp/nvim_src.zip  
RUN unzip /tmp/nvim_src.zip -d /tmp/ && \
    cd /tmp/neovim-0.10.4 && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    cd build && \
    cpack -G DEB && \
    sudo dpkg -i --force-overwrite nvim-linux-x86_64.deb && \
    rm -rf /tmp/nvim_src.zip /tmp/neovim-0.10.4


ENV LLVM_VERSION=21
RUN curl -s -o - https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

# install llvm toolchain related
RUN echo -e "\
deb http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename} main\n\
deb-src http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename} main\n\
# 20\n\
deb http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-20 main\n\
deb-src http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-20 main\n\
# 21\n\
deb http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-21 main\n\
deb-src http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-21 main\
" > /etc/apt/sources.list.d/llvm.list

RUN apt update && apt install -y \
	clang-$LLVM_VERSION \
	lld-$LLVM_VERSION \
	lldb-$LLVM_VERSION \
    llvm-$LLVM_VERSION \
	clangd-$LLVM_VERSION \
	clang-format-$LLVM_VERSION 

RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/opt opt /usr/bin/opt-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/llc llc /usr/bin/llc-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/lld lld /usr/bin/lld-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/FileCheck FileCheck /usr/bin/FileCheck-$LLVM_VERSION 100 

# ================ docker build only end ================

COPY install_pkg/cuda_install.sh /tmp/cuda_install.sh
# RUN bash /tmp/cuda_install.sh $distro

RUN apt install -y \
    bat eza btop

RUN apt clean && rm -rf /var/lib/apt/lists/*

RUN echo "\
RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static\n\
RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup\n\
" >> /etc/environment

USER $user
WORKDIR /home/$user
ENV PATH=/home/$user/.cargo/bin:$PATH \
    RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static \
    RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup 

# install rust
# - https://www.rust-lang.org/tools/install
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path --profile minimal --default-toolchain nightly

RUN cargo install --locked yazi-fm yazi-cli du-dust

COPY --chown=$user:$user install_pkg/user_basic_install.sh user_basic_install.sh
# COPY --chown=$user:$user set_proxy.sh set_proxy.sh
RUN bash user_basic_install.sh

USER root
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "$user"]

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
