{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, homeManager, ... } @ inputs: 
    let
      stateVersion = "21.11";
    in {
    
      homeConfigurations = {
        "linux-personal" = homeManager.lib.homeManagerConfiguration {
          configuration = import ./home-linux.nix;

          inherit stateVersion;
          system = "x86_64-linux";
          username = "paul";
          homeDirectory = "/home/paul";
        };

        "darwin-nicole-m1" = homeManager.lib.homeManagerConfiguration {
          configuration = import ./home-darwin.nix;
          inherit stateVersion;

          system = "aarch64-darwin";
          username = "nicole";
          homeDirectory = "/Users/nicole";
        };


        "darwin-work" = homeManager.lib.homeManagerConfiguration {
          configuration = import ./home-darwin.nix;
          inherit stateVersion;

          system = "x86_64-darwin";
          username = "paul.gray";
          homeDirectory = "/Users/paul.gray";
        };
      };
    };
}