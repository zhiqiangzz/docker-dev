FROM ubuntu:jammy

ARG USER_PASSWD
ENV distro=ubuntu2204
ENV distro_codename=jammy

# COPY apt/cn_sources.list /etc/apt/sources.list
RUN apt update 
RUN apt install -y \
    ca-certificates && update-ca-certificates

RUN apt update && apt install -y \
    software-properties-common gpg gnupg gnupg2 \
    openssh-server sudo zsh curl wget vim locales

RUN useradd -m -s $(which zsh) zhiqiangz && \
    echo zhiqiangz:${USER_PASSWD} | chpasswd && \
    usermod -aG sudo zhiqiangz

RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'AllowUsers zhiqiangz' >> /etc/ssh/sshd_config

RUN curl -o /tmp/fd.deb -L https://github.com/sharkdp/fd/releases/download/v10.2.0/fd_10.2.0_amd64.deb && \
    dpkg -i /tmp/fd.deb && \
    rm -f /tmp/fd.deb

RUN apt update 

RUN apt install -y \
    net-tools telnet iputils-ping \
    unzip p7zip-full 7zip\
    ripgrep \
    tmux \
    git

USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
