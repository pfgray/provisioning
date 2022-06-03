{pkgs, ...}:

{
  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      dhall.vscode-dhall-lsp-server
    ];
  };

  home.packages = with pkgs; [
    dhall
    dhall-json
  ];
}