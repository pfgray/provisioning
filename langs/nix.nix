{pkgs, ...}:

{
  config = {
    programs.vscode = {
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