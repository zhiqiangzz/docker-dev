distro_codename=$1
llvm_version=$2

# install LLVM/Clang toolchain from apt.llvm.org
curl -s -o - https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc > /dev/null
cat <<EOF > /etc/apt/sources.list.d/llvm.list
deb http://apt.llvm.org/$distro_codename/ llvm-toolchain-$distro_codename-$llvm_version main
deb-src http://apt.llvm.org/$distro_codename/ llvm-toolchain-$distro_codename-$llvm_version main
EOF

apt update
apt install -y \
	clang-$llvm_version \
	lld-$llvm_version \
	lldb-$llvm_version \
	llvm-$llvm_version \
	clangd-$llvm_version \
	clang-format-$llvm_version

update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$llvm_version 100
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$llvm_version 100
update-alternatives --install /usr/bin/opt opt /usr/bin/opt-$llvm_version 100
update-alternatives --install /usr/bin/llc llc /usr/bin/llc-$llvm_version 100
update-alternatives --install /usr/bin/lld lld /usr/bin/lld-$llvm_version 100
update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-$llvm_version 100
update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-$llvm_version 100
update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-$llvm_version 100
update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-$llvm_version 100
update-alternatives --install /usr/bin/FileCheck FileCheck /usr/bin/FileCheck-$llvm_version 100
