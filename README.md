# Dotfiles

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

## Nix & Home Manager Setup

Alongside the script-based installation, this repository now includes a setup for managing packages and configurations declaratively using [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager). This allows for reproducible, isolated, and predictable environments.

### Initial Setup

1.  **Install Nix:** If you haven't already, install the Nix package manager. The recommended multi-user installation can be done by running:
    ```bash
    sh <(curl -L https://nix.dev/install) --daemon
    ```

2.  **Enable Flakes:** The Nix configuration for this repository uses Flakes, a modern feature for managing dependencies. Enable it by adding the following to `~/.config/nix/nix.conf` (or `/etc/nix/nix.conf`):
    ```
    experimental-features = nix-command flakes
    ```

3.  **Apply Configuration:** Run the initial activation from the root of this repository. This will install the packages and create the symlinks defined in `nix/home.nix`.
    ```bash
    home-manager switch --flake ./nix#wren
    ```
    > **Note:** Nix requires configuration files to be tracked by Git. If you get an error, make sure any changes to the `nix/` directory are added and committed.

### Managing Your Configuration

The entire Nix setup is contained within the `nix/` directory.

-   `nix/flake.nix`: This file pins the versions of `nixpkgs` and `home-manager`. You generally won't need to edit this unless you want to update these dependencies.
-   `nix/home.nix`: This is your main configuration file. You can manage packages, services, and other settings here.

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

To add a new package to your environment:

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

After modifying `nix/home.nix` or any other file in the `nix/` directory, apply the changes by running the following command from the root of the repository:

```bash
home-manager switch --flake ./nix#wren
```

This command will build your new configuration and activate it, making the new packages available in your shell. Remember to commit your changes to Git.
