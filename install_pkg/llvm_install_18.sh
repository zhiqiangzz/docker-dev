
curl -s -o - https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
cat <<EOF > /etc/apt/sources.list.d/llvm.list
# deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy main
# deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy main
# 18
deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main
deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main
# # 19
# deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-19 main
# deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-19 main
EOF

apt update
LLVM_VERSION=18
apt install -y \
	clang-$LLVM_VERSION \
	lld-$LLVM_VERSION \
	lldb-$LLVM_VERSION \
    llvm-$LLVM_VERSION \
	clangd-$LLVM_VERSION 

update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$LLVM_VERSION 100 
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$LLVM_VERSION 100 
update-alternatives --install /usr/bin/opt opt /usr/bin/opt-$LLVM_VERSION 100 
update-alternatives --install /usr/bin/llc llc /usr/bin/llc-$LLVM_VERSION 100 
update-alternatives --install /usr/bin/lld lld /usr/bin/lld-$LLVM_VERSION 100 
update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-$LLVM_VERSION 100 
update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-$LLVM_VERSION 100 