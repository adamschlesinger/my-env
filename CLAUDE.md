# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an Ansible role (`badplanning.my-env`) for provisioning macOS development environments. It installs packages, configures dotfiles, and sets up tools. The `run.yaml` playbook at the root applies the role to `localhost`.

## Commands

**Apply the full environment:**
```bash
ansible-playbook run.yaml
```

**Apply with overrides (e.g., skip homebrew):**
```bash
ansible-playbook run.yaml -e "run_homebrew_tasks=false"
```

**Sync current machine state back into the repo:**
```bash
./sync.sh
```
This pulls dotfiles from `$HOME` and updates package lists in `defaults/main/` using `yq`. Requires `yq` (`brew install yq`).

**Run a specific task file only:**
```bash
ansible-playbook run.yaml -e "run_homebrew_tasks=false run_ssh_tasks=false run_python_tasks=false run_node_tasks=false run_npm_tasks=false run_ruby_tasks=false run_rust_tasks=false run_vim_tasks=false run_fonts_tasks=false run_git_tasks=false run_terminal_tasks=false run_vscode_tasks=false run_jetbrains_tasks=false run_macos_tasks=false" -e "run_homebrew_tasks=true"
```

## Architecture

The repo is structured as a standard Ansible role:

- **`run.yaml`** — Playbook entry point. Passes `user_name` and `user_email` as role vars (used by `tasks/git.yaml` to populate `.gitconfig`).
- **`tasks/main.yaml`** — Orchestrates all task files, each guarded by a `run_*_tasks` boolean flag.
- **`vars/main.yaml`** — Feature flags (`run_homebrew_tasks`, `run_ssh_tasks`, etc.). All default to `true` except `run_jetbrains_tasks`.
- **`defaults/main/`** — Package/tool lists consumed by task files (e.g., `homebrew.yaml` has `taps`, `brews`, `casks`; `python.yaml`, `npm.yaml`, `ruby.yaml`, `rust.yaml` have their respective package lists; `fonts.yaml` lists fonts to download and patch).
- **`defaults/windows/`** — Windows package manager lists (choco, scoop, winget) — not currently wired into the playbook.
- **`tasks/`** — One YAML file per component (homebrew, ssh, python, node, npm, ruby, rust, vim, fonts, git, terminal, vscode, jetbrains, macos).
- **`files/dotfiles/`** — Dotfiles copied verbatim to `$HOME`. The `git.yaml` task post-processes `.gitconfig` by replacing `GITCONFIG_NAME` and `GITCONFIG_EMAIL` tokens. Kitty config lives at `files/dotfiles/.config/kitty/kitty.conf`.
- **`files/vscode/settings.json`** — VSCode settings synced from `~/Library/Application Support/Code/User/settings.json`.
- **`meta/main.yaml`** — Ansible Galaxy metadata (role name: `my-env`, namespace: `badplanning`, platform: Mac).

## Workflow

**To add a new package:** Edit the appropriate file in `defaults/main/` (e.g., add a brew formula to `homebrew.yaml`).

**To update package lists from the current machine:** Run `./sync.sh`, which regenerates `defaults/main/homebrew.yaml` and the language package files.

**To add a new task category:** Create a task file in `tasks/`, add a feature flag to `vars/main.yaml`, and wire it into `tasks/main.yaml` with a `when:` guard.

**To update dotfiles:** Edit files in `files/dotfiles/` directly, or run `./sync.sh` to pull from `$HOME`.

## Known Patterns & Decisions

- **Terminal:** Kitty replaces Alacritty. All tmux and vim key bindings in `kitty.conf` use `send_text all` to pass raw sequences through to tmux/vim.
- **Zsh completion:** `zsh-autocomplete` was removed due to crashes when combined with `fzf --zsh`. Completion is now handled by `compinit` + `zsh-completions` (via FPATH) + `fzf`.
- **`BREW_PREFIX`:** `.zshrc` caches `$(brew --prefix)` at the top to avoid repeated subshell spawns.
- **Rust defaults:** `defaults/main/rust.yaml` should only contain valid `cargo install` crate names — not rustup toolchain components (rustdoc, rust-gdb, etc.).
- **Ruby/Python defaults:** These lists should contain only explicitly installed top-level packages. `sync.sh` captures the full transitive dependency tree, so manually prune after running it.
- **npm install:** Only `tasks/npm.yaml` installs npm packages. `tasks/node.yaml` only ensures Node itself is present.
