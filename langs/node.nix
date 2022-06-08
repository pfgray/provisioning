{pkgs, ...}:

{
  config = {
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        esbenp.prettier-vscode
      ];
    };

    home.packages = with pkgs; [
      nodePackages.ts-node
      nodejs
      yarn
    ];
  };
}