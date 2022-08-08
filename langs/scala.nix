{pkgs, ...}:

{
  config = {
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        scalameta.metals
      ];
    };

    home.packages = with pkgs; [
      pkgs.scala
    ];
  };
}