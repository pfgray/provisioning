{pkgs, config, ...}:

{
  imports = [
    ./bash/bash.nix
    ./utils.nix
    ./fish/fish.nix
    ./vscode/vscode.nix
    ./langs/nix.nix
    ./langs/ruby.nix
    ./langs/scala.nix
    ./langs/node.nix
    ./langs/dhall.nix
    ./langs/java.nix
    ./langs/haskell.nix
    ./overlays.nix
    ./iterm2
    ./alacritty
    ./tmux
  ];
}