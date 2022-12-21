{pkgs, lib, config, ...}:

{

  options = {
    langs.java = {
      enable = lib.mkEnableOption "The Java language";
    };
  };

  config =lib.mkIf config.langs.java.enable {
    programs.vscode.extensions = lib.mkIf config.programs.vscode.enable
      [
        # pkgs.vscode-extensions.esbenp.prettier-vscode
      ];
    programs = {
      java = {
        enable = true;
        package = pkgs.jdk17;
      };
    };
  };
}