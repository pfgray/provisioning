{pkgs, lib, config, ...}:

{

  options = {
    langs.scala = {
      enable = lib.mkEnableOption "The Scala language";
    };
  };

  config = lib.mkIf config.langs.scala.enable {
    programs.vscode.extensions = lib.mkIf config.programs.vscode.enable
      [
        pkgs.vscode-extensions.scalameta.metals
      ];

    home.packages = with pkgs; [
      pkgs.scala
    ];
  };
}