{ pkgs, ... }:

{
  programs.git = {
    userName = "Wren (Work)";
    # userEmail is NOT set here to keep it out of the git repo.
    # It should be set in ~/.gitconfig.local
    
    extraConfig = {
      include.path = "~/.gitconfig.local";
    };
  };
}
