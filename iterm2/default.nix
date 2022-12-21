{pkgs, lib, ...}:

lib.mkIf pkgs.stdenv.isDarwin {
  xdg.configFile."iterm2/com.googlecode.iterm2.plist".source =
     ./com.googlecode.iterm2.plist;
}