# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Docker-based dev environment for the user `zhiqiangz`. The artifact is an Ubuntu 24.04 (noble) image with optional CUDA toolkit and optional LLVM toolchain, run as a long-lived per-host container that you SSH into. There is no application code here — only the image definition, install scripts, and a helper to derive a shell-script equivalent of the Dockerfile.

## Build & run

The canonical commands live in `README.md`. Two things to remember:

- `--build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g)` is **required** at build time. The Dockerfile uses these to create the in-container `zhiqiangz` user with the same UID/GID as the host user, so the bind-mounted `/home/zhiqiangz` has matching ownership on both sides. Without these args the build defaults to UID/GID 1000, which collides with the base image's prebuilt `ubuntu` user; the Dockerfile handles this by deleting whichever existing user/group occupies the requested UID/GID before creating `zhiqiangz`.
- Optional features are toggled with build args, off by default:
  - `--build-arg INSTALL_CUDA=true` → runs `install_pkg/cuda_install.sh` (CUDA 12.8 toolkit via NVIDIA's apt repo)
  - `--build-arg INSTALL_LLVM=true --build-arg LLVM_VERSION=21` → installs the LLVM/Clang toolchain from apt.llvm.org and registers `update-alternatives` for `clang`, `clangd`, `lldb`, etc.

At run time, the container is SSH-only: `docker-entrypoint.sh` reads `$SSH_PUBLIC_KEY` (passed via `-e SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"`) and writes it to `/home/zhiqiangz/.ssh/authorized_keys`. `sshd_config` is set to `PermitRootLogin no` + `AllowUsers zhiqiangz` + pubkey-only, and the user's password is locked. There is no password fallback.

Each container expects an existing custom bridge network (creation snippet in `README.md`) and is pinned to a fixed `--ip`, so SSH targets are stable.

## Dockerfile structure

The Dockerfile has two distinct phases separated by `USER $user`:

1. **Root phase** — apt installs, locale/timezone, user creation, sshd config, third-party tools (eza, fastfetch, fd, dust, fzf) installed directly to system paths. Optional CUDA/LLVM blocks live here.
2. **User phase** (`USER $user`, `WORKDIR /home/$user`) — runs `install_pkg/user_basic_install.sh`, which installs per-user tooling (zoxide, tpm, dotfiles clone). Anything that writes into `$HOME` belongs in this phase.

After the user phase, the Dockerfile switches back to `USER root` only to install the entrypoint and clean apt caches.

`install_pkg/basic_install.sh` is **not** invoked by the Dockerfile — it's an older standalone script targeting ubuntu2204 and is kept for reference / running setup on a bare host. The active in-image installs are inlined into the Dockerfile.

## `convert_dockerfile2sh.py`

Converts a Dockerfile into an approximate shell script for running the same setup directly on a host (no Docker). Rules:

- `ENV A=1 B=2` → `export A=1 B=2`
- `RUN <cmd>` → `<cmd>` (prefix stripped)
- `WORKDIR /x` → `cd /x`
- `FROM`, `COPY`, `USER`, `ENTRYPOINT`, `CMD`, `EXPOSE` lines are dropped
- Anything between marker comments `# docker build only begin` and `# docker build only end` is skipped (inclusive) — use this to wrap Dockerfile-only sections (e.g. user creation) that don't apply when running on a real host.

Usage: `./convert_dockerfile2sh.py Dockerfile -o setup.sh`.

## Network proxy

`set_proxy.sh` (COPY'd into the image) configures a SOCKS5/HTTP proxy pointing at `172.17.0.1:10808` (the default docker0 host gateway from inside a container) and writes `/etc/apt/apt.conf`. It's not sourced automatically — invoke it manually inside the container when behind a proxied network. `apt/cn_sources.list` is a China-mirror sources list kept available but not enabled by default (the Dockerfile comment history notes "disable CN related by default").
