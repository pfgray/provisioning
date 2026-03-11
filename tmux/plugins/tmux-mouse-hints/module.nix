{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.tmux.mouseHints;

  # Generate the config file content
  configContent = concatMapStringsSep "\n"
    (entry: "${entry.pattern} = ${entry.command}")
    cfg.patterns;

  mouseHintsConfigFile = pkgs.writeText "tmux-mouse-hints.conf" ''
    # tmux-mouse-hints configuration
    # Format: regex = command
    # Use {match} in the command to reference the matched text

    ${configContent}
  '';

  # Build the plugin package
  mouseHintsPackage = pkgs.callPackage ./package.nix {
    configFile = mouseHintsConfigFile;
  };

in {
  options.programs.tmux.mouseHints = {
    enable = mkEnableOption "tmux mouse hints plugin";

    patterns = mkOption {
      type = types.listOf (types.submodule {
        options = {
          pattern = mkOption {
            type = types.str;
            description = "Regex pattern to match";
            example = "(https?|git|ssh|ftp|file)://[^\\s<>\"{}|\\^`\\\\]+";
          };

          command = mkOption {
            type = types.str;
            description = "Command to execute when pattern matches. Use {match} to reference the matched text.";
            example = "open {match}";
          };
        };
      });
      default = [];
      description = "List of pattern-command pairs for mouse hints";
      example = literalExpression ''
        [
          {
            pattern = "(https?|git|ssh|ftp|file)://[^\\s<>\"{}|\\^`\\\\]+";
            command = "''${pkgs.open}/bin/open {match}";
          }
        ]
      '';
    };
  };

  config = mkIf cfg.enable {
    # Generate tmux config snippet
    home.file.".config/tmux/tmux-mouse-hints-init.conf".text = ''
      # tmux-mouse-hints plugin initialization
      bind-key -n C-MouseDown1Pane run-shell -b "${mouseHintsPackage}/bin/tmux-mouse-hints-handler '#{mouse_word}' '#{mouse_x}' '#{mouse_y}' '#{pane_id}'"
    '';
  };
}
