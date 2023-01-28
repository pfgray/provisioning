{pkgs, config, lib, ...}:

{
  options = {
    langs.haskell = {
      enable = lib.mkEnableOption "The Haskell language";
    };
  };

  config = lib.mkIf config.langs.haskell.enable {
    programs.vscode.extensions = lib.mkIf (config.programs.vscode.enable) [
      pkgs.vscode-extensions.haskell.haskell
    ];

    home.packages = with pkgs; [
      ghc
      haskell-language-server
    ];
  };
}