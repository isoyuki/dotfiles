{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = builtins.getEnv "HOME";

  # macOS specific packages
  home.packages = with pkgs; [
    # raycast
    # yabai
  ];

  # macOS specific configuration
}
