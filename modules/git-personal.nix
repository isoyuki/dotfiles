{ pkgs, ... }:

{
  programs.git = {
    userName = "Wren (Personal)";
    userEmail = "wren@personal.example.com";
    
    # Optional: Personal specific signing key
    # signing = {
    #   key = "...";
    #   signByDefault = true;
    # };
  };
}
