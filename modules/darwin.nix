{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/Users/wren";

  # macOS specific packages
  home.packages = with pkgs; [
    # raycast
    # yabai
  ];

  # macOS specific configuration
}
