{pkgs, config, lib, ...}:

lib.mkIf (pkgs.stdenv.isDarwin && config.provisioning.enableGui) {
  home.file."Library/Application\ Support/iTerm2/DynamicProfiles/iterm-profiles.json".source =
     ./iterm-profiles.json;

  #home.file."Library/Application\ Support/iTerm2/Scripts/AutoLaunch/set-default-profile.py".source =
   #  ./set-default-profile.py;
}