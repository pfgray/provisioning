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

        "linux" = homeManager.lib.homeManagerConfiguration {
          configuration.imports = [
            ./home-linux.nix
            ./home-common.nix
            local.overrides
          ];

          inherit stateVersion;
          inherit (local.systemConfig) system username homeDirectory;
        };

        "darwin" = homeManager.lib.homeManagerConfiguration {
          configuration.imports = [
            ./home-darwin.nix
            ./home-common.nix
            local.overrides
          ];

          inherit stateVersion;
          inherit (local.systemConfig) system username homeDirectory;
        };
      };
    };
}