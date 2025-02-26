distro=ubuntu2204

# add-apt-repository ppa:zhangsongcui3371/fastfetch -y
add-apt-repository ppa:neovim-ppa/unstable -y

curl -s -o - https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

curl -o /tmp/fastfetch.deb -L https://github.com/fastfetch-cli/fastfetch/releases/download/2.37.0/fastfetch-linux-amd64.deb && \
    dpkg -i /tmp/fastfetch.deb && \
    rm -f /tmp/fastfetch.deb

curl -o /tmp/fd.deb -L https://github.com/sharkdp/fd/releases/download/v10.2.0/fd_10.2.0_amd64.deb && \
    dpkg -i /tmp/fd.deb && \
    rm -f /tmp/fd.deb

apt update 

apt install -y \
    locales \
    tldr \
    net-tools telnet iputils-ping \
    unzip p7zip-full 7zip\
    ffmpeg jq poppler-utils imagemagick \
    ripgrep \
    tmux \
    git

# install compiler toolchain
apt install -y \
    gcc \
    libstdc++-12-dev \
    cmake \
    make \
    ninja-build 

apt install -y \
    bat eza neovim

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
pushd /tmp
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
popd

git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/.fzf
/tmp/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-zsh --no-fish && \
cp /tmp/.fzf/bin/fzf /usr/bin

apt clean && rm -rf /var/lib/apt/lists/*