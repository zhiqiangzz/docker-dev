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

# activate dotfiles via dotbot FIRST (symlinks the fish config, git, nvim, tmux,
# scripts...). This must run before fisher so that ~/.config/fish/fish_plugins is
# symlinked into place for `fisher update` to read.
bash ~/.config/dotfiles/install

# Bootstrap fisher and install every plugin listed in fish_plugins (nvm.fish,
# pure, fish-exa, autopair, sponge, bass, ...). This MUST run inside fish: both
# `curl | source` and the `fisher` function are fish-only, so running them under
# this bash script silently fails. `fisher install` bootstraps fisher itself;
# `fisher update` then syncs everything declared in the symlinked fish_plugins.
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher update'
popd