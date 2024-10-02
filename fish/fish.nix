{pkgs, lib, config, ...}:

let 
  bobthefish = {
    name = "bobthefish";
    src = pkgs.fetchFromGitHub {
      owner = "oh-my-fish";
      repo = "theme-bobthefish";
      rev = "ed896b65c3ddbdf2929c38719adfb940b0d9b90d";
      sha256 = "sha256-DRMBZS8nT0rhKXQEGWNqR1FUavtvxH0xUdHU52WhSJQ=";
    };
  };

  foreignEnv = {
    name = "foreign-env";
    src = pkgs.fetchFromGitHub {
      owner = "oh-my-fish";
      repo = "plugin-foreign-env";
      rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
      sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
    };
  };

  fish-completion-sync = {
    name = "fish-completion-sync";
    src = pkgs.fetchFromGitHub {
      owner = "pfgray";
      repo = "fish-completion-sync";
      rev = "98f43ffcdb4e69fa5c08f94f929b8c51ba65ebc8";
      sha256 = "sha256-J0JXEjM9Rhi5r9dMON1zEBbYK8oYzDGx4yCmhDoNMKw";
    };
  };
in {
  config = {
    programs.fish = {
      enable = true;
      shellInit = ''
      ${builtins.readFile ./config.fish}

      ${lib.mkIf (config.tools.rapture.enable) ''
        eval ( command rapture shell-init )
      ''}
      '';

      shellAliases = {
        dc = "docker compose";
      };

      plugins = [
        bobthefish
        foreignEnv
        fish-completion-sync
      ];
    };

    xdg.configFile."fish/conf.d/plugin-bobthefish.fish".text = lib.mkAfter ''
      for f in $plugin_dir/*.fish
        source $f
      end
      '';
  };
}
