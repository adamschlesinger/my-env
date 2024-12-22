#!/usr/bin/env bash

script_path=$(readlink -f "$0")
script_dir=$(dirname "$script_path")
files_dir="$script_dir/files/dotfiles"

sync() {
    rsync --archive --relative "$HOME/./$1" "$files_dir/"
}

# home dotfiles
sync ".alacritty.toml"
sync ".custom.omp.yaml"
sync ".gitconfig"
sync ".tmux.conf"
sync ".zshenv"
sync ".zprofile"
sync ".zshrc"

# lsd
sync ".config/lsd/config.yaml"

# vim
sync ".vim_runtime/my_configs.vim"

# tmux
sync ".config/tmux-powerline/"
