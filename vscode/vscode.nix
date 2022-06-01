{pkgs, lib, ...}:

{
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        justusadam.language-haskell
        scalameta.metals
        silvenon.mdx
        esbenp.prettier-vscode
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        skyapps.fish-vscode
        dhall.vscode-dhall-lsp-server
      ];
    };
  }