FROM aliyun-va-hub.byted.org/third/debian:bookworm

ENV container docker
ENV distro debian12

ARG USER_PASSWD

# COPY apt/cn_sources.list /etc/apt/sources.list
RUN apt update 
RUN apt install -y \
    ca-certificates && update-ca-certificates

RUN apt update && apt install -y \
    software-properties-common gpg gnupg gnupg2 \
    openssh-server sudo zsh curl wget vim locales

# ENV TZ=Asia/Shanghai
# RUN locale-gen en_US.UTF-8 && \
#     update-locale LANG=en_US.UTF-8 && \
#     ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN useradd -m -s $(which zsh) zhiqiangz && \
    echo zhiqiangz:${USER_PASSWD} | chpasswd && \
    usermod -aG sudo zhiqiangz

RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'AllowUsers zhiqiangz' >> /etc/ssh/sshd_config

# add-apt-repository ppa:zhangsongcui3371/fastfetch -y
# RUN add-apt-repository ppa:neovim-ppa/unstable -y

RUN curl -s -o - https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
RUN chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

RUN curl -o /tmp/fastfetch.deb -L https://github.com/fastfetch-cli/fastfetch/releases/download/2.37.0/fastfetch-linux-amd64.deb && \
    dpkg -i /tmp/fastfetch.deb && \
    rm -f /tmp/fastfetch.deb

RUN curl -o /tmp/fd.deb -L https://github.com/sharkdp/fd/releases/download/v10.2.0/fd_10.2.0_amd64.deb && \
    dpkg -i /tmp/fd.deb && \
    rm -f /tmp/fd.deb

RUN apt update 

RUN apt install -y \
    locales \
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
    ninja-build 

RUN apt install -y \
    bat eza file

RUN curl -fsSL https://github.com/neovim/neovim/archive/refs/tags/v0.10.4.zip -o /tmp/nvim_src.zip  
RUN unzip /tmp/nvim_src.zip -d /tmp/ && \
    cd /tmp/neovim-0.10.4 && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    cd build && \
    cpack -G DEB && \
    sudo dpkg -i --force-overwrite nvim-linux-x86_64.deb && \
    rm -rf /tmp/nvim_src.zip /tmp/neovim-0.10.4

RUN git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/.fzf
RUN /tmp/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-zsh --no-fish && \
    cp /tmp/.fzf/bin/fzf /usr/bin

RUN apt clean && rm -rf /var/lib/apt/lists/*

ENV LLVM_VERSION=20
RUN curl -s -o - https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

RUN echo '\
deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm main
deb-src http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm main
# 19 
deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-19 main
deb-src http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-19 main
# 20 
deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-20 main
deb-src http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-20 main
' > /etc/apt/sources.list.d/llvm.list

RUN apt update && apt install -y \
	clang-$LLVM_VERSION \
	lld-$LLVM_VERSION \
	lldb-$LLVM_VERSION \
    llvm-$LLVM_VERSION \
	clangd-$LLVM_VERSION 

RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/opt opt /usr/bin/opt-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/llc llc /usr/bin/llc-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/lld lld /usr/bin/lld-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-$LLVM_VERSION 100 
RUN update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-$LLVM_VERSION 100 

COPY install_pkg/cuda_install.sh /tmp/cuda_install.sh
# RUN bash /tmp/cuda_install.sh $distro

USER zhiqiangz
WORKDIR /home/zhiqiangz
COPY --chown=zhiqiangz:zhiqiangz install_pkg/user_basic_install.sh user_basic_install.sh
# COPY --chown=zhiqiangz:zhiqiangz set_proxy.sh set_proxy.sh
COPY --chown=zhiqiangz:zhiqiangz install_pkg/rust_install.sh /tmp/rust_install.sh
RUN bash user_basic_install.sh
# RUN bash /tmp/rust_install.sh

USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]