export HTTPS_PROXY=http://sys-proxy-rd-relay.byted.org:8118
export https_proxy=http://sys-proxy-rd-relay.byted.org:8118
export HTTP_PROXY=http://sys-proxy-rd-relay.byted.org:8118
export http_proxy=http://sys-proxy-rd-relay.byted.org:8118
export http_proxy_server=http://sys-proxy-rd-relay.byted.org:8118
export all_proxy_server=http://sys-proxy-rd-relay.byted.org:8118

[[ -f /etc/apt/apt.conf ]] || \
sudo bash -c 'cat << EOF > /etc/apt/apt.conf
Acquire::http::Proxy "http://sys-proxy-rd-relay.byted.org:8118";
Acquire::https::Proxy "http://sys-proxy-rd-relay.byted.org:8118";
EOF'