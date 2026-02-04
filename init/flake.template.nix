{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    provisioning.url = "github:pfgray/provisioning";
  };

  outputs = { nixpkgs, home-manager, provisioning, ... }:
    let
      system = "$init_system";
    in {
      homeConfigurations.base = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.$${system};

        modules = [
          provisioning.module
          {
            home = {
              username = "$init_username";
              homeDirectory = "$init_homedir";
              stateVersion = "21.11";
            };
          }
        ];
      };
    };
}
