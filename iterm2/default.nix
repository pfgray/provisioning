{pkgs, lib, ...}:

{
  xdg.configFile."iterm2/com.googlecode.iterm2.plist".source =
    lib.mkIf pkgs.stdenv.isDarwin ./com.googlecode.iterm2.plist;
}