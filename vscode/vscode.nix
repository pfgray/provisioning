{pkgs, lib, ...}:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    keybindings = import ./keybindings.nix;
    extensions = with pkgs.vscode-extensions; [
      justusadam.language-haskell
      silvenon.mdx
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      skyapps.fish-vscode
    ];
  };
}