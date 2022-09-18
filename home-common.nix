{pkgs, config, ...}:

{
  imports = [
    ./utils.nix
    ./fish/fish.nix
    ./vscode/vscode.nix
    ./langs/nix.nix
    ./langs/ruby.nix
    ./langs/scala.nix
    ./langs/node.nix
    ./langs/dhall.nix
    ./langs/java.nix
    ./overlays.nix
    ./iterm2
  ];
}