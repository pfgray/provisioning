{pkgs, config, ...}:
let
  linuxPkgs = with pkgs; [
    docker
    docker-compose
  ];
in {
  config = {
    nixpkgs.config.allowUnfreePredicate = (pkg: true);
    home.packages = with pkgs; [
      curl
      wget
      jq
      tmux
      vim
      whois
      git
      gnupg
      jwt-cli
      aws
      kubectl
      postgresql
      ripgrep
      lsd
      bat
      gopass
      graphviz
      # mutagen
    ] ++ (if pkgs.stdenv.isLinux then linuxPkgs else []);

    programs = {
      home-manager.enable = true;
    };

  };

}