{pkgs, lib, ...}:

let 
  bobthefish = {
    name = "bobthefish";
    src = pkgs.fetchFromGitHub {
      owner = "oh-my-fish";
      repo = "theme-bobthefish";
      rev = "a2ad38aa051aaed25ae3bd6129986e7f27d42d7b";
      sha256 = "1fssb5bqd2d7856gsylf93d28n3rw4rlqkhbg120j5ng27c7v7lq";
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
      rev = "483145eb997c47dd8b16f193dd0b927d76ec122c";
      sha256 = "sha256-MnrDegGc3kmnfL021JZWRLR8iaYYwwoy0FpUSP7AeVA=";
    };
  };
in {
  config = {
    programs.fish = {
      enable = true;
      shellInit = builtins.readFile ./config.fish;

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
