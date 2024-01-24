{pkgs, lib, config, ...}:

let
  alacrittyConfig = pkgs.callPackage ./alacritty-config.nix { };
in
  lib.mkIf config.programs.alacritty.enable {
    home.file.".alacritty.yml".text = builtins.toJSON alacrittyConfig.config;
  }