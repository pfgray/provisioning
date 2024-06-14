{pkgs, lib, config, ...}:

let
  concat = import ./concat pkgs;
in {
  options = {
    tools.video-editing = {
      enable = lib.mkEnableOption "Video Editing Tools";
    };
  };

  config = lib.mkIf config.tools.video-editing.enable {
    home.packages = with pkgs; [
      concat
    ];
  };
}