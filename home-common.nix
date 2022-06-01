{pkgs, ...} @ input:

let
  recursiveMerge = import ./recursiveMerge.nix input;
in
  recursiveMerge [
    {
      # nixpkgs.config.allowUnfree = true;

      nixpkgs.config.allowUnfreePredicate = (pkg: true);
      home.packages = with pkgs; [
        curl
        wget
        jq
        nodejs
        yarn
        tmux
        vim
        whois
        git
        gnupg
        nodePackages.ts-node
        jwt-cli
        aws
        ruby
        rubocop
        kubectl
        postgresql
        ripgrep
        dhall
        dhall-json
        lsd
        bat
        gopass
        jdk8
        graphviz
        # mutagen
      ];

      programs = {
        home-manager.enable = true;
        java = {
          enable = true;
          package = pkgs.jdk8;
        };
      };
    }

    (import ./fish/fish.nix input)
    (import ./vscode/vscode.nix input)
  ]
