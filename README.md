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

## Troubleshooting

### vim-tmux-navigator: "server exited unexpectedly"

If `TmuxNavigateDown` (or any direction) works from a zsh pane but not from inside nvim, the cause is likely a **tmux version mismatch** between the running server and the client binary in `$PATH`.

The vim-tmux-navigator plugin shells out to `tmux select-pane` to switch panes. If the tmux server was started with one version (e.g. Nix's 3.6a) but nvim resolves `tmux` to a different version (e.g. Fedora's 3.5a via `/usr/bin/tmux`), the client can't communicate with the server and silently fails.

Navigation from zsh panes still works because tmux handles those keybindings internally (via `if-shell` in `tmux.conf`) without spawning a client process.

**Diagnosis:**

```bash
# Check which tmux the server is running
ls -la /proc/$(pgrep -f "tmux new")/exe

# Check which tmux is first in PATH
which tmux
```

**Fix:** Remove the duplicate tmux so only one version exists, or ensure PATH ordering puts the correct one first.
