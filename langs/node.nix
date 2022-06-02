{pkgs, ...}:

{
  # programs.vscode = {
  #  extensions = with pkgs.vscode-extensions; [
  #  ];
  # };

  home.packages = with pkgs; [
    nodePackages.ts-node
    nodejs
    yarn
  ];
}