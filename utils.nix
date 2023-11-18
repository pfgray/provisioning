{pkgs, config, ...}:
let
  linuxPkgs = with pkgs; [
    docker
    docker-compose
  ];

  rapture = import ./tools/rapture pkgs;
  vaulted = import ./tools/vaulted pkgs;
  # kubectl1_22_7 =  import ./tools/kubectl pkgs;

in {
  config = {
    nixpkgs.config.allowUnfreePredicate = (pkg: true);
    home.packages = with pkgs; [
      # kubectl1_22_7

      curl
      gnugrep
      wget
      jq
      yq-go
      tmux
      vim
      # whois
      git
      gnupg
      jwt-cli
      # awscli2
      postgresql
      ripgrep
      lsd
      bat
      gopass
      graphviz

      # kubectl
      kustomize
      k9s
      kubectx
      rapture
      # vaulted
      fzf

      terraform
      terraform-ls
      # mutagen
    ] ++ (if pkgs.stdenv.isLinux then linuxPkgs else []);

    programs = {
      home-manager.enable = true;
      go.enable = true;
      direnv = {
        enable = true;
        # enableFishIntegration = true;
        config = {
          load_dotenv = true;
        };
        nix-direnv.enable = true;
      };
    };

  };

}