{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, homeManager, flake-utils, ... }: 
    let
      stateVersion = "22.11";
      local = import ./local.nix;
    in {
      module = ./home-common.nix;
      lib = {
        bundix = import ./lib/bundix-helpers.nix;
      };
    } // flake-utils.lib.eachDefaultSystem(
      system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          init = import ./init system {pkgs = pkgs;};
        in rec {
          packages.init = init;
          apps.init = flake-utils.lib.mkApp {
            drv = init;
          };
        }
    );
}