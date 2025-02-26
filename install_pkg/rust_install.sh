curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 
. "$HOME/.cargo/env"
rustup update

# Rust package install 
cargo install --locked yazi-fm yazi-cli