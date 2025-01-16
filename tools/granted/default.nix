{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.granted-fish;
  package = pkgs.granted.overrideAttrs (oldAttrs: {
    # Override installPhase to include assume.fish in the output
    installPhase = ''
      ${oldAttrs.installPhase}
      cp $src/scripts/assume.fish $out/bin/
    '';
  });

in {

  options.programs.granted-fish = {
    enable = mkEnableOption "granted-fish";

    enableFishIntegration = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable Fish integration.
      '';
    };
  };

  config = (mkIf cfg.enable {
    home.packages = [ package ];

    programs.fish.shellAliases = mkIf cfg.enableFishIntegration {
      assume = "source ${package}/bin/assume.fish";
    };
  });

}