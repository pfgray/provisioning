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
    in {
      provision = {systemConfig, overrides} @ configs: {

        homeConfigurations = {
          "linux" = homeManager.lib.homeManagerConfiguration {
            configuration.imports = [
              (import ./home-linux)
              overrides
            ];

            inherit stateVersion;
            inherit (systemConfig) system username homeDirectory;
          };

          "darwin" = homeManager.lib.homeManagerConfiguration {
            configuration.imports = [
              (import ./home-darwin)
              overrides
            ];

            inherit stateVersion;
            inherit (systemConfig) system username homeDirectory;
          };
        };
      };
    };
}