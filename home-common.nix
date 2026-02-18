{ pkgs, config, lib, ... }:

{
  imports = [
    # Always enabled - CLI core
    ./bash/bash.nix
    ./utils.nix
    ./fish/fish.nix
    ./git/default.nix
    ./tmux
    ./video-tools
    ./overlays.nix

    # Language tools (have their own enable flags)
    ./langs/nix.nix
    ./langs/ruby.nix
    ./langs/scala.nix
    ./langs/node.nix
    ./langs/dhall.nix
    ./langs/rust.nix
    ./langs/java.nix
    ./langs/haskell.nix

    # GUI applications - conditionally enabled via enableGui
    ./vscode/vscode.nix
    ./iterm2
    ./alacritty
    ./claude-code
    ./obsidian
  ];
}
