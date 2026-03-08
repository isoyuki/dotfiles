# Dotfiles

Config files managed via [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
.
├── config/     # ~/.config/ entries (nvim, tmux, awesome, rofi, kitty, etc.)
├── home/       # ~/ entries (.zshrc, .gitconfig, .fonts, .vim, etc.)
└── system/     # System-level files (/etc/, /usr/local/bin/)
```

## Usage

```bash
# Symlink everything
make all

# Or individually
make home      # Links home/ -> ~/
make config    # Links config/ -> ~/.config/
make system    # Links system/ -> / (requires sudo)
```

## Submodules

This repo uses git submodules for zsh plugins, themes, and alacritty color schemes.

**Clone with submodules:**

```bash
git clone --recurse-submodules <repo-url>
```

**Already cloned? Initialize submodules after the fact:**

```bash
git submodule init
git submodule update
```

**Update all submodules to latest upstream:**

```bash
git submodule update --remote
```

## Nix integration

These dotfiles are referenced by separate Nix repos that use `mkOutOfStoreSymlink`
to link configs into place via home-manager:

- **~/nix-linux** — Fedora (home-manager standalone)
- **~/nix-darwin** — macOS (nix-darwin + home-manager)

You can use either Stow (`make all`) or the Nix repos to deploy these files.
