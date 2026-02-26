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
sync ".config/kitty/"
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

# VSCode settings
echo "--- Syncing VSCode settings ---"
if [ -f "$HOME/Library/Application Support/Code/User/settings.json" ]; then
    echo "Syncing VSCode settings..."
    mkdir -p "$files_dir/../vscode"
    cp "$HOME/Library/Application Support/Code/User/settings.json" "$files_dir/../vscode/"
    echo "  ✓ Successfully synced VSCode settings"
else
    echo "  ⚠ VSCode settings not found"
fi

# JetBrains settings
# echo "--- Syncing JetBrains settings ---"
# jetbrains_dir="$HOME/Library/Application Support/JetBrains"
# if [ -d "$jetbrains_dir" ]; then
#     echo "Syncing JetBrains IDE settings..."
#     mkdir -p "$files_dir/../jetbrains"
#     # Sync common IDE settings (adjust paths as needed for your specific IDEs)
#     for ide_dir in "$jetbrains_dir"/*; do
#         if [ -d "$ide_dir" ] && [[ "$(basename "$ide_dir")" != "Toolbox" ]]; then
#             ide_name=$(basename "$ide_dir")
#             echo "  Syncing $ide_name settings..."
#             mkdir -p "$files_dir/../jetbrains/$ide_name"
#             # Copy key configuration files (adjust as needed)
#             if [ -d "$ide_dir/options" ]; then
#                 cp -r "$ide_dir/options" "$files_dir/../jetbrains/$ide_name/" 2>/dev/null || true
#             fi
#             if [ -d "$ide_dir/keymaps" ]; then
#                 cp -r "$ide_dir/keymaps" "$files_dir/../jetbrains/$ide_name/" 2>/dev/null || true
#             fi
#         fi
#     done
#     echo "  ✓ Successfully synced JetBrains settings"
# else
#     echo "  ⚠ JetBrains settings directory not found"
# fi

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

# Update development environment defaults
update_dev_defaults() {
    echo "--- Updating development environment defaults ---"
    
    # Python packages (using pyenv global environment)
    if command -v pyenv >/dev/null 2>&1; then
        echo "Getting installed Python packages from pyenv global environment..."
        # Use pyenv's global python and pip
        eval "$(pyenv init -)"
        if command -v "$HOME/.pyenv/shims/pip" >/dev/null 2>&1; then
            python_packages=$("$HOME/.pyenv/shims/pip" list --format=freeze | cut -d'=' -f1 | sort)
            package_count=$(echo "$python_packages" | wc -l | tr -d ' ')
            echo "  Found $package_count Python packages in global environment"
            
            python_file="$script_dir/defaults/main/python.yaml"
            echo "Updating file: $python_file"
            echo "---" > "$python_file"
            yq eval '.python_packages = []' -i "$python_file"
            while IFS= read -r package; do
                if [[ -n "$package" ]]; then
                    yq eval ".python_packages += [\"$package\"]" -i "$python_file"
                fi
            done <<< "$python_packages"
            echo "  ✓ Updated Python packages"
        else
            echo "  ⚠ pyenv pip not found, skipping Python packages"
        fi
    elif command -v pip >/dev/null 2>&1; then
        echo "Getting installed Python packages from system pip..."
        python_packages=$(pip list --format=freeze | cut -d'=' -f1 | sort)
        package_count=$(echo "$python_packages" | wc -l | tr -d ' ')
        echo "  Found $package_count Python packages"
        
        python_file="$script_dir/defaults/main/python.yaml"
        echo "Updating file: $python_file"
        echo "---" > "$python_file"
        yq eval '.python_packages = []' -i "$python_file"
        while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                yq eval ".python_packages += [\"$package\"]" -i "$python_file"
            fi
        done <<< "$python_packages"
        echo "  ✓ Updated Python packages"
    else
        echo "  ⚠ Neither pyenv nor pip found, skipping Python packages"
    fi
    
    # Node.js packages
    if command -v npm >/dev/null 2>&1; then
        echo "Getting installed global npm packages..."
        npm_packages=$(npm list -g --depth=0 --parseable | tail -n +2 | xargs -I {} basename {} | grep -v '^npm@' | sort)
        package_count=$(echo "$npm_packages" | wc -l | tr -d ' ')
        echo "  Found $package_count npm packages"
        
        npm_file="$script_dir/defaults/main/npm.yaml"
        echo "Updating file: $npm_file"
        echo "---" > "$npm_file"
        yq eval '.npm_packages = []' -i "$npm_file"
        while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                yq eval ".npm_packages += [\"$package\"]" -i "$npm_file"
            fi
        done <<< "$npm_packages"
        echo "  ✓ Updated npm packages"
    else
        echo "  ⚠ npm not found, skipping npm packages"
    fi
    
    # Ruby gems (using rbenv global environment)
    if command -v rbenv >/dev/null 2>&1; then
        echo "Getting installed Ruby gems from rbenv global environment..."
        # Use rbenv's global ruby and gem
        eval "$(rbenv init -)"
        if command -v "$HOME/.rbenv/shims/gem" >/dev/null 2>&1; then
            ruby_gems=$("$HOME/.rbenv/shims/gem" list --no-versions | grep -v '^$' | sort)
            gem_count=$(echo "$ruby_gems" | wc -l | tr -d ' ')
            echo "  Found $gem_count Ruby gems in global environment"
            
            ruby_file="$script_dir/defaults/main/ruby.yaml"
            echo "Updating file: $ruby_file"
            echo "---" > "$ruby_file"
            yq eval '.ruby_gems = []' -i "$ruby_file"
            while IFS= read -r gem; do
                if [[ -n "$gem" ]]; then
                    yq eval ".ruby_gems += [\"$gem\"]" -i "$ruby_file"
                fi
            done <<< "$ruby_gems"
            echo "  ✓ Updated Ruby gems"
        else
            echo "  ⚠ rbenv gem not found, skipping Ruby gems"
        fi
    elif command -v gem >/dev/null 2>&1; then
        echo "Getting installed Ruby gems from system gem..."
        ruby_gems=$(gem list --no-versions | grep -v '^$' | sort)
        gem_count=$(echo "$ruby_gems" | wc -l | tr -d ' ')
        echo "  Found $gem_count Ruby gems"
        
        ruby_file="$script_dir/defaults/main/ruby.yaml"
        echo "Updating file: $ruby_file"
        echo "---" > "$ruby_file"
        yq eval '.ruby_gems = []' -i "$ruby_file"
        while IFS= read -r gem; do
            if [[ -n "$gem" ]]; then
                yq eval ".ruby_gems += [\"$gem\"]" -i "$ruby_file"
            fi
        done <<< "$ruby_gems"
        echo "  ✓ Updated Ruby gems"
    else
        echo "  ⚠ Neither rbenv nor gem found, skipping Ruby gems"
    fi
    
    # Rust packages
    if command -v cargo >/dev/null 2>&1; then
        echo "Getting installed Rust packages..."
        if [ -d "$HOME/.cargo/bin" ]; then
            # Get cargo-installed binaries (excluding rustc, cargo, etc.)
            rust_packages=$(ls "$HOME/.cargo/bin" | grep -v -E '^(cargo|rustc|rustup|rustfmt|clippy)' | sort)
            package_count=$(echo "$rust_packages" | wc -l | tr -d ' ')
            echo "  Found $package_count Rust packages"
            
            rust_file="$script_dir/defaults/main/rust.yaml"
            echo "Updating file: $rust_file"
            echo "---" > "$rust_file"
            yq eval '.rust_packages = []' -i "$rust_file"
            while IFS= read -r package; do
                if [[ -n "$package" ]]; then
                    yq eval ".rust_packages += [\"$package\"]" -i "$rust_file"
                fi
            done <<< "$rust_packages"
            echo "  ✓ Updated Rust packages"
        else
            echo "  ⚠ Cargo bin directory not found"
        fi
    else
        echo "  ⚠ cargo not found, skipping Rust packages"
    fi
}

# Run homebrew sync
echo "--- Checking homebrew ---"
if command -v brew >/dev/null 2>&1; then
    echo "✓ Homebrew found"
    update_homebrew_defaults
else
    echo "✗ Homebrew not found, skipping homebrew defaults update"
fi

# Run development environment sync
update_dev_defaults

echo ""
echo "=== Sync completed ==="
