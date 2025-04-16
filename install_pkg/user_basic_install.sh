#!/bin/bash

pushd $HOME
# install zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# install miniconda 
mkdir -p miniconda3
curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda3/miniconda.sh
bash miniconda3/miniconda.sh -b -u -p miniconda3
rm miniconda3/miniconda.sh
source miniconda3/bin/activate
conda init --all

conda create --name byteir-dev python=3.9 -y
conda activate byteir-dev
python3 -m pip install --no-cache-dir \
        lit \
        numpy \
        pytest \
        cmake \
        pybind11 \
        black \
        torch==2.0.1

python3 -m pip install --no-cache-dir \
        onnx==1.13.0 \
        onnxruntime==1.13.1

# install tmux plugins manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
popd