export all_proxy_server=socks5://172.17.0.1:10808
export http_proxy_server=http://172.17.0.1:10808
export https_proxy_server=http://172.17.0.1:10808


[[ -f /etc/apt/apt.conf ]] || \
sudo bash -c 'cat << EOF > /etc/apt/apt.conf
Acquire::http::Proxy "http://172.17.0.1:10808";
Acquire::https::Proxy "http://172.17.0.1:10808";
EOF'
