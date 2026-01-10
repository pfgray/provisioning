{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.claude-code;
in {
  options.programs.claude-code = {
    enable = mkEnableOption "claude-code";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];
  };
}
