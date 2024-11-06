#!/usr/bin/env bash

script_path=$(readlink -f "$0")
script_dir=$(dirname "$script_path")
files_dir="$script_dir/files"

# home dotfiles
cp "$HOME/.alacritty.toml" "$files_dir"
cp "$HOME/.gitconfig" "$files_dir"
cp "$HOME/.p10k.zsh" "$files_dir"
cp "$HOME/.tmux.conf" "$files_dir"
cp "$HOME/.zshrc" "$files_dir"

# lsd
cp "$HOME/.config/lsd/config.yaml" "$file_dir/lsd_config.yaml"

# vim
cp "$HOME/.vim_runtime/my_configs.vim" "$files_dir"

# tmux
cp -R "$HOME/.config/tmux-powerline" "$file_dir"
