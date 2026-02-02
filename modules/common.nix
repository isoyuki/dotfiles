{ pkgs, ... }:

{
  # Shared configuration for both Linux and macOS
  
  programs.home-manager.enable = true;

  home.username = "wren";
  # Note: homeDirectory is usually set in the flake or platform specific file
  # to handle /home/wren vs /Users/wren

  home.stateVersion = "23.11";

  # Common packages
  home.packages = with pkgs; [
    # Core tools
    git
    htop
    ripgrep
    fzf
    jq
    tree
    
    # Editors
    neovim
    
    # Shell
    zsh
  ];

  # Example of migrating a simple config (Git)
  programs.git = {
    enable = true;
    userName = "Wren";
    # userEmail = "wren@example.com"; # TODO: Set your email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
