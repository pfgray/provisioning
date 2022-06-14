{pkgs, config, ...}:
let
  linuxPkgs = with pkgs; [
    docker
    docker-compose
  ];

  rapture = import ./tools/rapture pkgs;
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
      postgresql
      ripgrep
      lsd
      bat
      gopass
      graphviz

      kubectl
      kustomize
      k9s
      kubectx
      asdf
      rapture

      terraform
      terraform-ls
      # mutagen
    ] ++ (if pkgs.stdenv.isLinux then linuxPkgs else []);

    programs = {
      home-manager.enable = true;
      go.enable = true;
    };

  };

}