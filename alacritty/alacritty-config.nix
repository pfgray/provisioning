{tmux, writeShellScriptBin, fish}:

let

  openGerritId = writeShellScriptBin "open-gerrit-id" ''
    G_ID=`echo $1 | sed -r 's/g\///'`
    open https://gerrit.instructure.com/c/$G_ID
  '';

in {
  config = {
    window = {
      decorations_theme_variant = "Dark";
    };
    font = {
      size = 18;
      normal.family = "Fantasque Sans Mono";
    };
    terminal.shell = {
      program = "${fish}/bin/fish";
    };
    # shell = {
    #   program = "${tmux}/bin/tmux";
    #   args = [
    #     "new-session"
    #     "-A"
    #     "-D"
    #     "-s"
    #     "main"
    #   ];
    # };
    hints = {
      enabled = [
        {
          hyperlinks = true;
          command = "open";
          binding = {
            mods = "Command";
            key = "Period";
          };
          mouse = {
            enabled = true;
            mods = "Control";
          };
        }
        {
          regex = "g/[0-9]*";
          command = "${openGerritId}/bin/open-gerrit-id";
          mouse = {
            enabled = true;
            mods = "Control";
          };
        }
      ];
    };
  };
}