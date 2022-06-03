{ bundlerApp, ... }:

bundlerApp {
  pname = "htmlbeautifier";
  gemdir = ./.;
  exes = [ "htmlbeautifier" ];
}