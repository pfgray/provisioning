{pkgs, ...}:

{
  config = {
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
      ];
    };
  };
}