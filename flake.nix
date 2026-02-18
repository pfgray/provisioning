{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { nixpkgs, home-manager, flake-utils, claude-code, ... }@inputs:
    let
      stateVersion = "22.11";
      local = import ./local.nix;
    in
    {
      module = { config, lib, ... }: {
        options.provisioning = {
          enableGui = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable GUI applications (vscode, alacritty, iterm2, etc)";
          };
        };

        config = {
          _module.args = { inherit inputs; };
        };

        imports = [ ./home-common.nix ];
      };
      lib = {
        bundix = import ./lib/bundix-helpers.nix;
      };
    } // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        init = import ./init system { pkgs = pkgs; };
        obsidian-plugin = import ./obsidian/plugin { inherit pkgs; };
      in
      rec {
        packages.init = init;
        packages.obsidian-plugin = obsidian-plugin;
        apps.init = flake-utils.lib.mkApp {
          drv = init;
        };
      }
    );
}
