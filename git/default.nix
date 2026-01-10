{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeShellScriptBin "rubocop-commit" ''
      ${builtins.readFile ./rubocop_commit.sh}
    '')
  ];
}