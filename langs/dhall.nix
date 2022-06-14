{pkgs, config, lib, ...}:

{
  options = {
    langs.dhall = {
      enable = lib.mkEnableOption "The Dhall language";
    };
  };

  config = {
    programs.vscode.extensions = lib.mkIf (config.programs.vscode.enable && config.langs.dhall.enable) [
      pkgs.vscode-extensions.dhall.vscode-dhall-lsp-server
    ];

    home.packages = with pkgs; lib.mkIf config.langs.dhall.enable [
      dhall
      dhall-json
    ];
  };
}