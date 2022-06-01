{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, homeManager, ... } @ input: 
    let
      recursiveMerge = import ./recursiveMerge.nix nixpkgs;
      stateVersion = "21.11";
      local = import ./local.nix;
    in {
      homeConfigurations = {
        "basic" = homeManager.lib.homeManagerConfiguration {
          configuration.imports = [
            ./home-splice-module.nix
          ];

          inherit stateVersion;
          inherit (local.systemConfig) system username homeDirectory;
        };

        "linux" = homeManager.lib.homeManagerConfiguration {
          configuration.imports = [
            ./home-linux.nix
            local.overrides
          ];

          inherit stateVersion;
          inherit (local.systemConfig) system username homeDirectory;
        };

        "darwin" = homeManager.lib.homeManagerConfiguration {
          configuration.imports = [
            ./home-darwin.nix
            local.overrides
          ];

          inherit stateVersion;
          inherit (local.systemConfig) system username homeDirectory;
        };
      };
    };
}