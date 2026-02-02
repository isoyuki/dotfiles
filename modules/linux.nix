{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/home/wren";

  # Linux specific packages
  home.packages = with pkgs; [
    # GUI Tools
    # alacritty # Managed via home-manager module ideally, or just package
    
    # Desktop Environment stuff
    # awesome # AwesomeWM is usually installed system-wide on NixOS, 
              # but on Fedora via HM you might just want the config management
  ];

  # Example: Symlinking your existing AwesomeWM config
  # This replaces 'stow awesome'
  home.file.".config/awesome" = {
    source = ../awesome/.config/awesome;
    recursive = true;
  };
  
  # X11 / GTK settings could go here
  gtk = {
    enable = true;
    # theme = ...
  };
}
