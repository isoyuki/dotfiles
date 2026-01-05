# Dotfiles

## Script-based Installation

Instructions for the legacy script-based setup.

To install dotfiles, run the following command:

```bash
./install.mjs [modules...] [--os <os>]
```

### Modules

Specify which modules to install by passing their names as arguments. If no modules are specified, a prompt will appear for selection.

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

Specify the operating system using the `--os` flag. The default OS is `fedora`.

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

---

## Nix & Home Manager Setup

A declarative setup for managing packages and configurations using [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) for reproducible, isolated, and predictable environments.

### Initial Setup

1.  **Install Nix:** Install the Nix package manager if it's not already present.
    ```bash
    sh <(curl -L https://nix.dev/install) --daemon
    ```

2.  **Enable Flakes:** The Nix configuration uses Flakes. Enable it by adding the following to `~/.config/nix/nix.conf` (or `/etc/nix/nix.conf`):
    ```
    experimental-features = nix-command flakes
    ```

3.  **Apply Configuration:** Run the initial activation from the root of the repository. This installs packages and creates symlinks defined in `nix/home.nix`.
    ```bash
    home-manager switch --flake ./nix#wren
    ```
    > **Note:** Nix requires configuration files to be tracked by Git. If an error occurs, ensure changes to the `nix/` directory are added and committed.

### Managing the Configuration

The entire Nix setup is contained within the `nix/` directory.

-   `nix/flake.nix`: Pins the versions of `nixpkgs` and `home-manager`. Generally does not need to be edited unless updating dependencies.
-   `nix/home.nix`: The main configuration file for managing packages, services, and other settings.

#### Searching for Packages

To find available packages in `nixpkgs`, use the `nix search` command:

```bash
nix search nixpkgs <package-name>
```

For example:
```bash
nix search nixpkgs neofetch
```

#### Adding a Package

To add a new package:

1.  Open `nix/home.nix`.
2.  Add the package name to the `home.packages` list. For example, to add `neofetch`:
    ```nix
    home.packages = [
      pkgs.htop
      pkgs.cowsay
      pkgs.neofetch # Add the new package here
    ];
    ```
3.  Save the file.

#### Applying Changes

After modifying `nix/home.nix`, apply the changes by running the following command from the root of the repository:

```bash
home-manager switch --flake ./nix#wren
```

This command builds the new configuration and activates it, making new packages available in the shell. Remember to commit any changes to Git.
