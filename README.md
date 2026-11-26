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

## macOS desktop layer

Karabiner `caps-hyper.json`: tap Caps Lock for `Esc`, hold it for Hyper
(cmd+ctrl+opt+shift). AeroSpace workspaces: Hyper+`E` Emacs, `B` browser, `S`
Slack, `M` meetings. Ghostty is the Hyper+`` ` `` quick terminal. Hyper+`Space`
starts the AeroSpace `launch` mode: `e` Emacs, `b` browser, `l` Linear, `p` PRs
for review, `Esc` cancel.

## Neovim inside Doom Emacs

Neovim edits code inside Doom Emacs. Each project root gets one
terminal buffer, `*nvim:<project>*`, that runs
`nvim --listen $TMPDIR/nvim-<project>-<hash>.sock` with `NVIM_IN_EMACS=1`.
The hash keeps two repos with the same name apart. Emacs side:
`config/doom/lisp/nvim-bridge.el`. Neovim side: `config/nvim/lua/emacs_bridge.lua`,
loaded only when `NVIM_IN_EMACS` is set. Outside Emacs, Neovim is unchanged.

The Neovim buffer uses ghostel `ghostel-char-mode` in evil Emacs state. Char
mode sends every key to Neovim, `Esc`, `C-c`, `C-x` and `C-h` too. Doom's
`M-SPC` leader still works, because it lives in an emulation keymap. `M-RET`
leaves char mode, and `C-z` switches the buffer to evil normal state.

| Where | Key | Action |
|-------|-----|--------|
| Emacs | `SPC o n` | Show this project's Neovim, start it when needed |
| Emacs | `SPC f n` | Open the current file in Neovim at point |
| Emacs | `SPC l e` | Open the `file:line[:col]` at point in Neovim (logs, traces, org) |
| Magit / Forge diffs | `C-RET` | Open the worktree file at the hunk line (`RET` still visits in Emacs) |
| consult-ripgrep, `SPC s p` | `C-;` then `n` | Embark: open the match in Neovim |
| Embark on a file | `n` | Open the file in Neovim |
| Emacs normal state | `C-h/j/k/l` | `windmove`. Help is still on `SPC h` |
| Neovim | `C-h/j/k/l` | Move between splits, into the Emacs window at the edge |
| Neovim | `M-SPC` | Doom leader, for example `M-SPC g g` |
| Neovim | `<leader>hg` | Magit status for the cwd |

`my/nvim-lsp-off-modes` lists the major modes that Neovim edits. Doom starts
no LSP client in them.

To restart a stuck Neovim buffer, kill it with `SPC b k` and press `SPC o n`.
`SPC o n` also restarts Neovim when the process is gone or the socket is stale.
`<leader>e` stays the diagnostic float, so the Magit hand-off uses `<leader>hg`.
