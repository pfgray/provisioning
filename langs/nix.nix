{ pkgs, ... }:

{
  config = {
    programs.vscode.profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
      ];
    };

    home.packages = with pkgs; [
      nil
      nixpkgs-fmt
    ];
  };
}
