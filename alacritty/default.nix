{pkgs, config, lib, ...}:

let
  alacrittyConfig = pkgs.callPackage ./alacritty-config.nix { };
in {
  config = lib.mkIf config.provisioning.enableGui {
    programs.alacritty = {
      enable = true;
      settings = alacrittyConfig.config;
    };
  };
}