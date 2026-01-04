# Dotfiles

This repository contains my personal dotfiles. They are managed by a custom script `install.mjs` that uses `zx` to install and configure my development environment.

## Usage

To install the dotfiles, run the following command:

```bash
./install.mjs [modules...] [--os <os>]
```

### Modules

You can specify which modules to install by passing their names as arguments. If no modules are specified, you will be prompted to select them.

Available modules:

*   `core`: Installs essential packages.
*   `dev`: Installs development tools.
*   `github`: Installs packages from GitHub.
*   `fonts`: Installs fonts.
*   `alacritty`: Configures Alacritty.
*   `awesome`: Configures AwesomeWM.
*   `bash`: Configures Bash.
*   `emacs`: Configures Emacs.
*   `git`: Configures Git.
*   `gtk`: Configures GTK.
*   `nvim`: Configures Neovim.
*   `rofi`: Configures Rofi.
*   `ssh`: Configures SSH.
*   `systemd`: Configures Systemd.
*   `tmux`: Configures Tmux.
*   `vim`: Configures Vim.
*   `zsh`: Configures Zsh.

To install all modules, use the `all` keyword.

### Operating System

You can specify the operating system using the `--os` flag. The default operating system is `fedora`.

Supported operating systems:

*   `fedora`
*   `arch`
*   `ubuntu`
*   `macos`

### Examples

Install all modules for Fedora:

```bash
./install.mjs all --os fedora
```

Install the `core` and `dev` modules for Ubuntu:

```bash
./install.mjs core dev --os ubuntu
```

Install the `zsh` module for macOS:

```bash
./install.mjs zsh --os macos
```
