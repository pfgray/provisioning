{pkgs, lib, ...}:

lib.mkIf pkgs.stdenv.isDarwin {
  home.file."Library/Application\ Support/iTerm2/DynamicProfiles/iterm-profiles.json".source =
     ./iterm-profiles.json;
}