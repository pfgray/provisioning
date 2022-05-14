{...}: {

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./config.fish;
  };
}