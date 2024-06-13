#!/usr/bin/env bash

script_path=$(readlink -f "$0")
script_dir=$(dirname "$script_path")
files_dir="$script_dir/files"

cp "$HOME/.alacritty.toml" "$files_dir"
cp "$HOME/.gitconfig" "$files_dir"
cp "$HOME/.p10k.zsh" "$files_dir"
cp "$HOME/.tmux.conf" "$files_dir"
cp "$HOME/.zshrc" "$files_dir"

cp "$HOME/.config/lsd/config.yaml" "$file_dir/lsd_config.yaml"

cp "$HOME/.vim_runtime/my_configs.vim" "$files_dir"