{pkgs, config, lib, ...}:

{
  options = {
    langs.rust = {
      enable = lib.mkEnableOption "The Rust language";
    };
  };

  config = {
    programs.vscode.extensions = lib.mkIf (config.programs.vscode.enable && config.langs.rust.enable) [
      pkgs.vscode-extensions.rust-lang.rust-analyzer
    ];

    home.packages = with pkgs; lib.mkIf config.langs.rust.enable [
      cargo
      gcc
      rustfmt
    ];
  };
}