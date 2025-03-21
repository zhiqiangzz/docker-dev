distro=$1

curl -o /tmp/cuda-keyring.deb -L https://developer.download.nvidia.com/compute/cuda/repos/$distro/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i /tmp/cuda-keyring.deb && \
    rm -f /tmp/cuda-keyring.deb

# # install nvidia driver https://ubuntu.com/server/docs/nvidia-drivers-installation
# ubuntu-drivers --gpgpu install nvidia:550

# install cuda driver and toolkit
apt update && apt install -y cuda-toolkit