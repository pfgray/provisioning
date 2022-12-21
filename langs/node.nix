{pkgs, lib, config, ...}:

{
  options = {
    langs.node = {
      enable = lib.mkEnableOption "The Nodejs engine";
    };
  };

  config = lib.mkIf config.langs.scala.enable {
    programs.vscode.extensions = lib.mkIf config.programs.vscode.enable
      [
        pkgs.vscode-extensions.esbenp.prettier-vscode
      ];

    home.packages = with pkgs; [
      nodePackages.ts-node
      nodejs
      yarn
    ];
  };
}