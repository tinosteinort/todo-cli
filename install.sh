#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"
EXECUTABLE_SCRIPT="$DIST_DIR/todo"
COMPLETION_SCRIPT="$DIST_DIR/todo-completion.bash"

TARGET_BIN_DIR="$HOME/bin"
TARGET_COMPLETION_DIR="/etc/bash_completion.d"


if [ ! -d "$TARGET_BIN_DIR" ]
then
    echo "There is no $TARGET_BIN_DIR"
    echo 'Create it and put it into your PATH: PATH=$PATH:$HOME/bin"'
    exit 1
fi
cp "$EXECUTABLE_SCRIPT" "$TARGET_BIN_DIR"


if [ ! -d "$TARGET_COMPLETION_DIR" ]
then
    echo "There is no $TARGET_BIN_DIR. Could not install completion script."
    exit 1
fi
cp "$COMPLETION_SCRIPT" "$TARGET_COMPLETION_DIR"
