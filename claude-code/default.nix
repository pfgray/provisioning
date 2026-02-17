{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf config.provisioning.enableGui {
    home.packages = [ pkgs.claude-code ];
  };
}
