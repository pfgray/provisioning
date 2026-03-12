{ pkgs, ... }:

{
  imports = [
    ./plugins/tmux-mouse-hints/module.nix
  ];

  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "screen-256color";

    # Disable default styling to let catppuccin handle it
    disableConfirmationPrompt = true;

    # Don't use plugins list - load catppuccin manually to avoid run-shell issues
    plugins = [ ];

    extraConfig = ''
      # Load catppuccin theme directly
      set -g @catppuccin_flavor 'mocha'
      set -g @catppuccin_window_status_style 'rounded'

      # Customize status bar background - options: default, or any @thm_ color
      # Examples: @thm_crust, @thm_mantle, @thm_surface_0, @thm_surface_1
      set -g @catppuccin_status_background "#{@thm_surface_0}"

      # Customize active/current window colors
      set -g @catppuccin_window_current_text_color "#{@thm_surface_0}"
      # set -g @catppuccin_window_current_number_color "#{@thm_mauve}"

      source-file ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin_options_tmux.conf
      source-file ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin_tmux.conf

      ${builtins.readFile ./.tmux.conf}

      # Configure status bar after catppuccin loads
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_session}"
      set -g status-right-length 100

      # Customize copy mode selection highlight (when selecting text)
      set -g mode-style "fg=#{@thm_fg},bg=#{@thm_surface_2},bold"
    '';
  };

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
