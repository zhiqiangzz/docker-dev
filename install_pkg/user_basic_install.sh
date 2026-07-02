#!/bin/bash

pushd $HOME
# install zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# # install miniconda 
# mkdir -p miniconda3
# curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda3/miniconda.sh
# bash miniconda3/miniconda.sh -b -u -p miniconda3
# rm miniconda3/miniconda.sh
# source miniconda3/bin/activate
# conda init --all

curl -LsSf https://astral.sh/uv/install.sh | sh

curl -fsSL https://pixi.sh/install.sh | bash

# install tmux plugins manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/zhiqiangzz/dotfiles.git ~/.config/dotfiles

curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# activate dotfiles via dotbot (symlinks the fish config, git, nvim, tmux, scripts...).
# fisher and its plugins (nvm.fish, pure, ...) bootstrap on the first interactive fish session.
bash ~/.config/dotfiles/install
popd