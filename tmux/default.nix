{ pkgs, ... }:

{
  imports = [
    ./plugins/tmux-mouse-hints/module.nix
  ];

  home.file.".tmux.conf".source = ./.tmux.conf;

  # Configure tmux mouse hints
  programs.tmux.mouseHints = {
    enable = true;
    patterns = [
      {
        pattern = "(https?|git|ssh|ftp|file)://[^\\s<>\"{}|\\^`\\\\]+";
        command = "open {match}";
      }
      {
        pattern = "(ipfs:|ipns:)[^\\s<>\"{}|\\^`\\\\]+";
        command = "open {match}";
      }
      {
        pattern = "mailto:[^\\s<>\"{}|\\^`\\\\]+";
        command = "open {match}";
      }
      {
        pattern = "g/[0-9]+";
        command = "/nix/store/z86032kgdx2m41l5in2by95805r4pa7q-open-gerrit-id/bin/open-gerrit-id {match}";
      }
      {
        pattern = "(\\/|\\.(\\/|\\.\\/))[\\/\\w\\.\\-]+";
        command = "open {match}";
      }
    ];
  };
}