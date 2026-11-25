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

## Agent cockpit (Doom Emacs)

One GUI Emacs frame is the home base. Claude Code runs the agents. `cc-hubd`
(`config/cc-hub/cc-hubd`, launchd agent from `~/nix-darwin`) polls
`claude agents --json --all`, reads hook events from `config/cc-hub/cc-event`,
stores state in `~/.local/state/cc/hub.db`, serves `127.0.0.1:7777` only, and
pokes Emacs through `emacsclient` when a session changes. Emacs reads only from
`cc-hubd` and from async `curl`/`gh`/`claude` subprocesses.

Secrets come from auth-source (Keychain or `~/.authinfo.gpg`), never from this repo:

| Integration | auth-source entry |
|---|---|
| Linear | `machine api.linear.app password <personal key>` |
| Datadog | `machine api.datadoghq.com login api password <key>` and `login app password <key>` |
| Octopus | `machine <octopus host> password <API key>`, plus `(setq cc-hub-octopus-url "https://...")` |
| GitHub (Forge) | `machine api.github.com login <user>^forge password <token>` |

Work-specific settings go in `config/doom/local.el`, which git ignores. Doom
loads it before `cc-hub`. Set at least the MCP tool prefix for `SPC l s` and
`SPC l b`:

```elisp
(setq cc-hub-mcp-prefix "mcp__claude_ai_<gateway>__")
```

### `SPC l` keys

| Key | Command | Keys in the buffer |
|---|---|---|
| `SPC l a` | Agents | `RET` attach, `p` peek logs, `d` Magit diff, `r` PR in Forge, `s` stop, `x` rm, `n` dispatch |
| `SPC l .` | Jump to the session that waited longest, at its prompt | |
| `SPC l n` | Dispatch `claude --bg --permission-mode plan --name KEY --worktree KEY` | |
| `SPC l r` | Review queue: finished agents and PRs for my review | `RET` Forge, `d` diff, `a` approve, `c` request changes, `o` browser |
| `SPC l i` | My Linear issues, joined to agents by key | `t` transition, `c` comment, `n` dispatch, `RET`/`o` open |
| `SPC l d` | Octopus deploy status | `RET` deep link |
| `SPC l m` | Datadog monitors | `n` dispatch a read-only investigation agent, `RET` deep link |
| `SPC l t` | Process buffers of this workspace and `.cc-procs.el` | `RET` jump or start, `S` start all, `R` restart, `x` kill |
| `SPC l s` | Slack catch-up (skill `slack-catchup`, MCP read tools) in an org buffer | |
| `SPC l b` | Morning brief (skill `morning-brief`) in an org buffer | |
| `SPC l w w`, `w a`, `w g`, `w m` | Dashboard, agent timeline, graph, metrics in xwidget-webkit | page keys: `g a`, `g g`, `g m`, `j`/`k`, `/` |
| `SPC l W` | Dashboard in the external browser (xwidget fallback) | |
| `SPC o c` | claude-code.el session for the current project (ghostel) | |

All lists also take `gr` refresh, `/` filter and `q` quit. The modeline shows
`⚑N` while N sessions wait for input. macOS notifications fire only when Emacs
is not the front app. In the xwidget buffer, printable keys go to the page; use
`M-SPC` for the Doom leader and `C-x b` to leave.

Project processes come from `.cc-procs.el` in the project root (read, never
evaluated), or from `cc-hub-project-procs`. On project switch, Emacs asks before
it starts the `:auto` entries:

```elisp
(("web" "npm run dev" :auto t)
 ("api" "go run ./cmd/api" :dir "backend")
 ("k9s" "k9s"))
```

### Keys that leave Emacs

| Key | Goes to | Why |
|---|---|---|
| `SPC l o` | Opal web UI (`cc-hub-opal-url`) | MFA blocks request creation from CLI and API |
| `RET` in `SPC l d` | Octopus project page | Deploys stay a human action in Octopus |
| `RET` in `SPC l m` | Datadog monitor page | Full dashboards stay in Datadog |
| Hyper+`S` / Hyper+`M` | Slack / meetings workspace (AeroSpace) | Writing in Slack and meetings stay in their apps |

OS layer: Karabiner `caps-hyper.json` (Caps tap Esc, hold Hyper), AeroSpace
workspaces E (Emacs), B (browser), S (Slack), M (meetings), and Ghostty only as
the Hyper+`` ` `` quick terminal.

