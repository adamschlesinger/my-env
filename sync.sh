#!/usr/bin/env bash

script_path=$(readlink -f "$0")
script_dir=$(dirname "$script_path")
files_dir="$script_dir/files/dotfiles"

echo "=== Starting dotfiles sync ==="
echo "Script directory: $script_dir"
echo "Files directory: $files_dir"
echo ""

sync() {
    echo "Syncing: $1"
    if rsync --archive --relative "$HOME/./$1" "$files_dir/"; then
        echo "  ✓ Successfully synced $1"
    else
        echo "  ✗ Failed to sync $1"
    fi
}

echo "--- Syncing home dotfiles ---"
sync ".alacritty.toml"
sync ".custom.omp.yaml"
sync ".gitconfig"
sync ".tmux.conf"
sync ".zshenv"
sync ".zprofile"
sync ".zshrc"

echo ""
echo "--- Syncing application configs ---"
# lsd
sync ".config/lsd/config.yaml"

# vim
sync ".vim_runtime/my_configs.vim"

# tmux
sync ".config/tmux-powerline/"

echo ""

# Update homebrew defaults
update_homebrew_defaults() {
    echo "--- Updating homebrew defaults ---"
    
    # Check if yq is available
    if ! command -v yq >/dev/null 2>&1; then
        echo "✗ Error: yq is required but not installed. Please install yq first."
        echo "  You can install it with: brew install yq"
        return 1
    fi
    echo "✓ yq found"
    
    # Get currently installed packages (separate commands for formulas and casks)
    echo "Getting installed formulas..."
    installed_formulas=$(brew list --installed-on-request --formula --full-name | sort)
    formula_count=$(echo "$installed_formulas" | wc -l | tr -d ' ')
    echo "  Found $formula_count installed formulas"
    
    echo "Getting installed casks..."
    installed_casks=$(brew list --cask | sort)
    cask_count=$(echo "$installed_casks" | wc -l | tr -d ' ')
    echo "  Found $cask_count installed casks"
    
    # Extract taps from formulas (anything with a slash that's not homebrew/core)
    echo "Extracting taps from formulas..."
    taps=$(echo "$installed_formulas" | grep '/' | sed 's|/[^/]*$||' | grep -v '^homebrew/core$' | sort -u)
    tap_count=$(echo "$taps" | grep -c . || echo "0")
    echo "  Found $tap_count custom taps"
    if [[ $tap_count -gt 0 ]]; then
        echo "$taps" | sed 's/^/    - /'
    fi
    
    homebrew_file="$script_dir/defaults/main/homebrew.yaml"
    echo "Updating file: $homebrew_file"
    
    # Create a new YAML structure using yq
    echo "---" > "$homebrew_file"
    
    # Add taps if any exist
    if [[ -n "$taps" ]]; then
        echo "Adding taps section..."
        yq eval '.taps = []' -i "$homebrew_file"
        while IFS= read -r tap; do
            if [[ -n "$tap" ]]; then
                echo "  Adding tap: $tap"
                yq eval ".taps += [\"$tap\"]" -i "$homebrew_file"
            fi
        done <<< "$taps"
    fi
    
    # Add brews
    echo "Adding brews section..."
    yq eval '.brews = []' -i "$homebrew_file"
    while IFS= read -r formula; do
        if [[ -n "$formula" ]]; then
            yq eval ".brews += [\"$formula\"]" -i "$homebrew_file"
        fi
    done <<< "$installed_formulas"
    echo "  Added $formula_count formulas"
    
    # Add casks
    echo "Adding casks section..."
    yq eval '.casks = []' -i "$homebrew_file"
    while IFS= read -r cask; do
        if [[ -n "$cask" ]]; then
            yq eval ".casks += [\"$cask\"]" -i "$homebrew_file"
        fi
    done <<< "$installed_casks"
    echo "  Added $cask_count casks"
    
    echo "✓ Homebrew defaults updated successfully!"
}

# Run homebrew sync
echo "--- Checking homebrew ---"
if command -v brew >/dev/null 2>&1; then
    echo "✓ Homebrew found"
    update_homebrew_defaults
else
    echo "✗ Homebrew not found, skipping homebrew defaults update"
fi

echo ""
echo "=== Sync completed ==="
