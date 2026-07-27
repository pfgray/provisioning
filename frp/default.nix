{ pkgs, config, lib, ... }:

{
  options = {
    frp = {
      enable = lib.mkEnableOption "FRP reverse proxy client";

      configText = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Contents of the frpc.toml configuration file";
      };
    };
  };

  config = lib.mkIf config.frp.enable {
    home.packages = [ pkgs.frp ];

    home.file.".config/frp/frpc.toml".text = lib.mkIf (config.frp.configText != "") config.frp.configText;
  };
}
