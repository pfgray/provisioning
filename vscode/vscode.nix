{pkgs, lib, ...}: {


  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    # extensions = with pkgs.vscode-extensions; [
    #     bbenoist.nix
    #     # justusadam.language-haskell
    # ];
  };
}