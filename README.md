# Dotfiles

## Nix & Home Manager Setup

A declarative setup for managing packages and configurations using [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager). This setup supports both Linux (Fedora) and macOS.

### Prerequisites

1.  **Install Nix:**
    ```bash
    sh <(curl -L https://nixos.org/nix/install) --daemon
    ```

2.  **Enable Flakes:**
    Edit `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` and add:
    ```
    experimental-features = nix-command flakes
    ```

### Directory Structure

The configuration is split into modules for reuse:

*   `flake.nix`: Entry point defining configurations (`fedora` and `macos`).
*   `modules/common.nix`: Packages and settings shared by all OSs.
*   `modules/linux.nix`: Linux-specific settings (e.g., Desktop Environment configs).
*   `modules/darwin.nix`: macOS-specific settings.

### Usage

**1. Apply Configuration**

Run the following command from the repository root to build and activate your environment:

*   **Fedora (Linux):**
    ```bash
    nix run home-manager/master -- switch --flake .#fedora
    ```

*   **macOS:**
    ```bash
    nix run home-manager/master -- switch --flake .#macos
    ```

**2. Update Packages**

To update all packages to their latest versions defined in `nixpkgs`:

```bash
nix flake update
nix run home-manager/master -- switch --flake .#<profile>
```

### Managing Configuration

**Adding Packages:**
*   Add cross-platform tools (e.g., `ripgrep`) to `modules/common.nix`.
*   Add OS-specific tools to `modules/linux.nix` or `modules/darwin.nix`.

**Managing Dotfiles:**
*   **Symlinking:** You can map existing dotfiles (like `awesome/`) using `home.file` in the relevant module:
    ```nix
    home.file.".config/awesome" = {
      source = ../awesome/.config/awesome;
      recursive = true;
    };
    ```
*   **Native Config:** Prefer using Home Manager modules (e.g., `programs.git`) for better integration where possible.

> **Note:** Changes to config files managed by Home Manager require running the `switch` command to take effect.
