{
  description = "Multi-OS Dotfiles Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    
    # Configuration for Fedora (Linux)
    homeConfigurations."fedora" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ 
        ./modules/linux.nix 
      ];
    };

    # Configuration for macOS (Darwin)
    # Assuming Apple Silicon (aarch64-darwin). Change to x86_64-darwin if Intel.
    homeConfigurations."macos" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [ 
        ./modules/darwin.nix 
      ];
    };
  };
}
