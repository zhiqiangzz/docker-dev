FROM aliyun-va-hub.byted.org/third/debian:bullseye

ARG USER_PASSWD
ENV distro=debian11
ENV distro_codename=bullseye

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

RUN mkdir /etc/apt/keyrings
RUN curl -s -o - https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
RUN chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# RUN curl -o /tmp/fastfetch.deb -L https://github.com/fastfetch-cli/fastfetch/releases/download/2.37.0/fastfetch-linux-amd64.deb && \
#     dpkg -i /tmp/fastfetch.deb && \
#     rm -f /tmp/fastfetch.deb

# RUN curl -o /tmp/fd.deb -L https://github.com/sharkdp/fd/releases/download/v10.2.0/fd_10.2.0_amd64.deb && \
#     dpkg -i /tmp/fd.deb && \
#     rm -f /tmp/fd.deb

RUN apt update 

# 7zip \
RUN apt install -y \
    locales \
    tldr \
    net-tools telnet iputils-ping \
    unzip p7zip-full \
    ffmpeg jq poppler-utils imagemagick \
    ripgrep \
    tmux \
    git \
    gettext

# install compiler toolchain
# libstdc++-12-dev \
RUN apt install -y \
    gcc \
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

ENV LLVM_VERSION=18
RUN curl -s -o - https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

# install llvm toolchain related
RUN echo "\
# deb http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename} main\n\
# deb-src http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename} main\n\
# 18\n\
deb http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-18 main\n\
deb-src http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-18 main\n\
# # 19\n\
# deb http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-19 main\n\
# deb-src http://apt.llvm.org/${distro_codename}/ llvm-toolchain-${distro_codename}-19 main\
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
RUN update-alternatives --install /usr/bin/clang-format clangd /usr/bin/clang-format-$LLVM_VERSION 100 

COPY install_pkg/cuda_install.sh /tmp/cuda_install.sh
# RUN bash /tmp/cuda_install.sh $distro

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
        gnupg2 \
        curl \
        ca-certificates \
        && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/${distro}/x86_64/3bf863cc.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/${distro}/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get update && \
    apt-get install -yq --no-install-recommends --fix-missing \
        cuda-cudart-12-1=12.1.105-1 \
        cuda-compat-12-1 \
        cuda-libraries-12-1=12.1.1-1 \
        cuda-nvtx-12-1=12.1.105-1 \
        cuda-nvml-dev-12-1=12.1.105-1 \
        cuda-command-line-tools-12-1=12.1.1-1 \
        cuda-libraries-dev-12-1=12.1.1-1 \
        cuda-minimal-build-12-1=12.1.1-1 \
        libcublas-12-1=12.1.3.1-1 \
        libcublas-dev-12-1=12.1.3.1-1 \
        libcusparse-12-1=12.1.0.106-1 \
        libcusparse-dev-12-1=12.1.0.106-1 \
        libcudnn8=8.9.0.131-1+cuda12.1 \
        libcudnn8-dev=8.9.0.131-1+cuda12.1 \
        libncursesw5 \
        libtinfo5 \
        && \
    ln -s /usr/local/cuda-12.1 /usr/local/cuda && \
    find /usr/local/cuda-12.1/lib64/ -type f -name '*.a' -not -name 'libcudart_static.a' -not -name 'libcudadevrt.a' -delete && \
    rm /etc/apt/sources.list.d/cuda.list && \
    rm -rf /var/lib/apt/lists/*

# CUDA environment variables
ENV CUDA_HOME "/usr/local/cuda"
ENV PATH "${CUDA_HOME}/bin:${PATH}"
ENV LD_LIBRARY_PATH "${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=12.1 brand=tesla,driver>=450,driver<451 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471 brand=tesla,driver>=510,driver<511 brand=unknown,driver>=510,driver<511 brand=nvidia,driver>=510,driver<511 brand=nvidiartx,driver>=510,driver<511 brand=geforce,driver>=510,driver<511 brand=geforcertx,driver>=510,driver<511 brand=quadro,driver>=510,driver<511 brand=quadrortx,driver>=510,driver<511 brand=titan,driver>=510,driver<511 brand=titanrtx,driver>=510,driver<511 brand=tesla,driver>=515,driver<516 brand=unknown,driver>=515,driver<516 brand=nvidia,driver>=515,driver<516 brand=nvidiartx,driver>=515,driver<516 brand=geforce,driver>=515,driver<516 brand=geforcertx,driver>=515,driver<516 brand=quadro,driver>=515,driver<516 brand=quadrortx,driver>=515,driver<516 brand=titan,driver>=515,driver<516 brand=titanrtx,driver>=515,driver<516 brand=tesla,driver>=525,driver<526 brand=unknown,driver>=525,driver<526 brand=nvidia,driver>=525,driver<526 brand=nvidiartx,driver>=525,driver<526 brand=geforce,driver>=525,driver<526 brand=geforcertx,driver>=525,driver<526 brand=quadro,driver>=525,driver<526 brand=quadrortx,driver>=525,driver<526 brand=titan,driver>=525,driver<526 brand=titanrtx,driver>=525,driver<526"

RUN apt-get -q -y update && \
    apt-get install libcurl3-gnutls -q -y && \
    apt-get install -q -y bzip2 \
        wget \
        curl \
        git \
        git-lfs \
        build-essential \
        ca-certificates \
        libbz2-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        tk-dev \
        uuid-dev \
        zlib1g-dev && \
    apt-get -y autoclean && apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get -q -y update && \
    apt-get install --no-install-recommends -yq \
        software-properties-common \
        gnupg1 \
        gnupg2 \
        ninja-build \
        unzip \
        patch \
        clang-format-13 \
        clang \
        python3-dev \
        python3-pip \
        zsh \
        openssh-client && \
    rm -rf /var/lib/apt/lists/*

RUN git lfs install --force --skip-smudge

# for onnx-frontend
RUN apt-get update && \
    apt-get install --no-install-recommends -yq \
        protobuf-compiler \
        libprotobuf-dev \
        && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get remove -y lsb-release

RUN echo "\
RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static\n\
RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup\n\
" >> /etc/environment

USER zhiqiangz
WORKDIR /home/zhiqiangz
ENV PATH=/home/zhiqiangz/.cargo/bin:$PATH \
    RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static \
    RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup 

# install rust
# - https://www.rust-lang.org/tools/install
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path --profile minimal --default-toolchain nightly

RUN cargo install --locked yazi-fm yazi-cli

COPY --chown=zhiqiangz:zhiqiangz install_pkg/user_basic_install.sh user_basic_install.sh
COPY --chown=zhiqiangz:zhiqiangz set_proxy.sh set_proxy.sh
RUN bash user_basic_install.sh

USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
