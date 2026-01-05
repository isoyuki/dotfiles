{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "wren";
  home.homeDirectory = "/home/wren";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You can update this value Home Manager release schedules indicated in
  # https://github.com/nix-community/home-manager/releases
  home.stateVersion = "23.11";

  # The home.packages option allows you to install packages into your
  # environment.
  home.packages = [
    pkgs.htop
    pkgs.cowsay
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}