#!/usr/bin/env bash

script_path=$(readlink -f "$0")
files_dir=$(dirname "$script_path")

cp "$HOME/.alacritty.toml" "$files_dir"
cp "$HOME/.gitconfig" "$files_dir"
cp "$HOME/.p10k.zsh" "$files_dir"
cp "$HOME/.tmux.conf" "$files_dir"
cp "$HOME/.zshrc" "$files_dir"

cp "$HOME/.config/lsd/config.yaml" "$file_dir/lsd_config.yaml"

cp "$HOME/.vim_runtime/my_configs.vim" "$files_dir"