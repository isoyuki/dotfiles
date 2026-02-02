{ pkgs, ... }:

{
  # Shared configuration for both Linux and macOS
  
  programs.home-manager.enable = true;

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

  # Dotfiles Configuration
  home.file = {
    # Editors
    ".config/nvim" = {
      source = ../config/nvim;
      recursive = true;
    };
    ".config/doom" = {
      source = ../config/doom;
      recursive = true;
    };

    # Terminal & Shell
    ".config/alacritty" = {
      source = ../config/alacritty;
      recursive = true;
    };
    ".config/tmux" = {
      source = ../config/tmux;
      recursive = true;
    };
    ".oh-my-zsh" = {
      source = ../config/oh-my-zsh;
      recursive = true;
    };
    ".zshrc".source = ../home/.zshrc;
    ".bashrc".source = ../home/.bashrc;
    ".bash_profile".source = ../home/.bash_profile;
    ".profile".source = ../home/.profile;
    
    # SSH Config
    ".ssh/config".source = ../home/.ssh/config;

    # Vim
    ".vim" = {
      source = ../home/.vim;
      recursive = true;
    };
  };



  # Example of migrating a simple config (Git)
  programs.git = {
    enable = true;
    # Identity is set in git-personal.nix or git-work.nix
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

}
