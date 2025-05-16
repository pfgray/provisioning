{pkgs, ...}:

let
  alacrittyConfig = pkgs.callPackage ./alacritty-config.nix { };
in {
  config.programs.alacritty.settings = alacrittyConfig.config;
}