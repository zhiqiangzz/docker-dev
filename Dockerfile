FROM ubuntu:jammy

ARG USER_PASSWD

COPY apt/cn_sources.list /etc/apt/sources.list
RUN apt update 
RUN apt install -y \
    ca-certificates && update-ca-certificates

RUN apt update && apt install -y \
    software-properties-common gpg gnupg gnupg2 \
    openssh-server sudo zsh curl wget vim locales

ENV TZ=Asia/Shanghai
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN useradd -m -s $(which zsh) zhiqiangz && \
    echo zhiqiangz:${USER_PASSWD} | chpasswd && \
    usermod -aG sudo zhiqiangz

RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'AllowUsers zhiqiangz' >> /etc/ssh/sshd_config

COPY install_pkg/basic_install.sh /tmp/basic_install.sh
COPY install_pkg/llvm_install_18.sh /tmp/llvm_install.sh
COPY install_pkg/cuda_install.sh /tmp/cuda_install.sh
RUN bash /tmp/basic_install.sh
# RUN bash /tmp/llvm_install.sh
# RUN bash /tmp/cuda_install.sh

COPY install_pkg/rust_install.sh /tmp/rust_install.sh

USER zhiqiangz
WORKDIR /home/zhiqiangz
COPY --chown=zhiqiangz:zhiqiangz install_pkg/user_basic_install.sh user_basic_install.sh
COPY --chown=zhiqiangz:zhiqiangz set_proxy.sh set_proxy.sh
RUN bash user_basic_install.sh
# RUN bash /tmp/rust_install.sh

USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]