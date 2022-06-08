{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, homeManager, ... }: 
    let
      stateVersion = "21.11";
      local = import ./local.nix;
    in {
      homeConfigurations = {

        "base" = homeManager.lib.homeManagerConfiguration {
          inherit stateVersion;
          inherit (local.systemConfig) system username homeDirectory;

          configuration.imports = [
            ./home-common.nix
            local.overrides
          ];
        };
      };
    };
}