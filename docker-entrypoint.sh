#!/bin/bash
set -e

USER=$1
HOME_DIR=/home/$USER
SSH_DIR=$HOME_DIR/.ssh
AUTH_KEYS=$SSH_DIR/authorized_keys

if [ -n "$SSH_PUBLIC_KEY" ]; then
    mkdir -p "$SSH_DIR"
    echo "$SSH_PUBLIC_KEY" > "$AUTH_KEYS"
    chmod 700 "$SSH_DIR"
    chmod 600 "$AUTH_KEYS"
    chown -R $USER:$USER "$SSH_DIR"
fi

exec "$@"
