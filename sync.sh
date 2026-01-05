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

# Update homebrew defaults
update_homebrew_defaults() {
    echo "Updating homebrew defaults..."
    
    # Check if yq is available
    if ! command -v yq >/dev/null 2>&1; then
        echo "Error: yq is required but not installed. Please install yq first."
        echo "You can install it with: brew install yq"
        return 1
    fi
    
    # Get currently installed packages (separate commands for formulas and casks)
    installed_formulas=$(brew list --installed-on-request --formula --full-name | sort)
    installed_casks=$(brew list --cask | sort)
    
    # Extract taps from formulas (anything with a slash that's not homebrew/core)
    taps=$(echo "$installed_formulas" | grep '/' | sed 's|/[^/]*$||' | grep -v '^homebrew/core$' | sort -u)
    
    homebrew_file="$script_dir/defaults/main/homebrew.yaml"
    
    # Create a new YAML structure using yq
    echo "---" > "$homebrew_file"
    
    # Add taps if any exist
    if [[ -n "$taps" ]]; then
        yq eval '.taps = []' -i "$homebrew_file"
        while IFS= read -r tap; do
            [[ -n "$tap" ]] && yq eval ".taps += [\"$tap\"]" -i "$homebrew_file"
        done <<< "$taps"
    fi
    
    # Add brews
    yq eval '.brews = []' -i "$homebrew_file"
    while IFS= read -r formula; do
        [[ -n "$formula" ]] && yq eval ".brews += [\"$formula\"]" -i "$homebrew_file"
    done <<< "$installed_formulas"
    
    # Add casks
    yq eval '.casks = []' -i "$homebrew_file"
    while IFS= read -r cask; do
        [[ -n "$cask" ]] && yq eval ".casks += [\"$cask\"]" -i "$homebrew_file"
    done <<< "$installed_casks"
    
    echo "Homebrew defaults updated successfully!"
}

# Run homebrew sync
if command -v brew >/dev/null 2>&1; then
    update_homebrew_defaults
else
    echo "Homebrew not found, skipping homebrew defaults update"
fi
