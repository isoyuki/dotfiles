{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.username = "wren";
  home.homeDirectory = "/home/wren";

  # Linux specific packages
  home.packages = with pkgs; [
    # GUI Tools
    # alacritty # Managed via home-manager module ideally, or just package
    
    # Desktop Environment stuff
    # awesome # AwesomeWM is usually installed system-wide on NixOS, 
              # but on Fedora via HM you might just want the config management
  ];

  # AwesomeWM
  home.file.".config/awesome" = {
    source = ../config/awesome;
    recursive = true;
  };

  # Rofi
  home.file.".config/rofi" = {
    source = ../config/rofi;
    recursive = true;
  };

  # GTK 3.0
  home.file.".config/gtk-3.0" = {
    source = ../config/gtk-3.0;
    recursive = true;
  };

  # Systemd User Units
  home.file.".config/systemd" = {
    source = ../config/systemd;
    recursive = true;
  };

  # X11 Configuration
  home.file.".Xresources".source = ../home/.Xresources;
  home.file.".xinitrc".source = ../home/.xinitrc;
  
  # User Fonts
  home.file.".fonts" = {
    source = ../home/.fonts;
    recursive = true;
  };


  
  # X11 / GTK settings could go here
  gtk = {
    enable = true;
    # theme = ...
  };
}
